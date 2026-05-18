{ config, ... }:
{
  nixosHosts.catjailer = { };

  flake.modules.nixos."hosts/catjailer".imports = with config.flake.modules.nixos; [
    workstation

    nvidia
    gaming
    obs

    sshd
    fail2ban
    caddy
    home-assistant
    audiobookshelf
  ];
}
