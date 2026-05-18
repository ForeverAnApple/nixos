{ config, inputs, ... }:
{
  flake.modules.nixos.dev.imports = with config.flake.modules.nixos; [
    human-user
    dev-overlays
    wireguard
    openvpn
  ];
}
