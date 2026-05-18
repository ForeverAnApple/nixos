{ config, inputs, ... }:
{
  flake.modules.nixos.dev.imports = with config.flake.modules.nixos; [
    users
    dev-overlays
    wireguard
    openvpn
  ];
}
