{ config, ... }:
{
  flake.modules.homeManager."homes/wallfacer" =
    { lib, ... }:
    {
      home.username = "daaaa";
      home.homeDirectory = "/Users/daaaa";

      imports = with config.flake.modules.homeManager; [
        dev
        kitty
      ];

      # The shared kitty module sets font_size = 10, which looks fine on the
      # Linux Hi-DPI hosts but is uncomfortably small on macOS Retina. Bump
      # it just for this host (mkForce because the shared module sets a
      # plain value at the same priority).
      programs.kitty.settings.font_size = lib.mkForce 14;
    };
}
