{
  flake.modules.nixos.sonarr = {
    services.sonarr = {
      enable = true;
      openFirewall = false;
    };

    users.users.sonarr.extraGroups = [ "plex" ];
    systemd.services.sonarr.serviceConfig.SupplementaryGroups = [ "plex" ];
    systemd.services.sonarr.serviceConfig.ReadWritePaths = [ "/THICC/Plex" ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8989 ];
  };
}
