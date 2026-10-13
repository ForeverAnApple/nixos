{
  flake.modules.homeManager.yazi =
    { pkgs, lib, ... }:
    let
      # Chromium/Electron only paste image/png from the clipboard.
      copyFile = pkgs.writeShellApplication {
        name = "copy-file";
        runtimeInputs = [
          pkgs.file
          pkgs.imagemagick
          pkgs.wl-clipboard
        ];
        text = ''
          case "$(file -b --mime-type "$1")" in
            image/png) wl-copy -t image/png < "$1" ;;
            image/*) magick "$1[0]" -define png:compression-level=1 png:- | wl-copy -t image/png ;;
            *) wl-copy < "$1" ;;
          esac
        '';
      };
    in
    {
      home.packages = [ copyFile ];

      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";
        keymap.mgr.prepend_keymap = [
          {
            on = [ "c" "i" ];
            run = "shell -- ${lib.getExe copyFile} %h";
            desc = "Copy file contents";
          }
        ];
      };
    };
}
