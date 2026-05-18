# Aggregator for home-manager modules that only make sense on macOS
# (terminal-notifier, mas, anything pulling darwin.* packages, etc.).
# Auto-imported by modules/darwin/dev/home-manager.nix on every Darwin host,
# so leaves under modules/home/darwin/ never need a `pkgs.stdenv.isDarwin`
# guard — the platform routing lives entirely in the wiring layer.
{ config, ... }:
{
  flake.modules.homeManager.darwin.imports = with config.flake.modules.homeManager; [
    darwin-packages
    skhd
    aerospace
    power-logger
  ];
}
