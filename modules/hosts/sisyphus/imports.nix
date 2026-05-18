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
    worker
    endlessh
    initrd-unlock
    derper
  ];
}
