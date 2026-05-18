{
  flake.modules.homeManager.hyprlock =
    {
      lib,
      pkgs,
      ...
    }:
    {
      # hyprlock is a screen locker for Wayland
      # This module adds the hyprlock package and configures it with
      # a blurred screenshot background, clock widget, and password input
      # The Inter font is required by hyprlock.conf
      home.packages = with pkgs; [
        hyprlock
        inter
      ];

      xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
      xdg.configFile."hypr/hyprlock.png".source = ./hyprlock.png;
    };
}
