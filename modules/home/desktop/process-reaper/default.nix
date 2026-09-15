# process-reaper: Kills stale dev processes older than 12h. Runs every 2 hours.
#
# Tools like opencode, neovim, and editors spawn child processes (tsserver, pyright,
# biome, etc.) that survive after the parent is closed. Over a day or two these orphans
# accumulate into GBs of wasted RAM and swap. This just kills anything matching the
# target list that's been running longer than 12 hours.
#
# wireplumber-watchdog: Restarts wireplumber when it's stuck burning a CPU core.
#
# Wireplumber 0.5.x has a bug where disconnecting an audio device (USB headset,
# monitor via HDMI/DP, etc.) leaves a phantom device (e.g. hw:1) in its session state.
# The ALSA SPA plugin tries to re-probe the missing device, fails, which fires a udev
# re-scan, which triggers another probe — an infinite retry loop with no backoff.
# This pins a full CPU core at 100% indefinitely. The fix is clearing wireplumber's
# state dir and restarting it. This watchdog checks CPU every 5 minutes and only
# restarts if it's actually spinning (>30%). Normal wireplumber sits at ~0% CPU so
# this never fires unless the bug is triggered.
# TODO: remove this when wireplumber fixes the ALSA device removal retry storm.
{
  flake.modules.homeManager.process-reaper =
    { pkgs, ... }:
    let
      reaper = pkgs.writeShellScript "process-reaper" ''
        export PATH="${pkgs.procps}/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.gnugrep}/bin:$PATH"

        MAX_AGE=43200      # 12 hours in seconds
        MAX_AGE_LONG=172800 # 2 days in seconds

        # Dev processes that should not live forever
        TARGETS="tsserver|typescript-language-server|pyright|yaml-language-server|eslint_d|biome|vite|next-server|webpack|turbopack|tailwindcss"
        TARGETS_LONG="opencode"

        killed=0
        # Match against both comm ($3) and the full args (everything after $3).
        # Some targets like vite run as "node .../vite" so comm is "node", not "vite".
        for pid in $(ps -eo pid= -o etimes= -o comm= -o args= | awk -v max="$MAX_AGE" -v targets="$TARGETS" '
          $2 > max && ($3 ~ targets || $0 ~ targets) { print $1 }
        '); do
          comm=$(ps -p "$pid" -o comm= 2>/dev/null || true)
          echo "Killing stale process: PID=$pid comm=$comm"
          kill "$pid" 2>/dev/null && killed=$((killed + 1))
        done

        # Long-lived dev tools get a longer leash
        for pid in $(ps -eo pid= -o etimes= -o comm= -o args= | awk -v max="$MAX_AGE_LONG" -v targets="$TARGETS_LONG" '
          $2 > max && ($3 ~ targets || $0 ~ targets) { print $1 }
        '); do
          comm=$(ps -p "$pid" -o comm= 2>/dev/null || true)
          echo "Killing stale process: PID=$pid comm=$comm"
          kill "$pid" 2>/dev/null && killed=$((killed + 1))
        done

        echo "Reaped $killed stale dev processes"
      '';

      wireplumber-watchdog = pkgs.writeShellScript "wireplumber-watchdog" ''
        export PATH="${pkgs.procps}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:$PATH"

        CPU_THRESHOLD=30

        pid=$(pgrep -x wireplumber 2>/dev/null || true)
        if [ -z "$pid" ]; then
          echo "wireplumber not running, skipping"
          exit 0
        fi

        # Get CPU% averaged over process lifetime
        cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null | awk '{printf "%d", $1}')
        if [ "$cpu" -gt "$CPU_THRESHOLD" ]; then
          echo "wireplumber (PID=$pid) at ''${cpu}% CPU — stuck in spin loop, restarting"
          rm -rf "''${XDG_STATE_HOME:-$HOME/.local/state}/wireplumber"
          systemctl --user restart wireplumber
          echo "wireplumber restarted with clean state"
        else
          echo "wireplumber OK (''${cpu}% CPU)"
        fi
      '';
    in
    {
      systemd.user.services.process-reaper = {
        Unit = {
          Description = "Kill stale dev processes older than 12 hours";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${reaper}";
        };
      };

      systemd.user.timers.process-reaper = {
        Unit = {
          Description = "Periodically reap stale dev processes";
        };
        Timer = {
          OnBootSec = "30min";
          OnUnitActiveSec = "2h";
          Unit = "process-reaper.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      systemd.user.services.wireplumber-watchdog = {
        Unit = {
          Description = "Restart wireplumber if stuck in CPU spin loop";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${wireplumber-watchdog}";
        };
      };

      systemd.user.timers.wireplumber-watchdog = {
        Unit = {
          Description = "Monitor wireplumber for CPU spin loops";
        };
        Timer = {
          OnBootSec = "2min";
          OnUnitActiveSec = "5min";
          Unit = "wireplumber-watchdog.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
}
