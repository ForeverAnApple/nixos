{
  flake.modules.nixos.networking =
    { ... }:
    {
      networking = {
        networkmanager.enable = true;
      };

      # Stub resolver so /etc/resolv.conf is populated independent of any
      # later DNS-managing service (tailscale, vpn). NixOS auto-configures
      # NetworkManager with dns=systemd-resolved when this is enabled.
      services.resolved.enable = true;
    };
}
