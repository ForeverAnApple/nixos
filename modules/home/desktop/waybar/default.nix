{
  flake.modules.homeManager.waybar =
    { lib, ... }:
    {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
      };
      xdg.configFile = {
        "waybar/config.jsonc".source = ./config.jsonc;
        "waybar/style.css".source = ./style.css;
      };
    };
}
