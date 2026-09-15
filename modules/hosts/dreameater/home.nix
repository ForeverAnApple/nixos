{ config, ... }:
{
  flake.modules.homeManager."homes/dreameater" = {
    imports = with config.flake.modules.homeManager; [
      dev
    ];
  };
}
