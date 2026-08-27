# Nightly dumps of service state from the ext4 root onto the raidz1 pool,
# versioned by sanoid snapshots (30 daily / 24 monthly / 10 yearly).
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
          daily = 30;
          monthly = 24;
          yearly = 10;
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
        '';
        serviceConfig.Type = "oneshot";
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
