# Periodic battery + sleep-assertion snapshot logger.
#
# Why: macOS keeps detailed pmset logs, but only on a rolling buffer that
# gets noisy fast (sharingd Handoff, coreaudio per-context, …). For
# "what drained my battery last night" you want a thin signal: timestamp,
# charge, AC vs batt, and *who* is holding sleep-blocking assertions.
#
# Output:  ~/Library/Logs/power-logger/power.log
# Query:   `power-history` (last 50 entries), `power-since 18:00` (filtered)
{ config, ... }:
{
  flake.modules.homeManager.power-logger =
    { pkgs, ... }:
    let
      # One snapshot. Single line for each fact so `grep`/`awk` stay trivial.
      logger = pkgs.writeShellScript "power-logger-snapshot" ''
        set -u
        log_dir="$HOME/Library/Logs/power-logger"
        mkdir -p "$log_dir"
        log="$log_dir/power.log"
        ts="$(date '+%Y-%m-%d %H:%M:%S')"

        # Battery line: "Now drawing from 'Battery Power' / -InternalBattery-0 (id=…) 73%; discharging; 4:12 remaining"
        batt="$(/usr/bin/pmset -g batt | tr '\n' ' ' | sed 's/  */ /g')"

        # Instantaneous draw at the cell (no root). ioreg reports Amperage as an
        # unsigned 64-bit word; bash arithmetic reinterprets it as signed two's
        # complement, so a discharging (negative) current comes back negative.
        # Anchor on " = " so we match only top-level scalars, not the nested
        # BatteryData blob (which repeats keys like "Voltage" with no spaces).
        battreg="$(/usr/sbin/ioreg -rn AppleSmartBattery)"
        amp="$(printf '%s\n' "$battreg" | awk -F' = ' '/"Amperage" = /{print $2; exit}')"
        volt="$(printf '%s\n' "$battreg" | awk -F' = ' '/"Voltage" = /{print $2; exit}')"
        power="?"
        if [ -n "$amp" ] && [ -n "$volt" ]; then
          dw=$(( (amp) * volt / 100000 ))
          sign=""; a=$dw; [ "$a" -lt 0 ] && { sign="-"; a=$(( -a )); }
          power="''${sign}$(( a / 10 )).$(( a % 10 ))W"
        fi

        # Only the per-process held assertions — these are the ones that block sleep.
        # Filter out coreaudiod's per-context spam, keep totals + named owners.
        assertions="$(/usr/bin/pmset -g assertions \
          | awk '/Listed by owning process:/{p=1;next} /^Kernel Assertions:/{p=0} p' \
          | grep -vE 'audio\.context[0-9]+\.preventuser' \
          | tr '\n' '|' \
          | sed 's/|  */ ## /g; s/^ *## //; s/ *## $//')"

        printf '%s\tbatt=%s\tpower=%s\tassertions=%s\n' "$ts" "$batt" "$power" "$assertions" >> "$log"

        # Cheap daily rotation: keep <= 14 days.
        find "$log_dir" -name 'power.log.*' -mtime +14 -delete 2>/dev/null || true
        if [ "$(date '+%H%M')" = "0000" ] && [ -f "$log" ]; then
          mv "$log" "$log.$(date '+%Y-%m-%d')"
        fi
      '';

      # Per-process energy + capacity health. Needs root (powermetrics), so it
      # leans on the NOPASSWD sudoers rule in modules/darwin/core/power-logger.nix.
      # Runs less often than the cheap snapshot — energy hogs and cell wear both
      # move slowly, and each sample costs a 5s powermetrics window.
      energy = pkgs.writeShellScript "power-logger-energy" ''
        set -u
        log_dir="$HOME/Library/Logs/power-logger"
        mkdir -p "$log_dir"
        log="$log_dir/energy.log"
        ts="$(date '+%Y-%m-%d %H:%M:%S')"

        battreg="$(/usr/sbin/ioreg -rn AppleSmartBattery)"
        maxc="$(printf '%s\n' "$battreg" | awk -F' = ' '/"AppleRawMaxCapacity" = /{print $2; exit}')"
        design="$(printf '%s\n' "$battreg" | awk -F' = ' '/"DesignCapacity" = /{print $2; exit}')"
        cycles="$(printf '%s\n' "$battreg" | awk -F' = ' '/"CycleCount" = /{print $2; exit}')"
        health="?"
        [ -n "$maxc" ] && [ -n "$design" ] && [ "$design" -gt 0 ] \
          && health="$(( maxc * 100 / design ))% (''${maxc}/''${design} mAh)"

        {
          printf '==== %s  health=%s  cycles=%s ====\n' "$ts" "$health" "''${cycles:-?}"
          # powermetrics sorts the task table by energy impact; header + top 8.
          /usr/bin/sudo -n /usr/bin/powermetrics --samplers tasks --show-process-energy \
            -n 1 -i 5000 2>/dev/null \
            | awk '/^Name/{p=1} p' | head -9
          printf '\n'
        } >> "$log"

        find "$log_dir" -name 'energy.log.*' -mtime +14 -delete 2>/dev/null || true
        if [ "$(date '+%H%M')" = "0000" ] && [ -f "$log" ]; then
          mv "$log" "$log.$(date '+%Y-%m-%d')"
        fi
      '';
    in
    {
      launchd.agents.power-logger = {
        enable = true;
        config = {
          ProgramArguments = [ "${logger}" ];
          StartInterval = 300; # 5 min
          RunAtLoad = true;
          StandardOutPath = "/tmp/power-logger.out";
          StandardErrorPath = "/tmp/power-logger.err";
        };
      };

      launchd.agents.power-logger-energy = {
        enable = true;
        config = {
          ProgramArguments = [ "${energy}" ];
          StartInterval = 1800; # 30 min
          RunAtLoad = true;
          StandardOutPath = "/tmp/power-logger-energy.out";
          StandardErrorPath = "/tmp/power-logger-energy.err";
        };
      };

      home.packages = [
        (pkgs.writeShellScriptBin "power-history" ''
          tail -n "''${1:-50}" "$HOME/Library/Logs/power-logger/power.log"
        '')
        (pkgs.writeShellScriptBin "power-since" ''
          # power-since "2026-05-12 18:00"  →  every snapshot after that time
          if [ $# -lt 1 ]; then
            echo "usage: power-since 'YYYY-MM-DD HH:MM'" >&2
            exit 2
          fi
          awk -F'\t' -v cutoff="$1" '$1 >= cutoff' \
            "$HOME/Library/Logs/power-logger/power.log"
        '')
        (pkgs.writeShellScriptBin "power-top" ''
          # Recent per-process energy snapshots + capacity-health trend.
          tail -n "''${1:-40}" "$HOME/Library/Logs/power-logger/energy.log"
        '')
        (pkgs.writeShellScriptBin "power-check" ''
          # Pre-bag sanity check: list anything currently blocking sleep
          # other than the routine system stuff. Non-zero exit if suspicious.
          out="$(/usr/bin/pmset -g assertions \
            | awk '/Listed by owning process:/{p=1;next} /^Kernel Assertions:/{p=0} p' \
            | grep -E 'PreventUserIdleSystemSleep|PreventSystemSleep|NoDisplaySleepAssertion' \
            | grep -vE 'powerd|WindowServer|backupd|com\.apple\.geod|sharingd')"
          if [ -n "$out" ]; then
            echo "⚠  Sleep blockers — close these before bagging:"
            echo "$out"
            exit 1
          fi
          echo "✓  No app-level sleep blockers."
        '')
      ];
    };
}
