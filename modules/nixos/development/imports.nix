{ config, ... }:
{
  flake.modules.nixos.development.imports = with config.flake.modules.nixos; [
    service
    dev
    nix-ld
    envfs
  ];
}
