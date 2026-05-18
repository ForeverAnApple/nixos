{ config, ... }:
{
  flake.modules.homeManager."homes/fishspeaker" = {
    imports = with config.flake.modules.homeManager; [
      desktop
      dev
    ];
  };
}
