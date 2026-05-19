{ config, ... }:
{
  nixosHosts.sisyphus = { };

  flake.modules.nixos."hosts/sisyphus".imports = with config.flake.modules.nixos; [
    service

    endlessh
    initrd-unlock
    derper
    caddy
    headscale
  ];
}
