{ config, ... }:
{
  flake.modules.homeManager."homes/catjailer" =
    { lib, ... }:
    {
      imports = with config.flake.modules.homeManager; [
        desktop
        gaming
        dev
        ssh
      ];

      xdg.configFile."hypr/hypridle.conf".source = lib.mkForce ./hypridle.conf;
    };
}
