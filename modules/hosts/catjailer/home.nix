{ config, ... }:
{
  flake.modules.homeManager."homes/catjailer" =
    { lib, pkgs, ... }:
    {
      imports = with config.flake.modules.homeManager; [
        desktop
        gaming
        dev
        ssh
        unit-alert
      ];

      xdg.configFile."hypr/hypridle.conf".source = lib.mkForce ./hypridle.conf;

      home.sessionVariables.CARGO_TARGET_DIR = lib.mkForce "/mnt/theta-beef/cargo-target";
      programs.zsh.envExtra = lib.mkAfter ''
        export CARGO_TARGET_DIR=/mnt/theta-beef/cargo-target
      '';

      home.activation.cargoTarget = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.util-linux}/bin/mountpoint -q /mnt/theta-beef || {
          echo "Cargo target disk is not mounted" >&2
          exit 1
        }
        old="$HOME/.cache/cargo-target"
        target=/mnt/theta-beef/cargo-target
        if [ -e "$old" ] || [ -L "$old" ]; then
          if [ ! -L "$old" ] || [ "$(readlink "$old")" != "$target" ]; then
            echo "Refusing to replace existing Cargo target: $old" >&2
            exit 1
          fi
        fi
        run mkdir -p "$target" "$HOME/.cache"
        if [ ! -L "$old" ]; then
          run ln -s "$target" "$old"
        fi
      '';
    };
}
