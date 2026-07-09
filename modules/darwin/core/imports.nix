{ config, ... }:
{
  flake.modules.darwin.core.imports = with config.flake.modules.darwin; [
    nix
    homebrew
    system-defaults
    fonts
    power-logger
  ];
}
