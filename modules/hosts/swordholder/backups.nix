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
      sqliteDbs = [
        "/var/lib/komga/database.sqlite"
        "/var/lib/komga/tasks.sqlite"
        "/var/lib/komf/database.sqlite"
        "/var/lib/hass/home-assistant_v2.db"
        "/var/lib/audiobookshelf/config/absdatabase.sqlite"
        "/THICC/Forgejo/data/forgejo.db"
        "/THICC/Paperless/db.sqlite3"
      ];
      stateDirs = [
        "/var/lib/komga"
        "/var/lib/komf"
        "/var/lib/suwayomi-server"
        "/var/lib/hass"
        "/var/lib/audiobookshelf"
        "/var/lib/qbittorrent"
        "/var/lib/tailscale"
        "/var/lib/plex/Plex Media Server/Plug-in Support"
        "/etc/ssh"
      ];
    in
    {
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
        path = [
          pkgs.sqlite
          pkgs.rsync
          pkgs.zstd
          pkgs.util-linux
          config.services.postgresql.package
        ];
        script = ''
          set -euo pipefail
          mkdir -p ${dest}/sqlite ${dest}/postgres ${dest}/state
          chmod 700 /THICC/Backups

          for db in ${lib.escapeShellArgs sqliteDbs}; do
            [ -f "$db" ] || continue
            out="${dest}/sqlite/$(echo "$db" | tr / _)"
            sqlite3 "$db" ".backup '$out.tmp'"
            mv "$out.tmp" "$out"
          done

          runuser -u postgres -- pg_dumpall | zstd -q -o ${dest}/postgres/pg_dumpall.sql.zst.tmp -f
          mv ${dest}/postgres/pg_dumpall.sql.zst.tmp ${dest}/postgres/pg_dumpall.sql.zst

          for dir in ${lib.escapeShellArgs stateDirs}; do
            [ -d "$dir" ] || continue
            rsync -a --delete "$dir" ${dest}/state/
          done

          for dump in ${dest}/sqlite/*; do
            [ "$(sqlite3 "$dump" 'PRAGMA integrity_check;')" = "ok" ]
          done
          zstd -t -q ${dest}/postgres/pg_dumpall.sql.zst
          date +%s > ${dest}/LAST_SUCCESS
        '';
        serviceConfig.Type = "oneshot";
      };

      systemd.services.state-backup-freshness = {
        script = ''
          set -euo pipefail
          last=$(cat ${dest}/LAST_SUCCESS)
          [ $(( $(date +%s) - last )) -lt 172800 ]
        '';
        serviceConfig.Type = "oneshot";
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
