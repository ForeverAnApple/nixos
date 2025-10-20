{ config, ... }:
{
  flake.modules.nixos.desktop.imports = with config.flake.modules.nixos; [
    niri
    tuigreet
    bluetooth
  ];
}
