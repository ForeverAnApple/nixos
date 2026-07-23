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
      systemPath = if isDarwin then ":/usr/bin:/bin:/usr/sbin:/sbin" else ":/run/wrappers/bin";
      nhUp = pkgs.writeShellScriptBin "nh-up" ''
        export NH_CMD="${nhCmd}"
        export PATH="${
          lib.makeBinPath [
            pkgs.gnused
            pkgs.gnugrep
            pkgs.coreutils
            pkgs.diffutils
            pkgs.git
            pkgs.jq
            pkgs.nh
            pkgs.nix
            pkgs.perl
          ]
        }${systemPath}"
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
