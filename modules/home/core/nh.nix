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
    in
    {
      home.shellAliases = {
        u = "${nhCmd} switch -u";
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
