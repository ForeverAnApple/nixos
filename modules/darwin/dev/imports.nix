{ config, ... }:
{
  flake.modules.darwin.dev.imports = with config.flake.modules.darwin; [
    dev-overlays
    home-manager
    wireguard
    openvpn
  ];
}
