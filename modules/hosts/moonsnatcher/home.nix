{ config, ... }:
{
  flake.modules.homeManager."homes/moonsnatcher".imports = with config.flake.modules.homeManager; [
    dev
  ];
}
