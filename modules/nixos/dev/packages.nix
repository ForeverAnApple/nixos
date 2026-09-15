{
  flake.modules.nixos.dev =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # utils
        libgcc
        lsof
        jq
        nixfmt
        nodejs
        bun
        python3
        uv
        rustc
        cargo
        rustfmt
        clippy

        # this seems to be needed by neovim, maybe mason or treesetter
        stdenv.cc
        gnumake
        tree-sitter
      ];

      programs = {
      };
    };
}
