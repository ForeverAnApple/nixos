{
  flake.modules.nixos.nix-ld =
    { pkgs, ... }:
    {
      # I got tired of facing NixOS issues
      # Let's be more pragmatic and try to run binaries sometimes
      # at the cost of sweeping bugs under the rug.
      programs.nix-ld = {
        enable = true;
        # put whatever libraries you think you might need
        # nix-ld includes a strong sane-default as well
        # in addition to these
        libraries = with pkgs; [
          stdenv.cc.cc.lib
        ];
      };
    };
}
