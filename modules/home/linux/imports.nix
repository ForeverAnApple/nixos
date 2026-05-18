# Aggregator for home-manager modules that only make sense on Linux
# (systemd.user.*, Wayland/X11 daemons that need PID 1 supervision, etc.).
# Auto-imported by modules/nixos/dev/home-manager.nix on every NixOS host,
# so leaves under modules/home/linux/ never need a `pkgs.stdenv.isLinux`
# guard — the platform routing lives entirely in the wiring layer.
{ config, ... }:
{
  flake.modules.homeManager.linux.imports = with config.flake.modules.homeManager; [
    process-reaper
  ];
}
