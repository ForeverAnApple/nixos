{
  flake.modules.nixos.radarr = {
    services.radarr = {
      enable = true;
      openFirewall = false;
    };

    users.users.radarr.extraGroups = [ "plex" ];
    systemd.services.radarr.serviceConfig.SupplementaryGroups = [ "plex" ];
    systemd.services.radarr.serviceConfig.ReadWritePaths = [ "/THICC/Plex" ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 7878 ];
  };
}
