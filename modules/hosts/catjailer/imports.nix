{ config, ... }:
{
  nixosHosts.catjailer = {
    unstable = true;
  };

  flake.modules.nixos."hosts/catjailer".imports = with config.flake.modules.nixos; [
    networking
    bootloader
    docker
    nix-ld
    envfs
    nvidia
    gaming
    obs

    sshd
    fail2ban
    caddy
    home-assistant
    audiobookshelf

    dev
    desktop
  ];
}
