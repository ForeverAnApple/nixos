{ config, ... }:
{
  nixosHosts.fishspeaker = { };

  flake.modules.nixos."hosts/fishspeaker".imports = with config.flake.modules.nixos; [
    workstation
    laptop
  ];
}
