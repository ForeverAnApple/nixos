{
  flake.modules.homeManager.desktop = { lib, ... }: {
    # electron apps
    xdg.configFile."electron-flags.conf".text = ''
      --enable-features=UseOzonePlatform
      --ozone-platform-wayland
    '';
  };
}
