{ config, ... }:
{
  flake.modules.darwin.workstation.imports = with config.flake.modules.darwin; [
    dev
  ];
}
