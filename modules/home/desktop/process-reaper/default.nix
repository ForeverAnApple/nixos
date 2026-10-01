{
  flake.modules.homeManager.process-reaper =
    { pkgs, ... }:
    let
      wireplumber-watchdog = pkgs.writeShellScript "wireplumber-watchdog" ''
        export PATH="${pkgs.procps}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:$PATH"

        set -euo pipefail
        pid=$(pgrep -u "$(id -u)" -x wireplumber || true)
        [[ "$pid" =~ ^[0-9]+$ ]] || exit 0
        read -r before start < <(awk '{print $14 + $15, $22}' "/proc/$pid/stat")
        sleep 10
        [ -r "/proc/$pid/stat" ] || exit 0
        read -r after current_start < <(awk '{print $14 + $15, $22}' "/proc/$pid/stat")
        [ "$start" = "$current_start" ] || exit 0
        ticks=$(${pkgs.getconf}/bin/getconf CLK_TCK)
        if [ "$((after - before))" -gt "$((ticks * 3))" ]; then
          echo "wireplumber exceeded 30% CPU over 10 seconds; restarting"
          ${pkgs.systemd}/bin/systemctl --user restart wireplumber
        fi
      '';
    in
    {
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
