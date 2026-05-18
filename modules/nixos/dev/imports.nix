{ config, inputs, ... }:
{
  flake.modules.nixos.dev.imports = with config.flake.modules.nixos; [
    dev-overlays
    wireguard
    openvpn
  ];
}
