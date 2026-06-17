{ config, ... }:
{
  flake.modules.homeManager.core.imports = with config.flake.modules.homeManager; [
    btop
    nh
    ssh
  ];
}
