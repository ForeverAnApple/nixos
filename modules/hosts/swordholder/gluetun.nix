{
  flake.modules.nixos."hosts/swordholder" =
    { config, pkgs, ... }:
    {
      sops.secrets."gluetun/env" = {
        owner = "faa";
        group = "users";
        mode = "0400";
      };

      systemd.user.services.gluetun = {
        description = "gluetun";
        wantedBy = [ "default.target" ];
        after = [ "default.target" ];
        restartTriggers = [ ./secrets.yaml ];
        unitConfig = {
          ConditionUser = "faa";
        };
        serviceConfig = {
          Type = "exec";
          Environment = "DOCKER_HOST=unix://%t/docker.sock";
          ExecStartPre = [
            "-${pkgs.docker}/bin/docker rm -f gluetun"
          ];
          ExecStart = ''
            ${pkgs.docker}/bin/docker run \
              --name gluetun \
              --cap-add=NET_ADMIN \
              --device=/dev/net/tun:/dev/net/tun \
              --env-file ${config.sops.secrets."gluetun/env".path} \
              -e VPN_SERVICE_PROVIDER=surfshark \
              -e VPN_TYPE=wireguard \
              -e SERVER_COUNTRIES="Japan" \
              -e TZ=America/Chicago \
              -p 127.0.0.1:8080:8080/tcp \
              qmcgaw/gluetun:latest
          '';
          ExecStop = "${pkgs.docker}/bin/docker stop gluetun";
          Restart = "on-failure";
          RestartSec = "30";
        };
      };
    };
}
