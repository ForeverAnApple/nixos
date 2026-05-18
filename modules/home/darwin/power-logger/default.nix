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

        # Only the per-process held assertions — these are the ones that block sleep.
        # Filter out coreaudiod's per-context spam, keep totals + named owners.
        assertions="$(/usr/bin/pmset -g assertions \
          | awk '/Listed by owning process:/{p=1;next} /^Kernel Assertions:/{p=0} p' \
          | grep -vE 'audio\.context[0-9]+\.preventuser' \
          | tr '\n' '|' \
          | sed 's/|  */ ## /g; s/^ *## //; s/ *## $//')"

        printf '%s\tbatt=%s\tassertions=%s\n' "$ts" "$batt" "$assertions" >> "$log"

        # Cheap daily rotation: keep <= 14 days.
        find "$log_dir" -name 'power.log.*' -mtime +14 -delete 2>/dev/null || true
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
