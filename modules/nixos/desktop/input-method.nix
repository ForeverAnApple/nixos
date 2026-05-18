{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      # Catppuccin Frappé theme for fcitx5 candidate popup
      fcitx5-catppuccin-frappe = pkgs.writeTextDir "share/fcitx5/themes/catppuccin-frappe/theme.conf" ''
        [Metadata]
        Name=Catppuccin Frappé
        Version=1
        Author=Custom
        Description=Catppuccin Frappé
        ScaleWithDPI=True

        [InputPanel]
        NormalColor=#c6d0f5
        HighlightCandidateColor=#232634
        HighlightColor=#8caaee
        HighlightBackgroundColor=#8caaee
        PageButtonAlignment=Last Candidate

        [InputPanel/TextMargin]
        Left=5
        Right=5
        Top=5
        Bottom=5

        [InputPanel/ContentMargin]
        Left=2
        Right=2
        Top=2
        Bottom=2

        [InputPanel/Background]
        Color=#303446
        BorderColor=#51576d
        BorderWidth=2

        [InputPanel/Background/Margin]
        Left=2
        Right=2
        Top=2
        Bottom=2

        [InputPanel/Highlight]
        Color=#8caaee

        [InputPanel/Highlight/Margin]
        Left=5
        Right=5
        Top=5
        Bottom=5

        [Menu]
        NormalColor=#c6d0f5
        HighlightCandidateColor=#232634

        [Menu/Background]
        Color=#303446
        BorderColor=#51576d
        BorderWidth=2

        [Menu/Background/Margin]
        Left=2
        Right=2
        Top=2
        Bottom=2

        [Menu/ContentMargin]
        Left=2
        Right=2
        Top=2
        Bottom=2

        [Menu/Highlight]
        Color=#8caaee

        [Menu/Highlight/Margin]
        Left=5
        Right=5
        Top=5
        Bottom=5

        [Menu/Separator]
        Color=#626880
      '';

    in
    {
      # Drop fcitx5-configtool (~130 MiB KDE deps)
      nixpkgs.overlays = [
        (_: prev: {
          qt6Packages = prev.qt6Packages // {
            fcitx5-with-addons = prev.qt6Packages.fcitx5-with-addons.override {
              withConfigtool = false;
            };
          };
        })
      ];

      # Needed for fcitx5 auto-start on WMs (no DE to handle XDG autostart)
      services.xserver.desktopManager.runXdgAutostartIfNone = true;

      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";

        fcitx5 = {
          waylandFrontend = true;
          ignoreUserConfig = true;

          addons = with pkgs; [
            fcitx5-mozc # Japanese
            qt6Packages.fcitx5-chinese-addons # Chinese (Pinyin)
            fcitx5-catppuccin-frappe
          ];

          # Disable tray icon (waybar custom module replaces it) and cloud
          # pinyin (sends keystrokes to remote servers). Uses fcitx5's own
          # global config — can't remove addon descriptors because the core
          # binary has its install prefix compiled in and ignores symlinkJoin.
          settings.globalOptions = {
            "Behavior/DisabledAddons" = {
              "0" = "notificationitem";
              "1" = "cloudpinyin";
            };
          };

          settings.addons = {
            pinyin.globalSection.CloudPinyinEnabled = "False";
            classicui.globalSection = {
              Theme = "catppuccin-frappe";
              Font = "Hack Nerd Font 10";
            };
          };

          # Declarative input method groups — replaces the GUI config tool
          settings.inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us";
            };
            "Groups/0/Items/0" = {
              Name = "keyboard-us";
              Layout = "";
            };
            "Groups/0/Items/1" = {
              Name = "mozc";
              Layout = "";
            };
            "Groups/0/Items/2" = {
              Name = "pinyin";
              Layout = "";
            };
            GroupOrder = {
              "0" = "Default";
            };
          };
        };
      };
    };
}
