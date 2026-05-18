{ config, ... }:
{
  nixosHosts.swordholder = {
    unstable = true;
  };

  flake.modules.nixos."hosts/swordholder".imports = with config.flake.modules.nixos; [
    networking
    bootloader
    server
    worker
    docker
    caddy
  ];
}
