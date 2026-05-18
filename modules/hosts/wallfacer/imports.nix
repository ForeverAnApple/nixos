{ config, ... }:
{
  darwinHosts.wallfacer = { };

  flake.modules.darwin."hosts/wallfacer".imports = with config.flake.modules.darwin; [
    workstation
  ];
}
