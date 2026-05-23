{ config, ... }:
{
  flake.modules.homeManager."homes/swordholder" = {
    imports = with config.flake.modules.homeManager; [
      dev
    ];
  };
}
