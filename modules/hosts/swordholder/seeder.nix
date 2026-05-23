{
  flake.modules.nixos."hosts/swordholder" =
    { pkgs, ... }:
    {
      systemd.tmpfiles.rules = [
        "d /var/lib/qbittorrent 0755 faa users -"
      ];

      users.users.faa.subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      users.users.faa.subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
        {
          startGid = 193;
          count = 1;
        }
      ];

      systemd.user.services.seeder = {
        description = "seeder";
        wantedBy = [ "default.target" ];
        after = [
          "default.target"
          "gluetun.service"
        ];
        requires = [ "gluetun.service" ];
        unitConfig.ConditionUser = "faa";
        serviceConfig = {
          Type = "exec";
          Environment = "DOCKER_HOST=unix://%t/docker.sock";
          ExecStartPre = [
            "${pkgs.bash}/bin/bash -c 'until [ \"$(${pkgs.docker}/bin/docker inspect -f {{.State.Health.Status}} gluetun 2>/dev/null)\" = \"healthy\" ]; do sleep 2; done'"
            "-${pkgs.docker}/bin/docker rm -f seeder"
          ];
          ExecStart = ''
            ${pkgs.docker}/bin/docker run \
              --name seeder \
              --network=container:gluetun \
              -e PUID=0 \
              -e PGID=65537 \
              -e TZ=America/Chicago \
              -e WEBUI_PORT=8080 \
              -v /var/lib/qbittorrent:/config \
              -v /media:/mnt/Plex \
              -v /THICC/THICC/Torrents:/mnt/Torrents \
              lscr.io/linuxserver/qbittorrent:5.2.0
          '';
          ExecStop = "${pkgs.docker}/bin/docker stop seeder";
          Restart = "on-failure";
          RestartSec = "30";
        };
      };
    };
}
