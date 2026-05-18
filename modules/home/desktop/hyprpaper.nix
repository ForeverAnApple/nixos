{
  flake.modules.homeManager.hyprpaper =
    { lib, config, ... }:
    {
      services.hyprpaper = {
        enable = true;
        settings = {
          wallpaper = [
            {
              monitor = "";
              path = "${config.home.homeDirectory}/Pictures/wallpaper";
              fit_mode = "cover";
            }
          ];
        };
      };
    };
}
