{ config, ... }:
{
  nixosHosts.sisyphus = {
    unstable = true;
  };

  flake.modules.nixos."hosts/sisyphus".imports = with config.flake.modules.nixos; [
    networking
    bootloader
    docker

    server
    endlessh
    initrd-unlock
    derper
  ];
}
