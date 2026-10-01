{
  flake.modules.nixos."hosts/swordholder" = { pkgs, ... }: {
    # Replace the temporary units with this declarative health check on activation.
    system.activationScripts.zfs-health-hardening-cleanup = {
      deps = [ "etc" ];
      text = ''
        rm -f /etc/systemd/system.control/zfs-health.service
        rm -f /etc/systemd/system.control/zfs-health.timer
        rm -f /etc/systemd/system.control/timers.target.wants/zfs-health.timer
      '';
    };
    boot.supportedFilesystems = [ "zfs" ];

    boot.zfs = {
      devNodes = "/dev/disk/by-id";
      extraPools = [ "THICC" ];
      forceImportRoot = false;
      forceImportAll = false;
    };

    # Do NOT `zpool upgrade THICC` — burns the one-way rollback option.
    services.zfs.autoScrub = {
      enable = true;
      interval = "Sun *-*-* 03:00:00";
      pools = [ "THICC" ];
    };

    services.zfs.trim.enable = true;
    services.zfs.zed.enableMail = false;

    systemd.services.zfs-health = {
      script = ''
        set -euo pipefail
        export LC_ALL=C
        ${pkgs.zfs}/bin/zpool status -x | ${pkgs.gnugrep}/bin/grep -Fxq 'all pools are healthy'
      '';
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "1min";
      };
      unitConfig.OnFailure = [ "backup-alert@%n.service" ];
    };
    systemd.timers.zfs-health = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };
}
