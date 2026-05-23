{ config, ... }:
{
  flake.modules.homeManager."homes/sisyphus" = {
    imports = with config.flake.modules.homeManager; [
      dev
    ];
  };
}
