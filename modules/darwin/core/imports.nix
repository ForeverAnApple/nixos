{ config, ... }:
{
  flake.modules.darwin.core.imports = with config.flake.modules.darwin; [
    nix
    substituters
    homebrew
    system-defaults
    fonts
    power-logger
  ];
}
