{
  flake.modules.homeManager.desktop =
    { config, lib, ... }:
    {
      # electron apps
      xdg.configFile."electron-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform-wayland
      '';

      # System-wide dark mode
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

      gtk = {
        enable = true;
        gtk4.theme = config.gtk.theme;
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
      };
    };
}
