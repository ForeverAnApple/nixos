{ config, ... }:
{
  flake.modules.nixos.workstation.imports = with config.flake.modules.nixos; [
    networking
    bootloader
    docker
    nix-ld
    envfs

    dev
    desktop
  ];
}
