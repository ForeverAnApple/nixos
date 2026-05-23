{ config, ... }:
{
  flake.modules.nixos.service.imports = with config.flake.modules.nixos; [
    networking
    bootloader
    docker

    sshd
    fail2ban
  ];
}
