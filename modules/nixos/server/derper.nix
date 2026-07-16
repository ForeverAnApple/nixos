{
  flake.modules.nixos.derper =
    { pkgs, ... }:
    {
      systemd.services.derper = {
        description = "Tailscale DERP relay";
        after = [
          "network.target"
          "tailscaled.service"
        ];
        wants = [ "tailscaled.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = ''
            ${pkgs.tailscale.derper}/bin/derper \
              -a=:8010 \
              -http-port=-1 \
              -hostname=derp.davec.xyz \
              -c=/var/lib/derper/derper.key \
              -stun \
              -stun-port=3478 \
              -verify-client-url=https://headscale.davec.xyz/verify \
              -verify-client-url-fail-open=false
          '';
          DynamicUser = true;
          StateDirectory = "derper";
          Restart = "on-failure";
          RestartSec = "5s";

          CapabilityBoundingSet = [ "" ];
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service" ];
        };
      };

      networking.firewall.allowedUDPPorts = [ 3478 ];
    };
}
