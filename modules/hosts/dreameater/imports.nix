{ config, ... }:
{
  nixosHosts.dreameater = { };

  flake.modules.nixos."hosts/dreameater".imports = with config.flake.modules.nixos; [
    service

    dev
    nix-ld
    envfs
  ];
}
