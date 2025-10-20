{
  flake.modules.nixos.desktop = {
    services = {
      gnome.gnome-keyring.enable = true;
    };
  };
}
