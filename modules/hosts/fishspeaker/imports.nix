{ config, ... }:
{
  nixosHosts.fishspeaker = {
    unstable = true;
  };

  flake.modules.nixos."hosts/fishspeaker".imports = with config.flake.modules.nixos; [
    networking
    bootloader

    dev
  ];
}
