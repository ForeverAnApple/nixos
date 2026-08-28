{
  flake.modules.nixos.bazarr =
    { config, ... }:
    {
      services.bazarr = {
        enable = true;
        listenPort = 6767;
        openFirewall = false;
      };

      users.users.bazarr.extraGroups = [ "plex" ];

      systemd.services.bazarr.serviceConfig = {
        SupplementaryGroups = [ "plex" ];
        ReadWritePaths = [
          "/var/lib/bazarr"
          "/THICC/Plex"
        ];
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6767 ];
    };
}
