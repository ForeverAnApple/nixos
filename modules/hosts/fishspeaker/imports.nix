{ config, ... }:
{
  nixosHosts.fishspeaker = {
    unstable = true;
  };

  flake.modules.nixos."nixosConfigurations/fishspeaker".imports = with config.flake.modules.nixos; [
    networking
    bootloader
  ];
}
