{
  flake.modules.homeManager.nh =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      inherit (pkgs.stdenv) isDarwin;
      nhCmd = if isDarwin then "nh darwin" else "nh os";
      nhUp = pkgs.writeShellScriptBin "nh-up" ''
        export NH_CMD="${nhCmd}"
        export PATH="${
          lib.makeBinPath [
            pkgs.gnused
            pkgs.gnugrep
            pkgs.coreutils
            pkgs.git
          ]
        }:$PATH"
        exec ${pkgs.bash}/bin/bash ${./nh-up.sh} "$@"
      '';
    in
    {
      home.packages = [ nhUp ];

      home.shellAliases = {
        u = "nh-up";
        t = "${nhCmd} test";
        nrs = "${nhCmd} switch";
        nru = "nix run \"$HOME/nixos\"#update";
        lg = "lazygit";
        oc = "opencode";
      };
      programs.nh = {
        enable = true;

        flake = lib.mkDefault "${config.home.homeDirectory}/nixos";

        clean = {
          enable = true;
          dates = "daily";
          extraArgs = "--keep 6 --keep-since 8d";
        };
      };
    };
}
