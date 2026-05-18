{ config, ... }:
{
  flake.modules.darwin.dev.imports = with config.flake.modules.darwin; [
    home-manager
    wireguard
    openvpn
  ];
}
