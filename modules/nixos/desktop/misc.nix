{
  flake.modules.nixos.desktop = {
    services = {
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
    };
  };
}
