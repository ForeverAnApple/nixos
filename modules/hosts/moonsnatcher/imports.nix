{ config, ... }:
{
  nixosHosts.moonsnatcher = { };

  flake.modules.nixos."hosts/moonsnatcher".imports = with config.flake.modules.nixos; [
    development
  ];
}
