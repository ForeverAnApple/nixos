# Nightly dumps of service state from the ext4 root onto the raidz1 pool.
# Snapshots: 90 dailies, monthlies/yearlies kept forever. Every run verifies
# its own output and fails the unit on corruption; a separate freshness timer
# fails if no successful backup landed in 48h.
# Local-only: survives root-disk death and fat-fingers, not a house fire.
{
  flake.modules.nixos."hosts/swordholder" =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      dest = "/THICC/Backups/swordholder";
      # local_only: caddy forwards real client IPs, so only on-host callers
      # (the OnFailure units) can trigger it despite the id being in-repo.
      alertWebhook = "bd6d99e96ae7cb2043bfdd0e45282fe4";
      sqliteDbs = [
        "/var/lib/komga/database.sqlite"
        "/var/lib/komga/tasks.sqlite"
        "/var/lib/komf/database.sqlite"
        "/var/lib/hass/home-assistant_v2.db"
        "/var/lib/audiobookshelf/config/absdatabase.sqlite"
        "/THICC/Forgejo/data/forgejo.db"
        "/THICC/Paperless/db.sqlite3"
        "/var/lib/sonarr/.config/NzbDrone/sonarr.db"
        "/var/lib/radarr/.config/Radarr/radarr.db"
        "/var/lib/bazarr/db/bazarr.db"
      ];
      stateDirs = [
        "/var/lib/komga"
        "/var/lib/komf"
        "/var/lib/hass"
        "/var/lib/audiobookshelf"
        "/var/lib/qbittorrent"
        "/var/lib/sonarr"
        "/var/lib/radarr"
        "/var/lib/bazarr"
        "/var/lib/tailscale"
        "/etc/ssh"
      ];
    in
    {
      # Remove the temporary hardening override when this declarative unit activates.
      system.activationScripts.state-backup-hardening-cleanup = {
        deps = [ "etc" ];
        text = ''
          rm -f /etc/systemd/system.control/state-backup.service.d/90-security-hardening.conf
        '';
      };
      services.sanoid = {
        templates.backup = {
          hourly = 0;
          daily = 90;
          monthly = 1200;
          yearly = 100;
          autosnap = true;
          autoprune = true;
        };
        datasets."THICC/Backups".useTemplate = [ "backup" ];
      };

      systemd.services.state-backup = {
        unitConfig.RequiresMountsFor = [ "/THICC/Backups" ];
        path = [
          pkgs.sqlite
          pkgs.rsync
          pkgs.zstd
          pkgs.util-linux
          pkgs.systemd
          config.services.postgresql.package
        ];
        script = ''
          set -euo pipefail
          umask 077
          ${pkgs.util-linux}/bin/mountpoint -q /THICC/Backups
          mkdir -p ${dest}/sqlite ${dest}/postgres ${dest}/state
          chmod 700 /THICC/Backups

          for db in ${lib.escapeShellArgs sqliteDbs}; do
            [ -f "$db" ] || { echo "Missing backup database: $db" >&2; exit 1; }
            out="${dest}/sqlite/$(echo "$db" | tr / _)"
            sqlite3 "$db" ".backup '$out.tmp'"
            [ "$(sqlite3 "$out.tmp" 'PRAGMA integrity_check;')" = "ok" ]
            mv "$out.tmp" "$out"
          done

          runuser -u postgres -- pg_dumpall | zstd -q -o ${dest}/postgres/pg_dumpall.sql.zst.tmp -f
          zstd -t -q ${dest}/postgres/pg_dumpall.sql.zst.tmp
          mv ${dest}/postgres/pg_dumpall.sql.zst.tmp ${dest}/postgres/pg_dumpall.sql.zst

          for dir in ${lib.escapeShellArgs stateDirs}; do
            [ -d "$dir" ] || { echo "Missing backup directory: $dir" >&2; exit 1; }
            rsync -a --delete "$dir" ${dest}/state/
          done

          restartUnits=()
          : > /run/state-backup/restart-units
          restoreServices() {
            status=$?
            trap - EXIT
            if [ "''${#restartUnits[@]}" -gt 0 ]; then
              systemctl start "''${restartUnits[@]}" || status=1
            fi
            exit "$status"
          }
          trap restoreServices EXIT
          for unit in suwayomi-server.service plex.service samba-smbd.service samba-nmbd.service samba-winbindd.service; do
            if systemctl is-active --quiet "$unit"; then
              restartUnits+=("$unit")
              printf '%s\n' "$unit" >> /run/state-backup/restart-units
              systemctl stop "$unit"
            fi
          done

          for dir in /var/lib/suwayomi-server /var/lib/samba '/var/lib/plex/Plex Media Server/Plug-in Support'; do
            [ -d "$dir" ] || { echo "Missing backup directory: $dir" >&2; exit 1; }
            rsync -a --delete "$dir" ${dest}/state/
          done

          if [ "''${#restartUnits[@]}" -gt 0 ]; then
            systemctl start "''${restartUnits[@]}"
            restartUnits=()
            : > /run/state-backup/restart-units
          fi

          date +%s > ${dest}/LAST_SUCCESS.tmp
          mv ${dest}/LAST_SUCCESS.tmp ${dest}/LAST_SUCCESS
        '';
        serviceConfig = {
          Type = "oneshot";
          RuntimeDirectory = "state-backup";
          RuntimeDirectoryMode = "0700";
          TimeoutStartSec = "10min";
          TimeoutStopSec = "2min";
          ExecStopPost = pkgs.writeShellScript "state-backup-restore-services" ''
            set -euo pipefail
            if [ -s /run/state-backup/restart-units ]; then
              mapfile -t units < /run/state-backup/restart-units
              ${pkgs.systemd}/bin/systemctl start "''${units[@]}"
            fi
          '';
        };
        unitConfig.OnFailure = [ "backup-alert@%n.service" ];
      };

      systemd.services."backup-alert@" = {
        scriptArgs = "%i";
        script = ''
          ${lib.getExe pkgs.curl} -sf -m 10 -X POST \
            -H "Content-Type: application/json" \
            -d "{\"message\": \"$1 failed on swordholder\"}" \
            http://127.0.0.1:8123/api/webhook/${alertWebhook}
        '';
        serviceConfig.Type = "oneshot";
      };

      services.home-assistant.config."automation manual" = [
        {
          alias = "backup-failure-alert";
          triggers = [
            {
              trigger = "webhook";
              webhook_id = alertWebhook;
              local_only = true;
              allowed_methods = [ "POST" ];
            }
          ];
          actions = [
            {
              action = "notify.notify";
              data = {
                title = "swordholder backup";
                message = "{{ trigger.json.message | default('backup failure') }}";
              };
            }
          ];
        }
      ];

      systemd.services.state-backup-freshness = {
        script = ''
          set -euo pipefail
          last=$(cat ${dest}/LAST_SUCCESS)
          [ $(( $(date +%s) - last )) -lt 172800 ]
        '';
        serviceConfig.Type = "oneshot";
        unitConfig.OnFailure = [ "backup-alert@%n.service" ];
      };

      systemd.timers.state-backup-freshness = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "12:00";
          Persistent = true;
        };
      };

      systemd.timers.state-backup = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "04:15";
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      };
    };
}
