{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;

      # Self-hosted headscale coordinator. Bake the URL in so reinstalls
      # don't drop the node back to login.tailscale.com.
      extraUpFlags = [ "--login-server=https://headscale.davec.xyz" ];

      # Let faa drive `tailscale set` and `tailscale debug` without sudo.
      # Otherwise runtime knob-twiddling (force-prefer-derp, break-derp-conns)
      # needs a password round-trip every time, which is the difference
      # between fixing a flap in 5 seconds vs 5 minutes.
      extraSetFlags = [ "--operator=faa" ];
    };

    # Trust the tailnet so services with ephemeral ports (HomeKit Bridge,
    # mDNS responders, etc.) are reachable from other nodes without having
    # to open each port system-wide.
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
