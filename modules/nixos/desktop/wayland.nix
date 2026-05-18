{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      users.users.faa.extraGroups = [ "video" ];

      security.polkit.enable = true;

      fonts.packages = with pkgs; [
        # Viewing pleasure
        noto-fonts
        nerd-fonts.hack
        nerd-fonts.iosevka
        montserrat

        # Symbols and glyphs
        nerd-fonts.symbols-only
        powerline-symbols
        material-design-icons

        # other langs
        noto-fonts-cjk-sans
      ];

      fonts.fontconfig.enable = true;

      services = {
        libinput.enable = true;
        xserver.xkb = {
          layout = "us";
          variant = "";
        };

        # GTK theme config
        dbus = {
          enable = true;
          packages = [ pkgs.dconf ];
        };
      };

      xdg.portal = {
        enable = true;
        config = {
          common.default = [
            "gtk"
            "gnome"
          ];
        };
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        xdgOpenUsePortal = true;
      };
    };
}
