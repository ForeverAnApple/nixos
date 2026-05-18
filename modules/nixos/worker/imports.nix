{ config, ... }:
{
  flake.modules.nixos.worker.imports = with config.flake.modules.nixos; [
    deploy-user
  ];
}
