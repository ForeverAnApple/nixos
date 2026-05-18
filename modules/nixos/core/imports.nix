{ config, inputs, ... }:
{
  flake.modules.nixos.core.imports = with config.flake.modules.nixos; [
    inputs.disko.nixosModules.disko

    nix
    users
    keyd
    kmscon
    sops
    substituters
    home-manager
    tailscale
    tmux
    zsh
  ];
}
