{
  flake.modules.nixos.derper = {
    services.tailscale.derper = {
      enable = true;
      domain = "derp.davec.xyz";

      # sisyphus runs tailscaled itself, so derper can ask it whether a
      # connecting client is actually a member of the tailnet. Without
      # this the relay is open to anyone on the internet.
      verifyClients = true;

      # Opens UDP 3478 (STUN). The module leaves TCP 80/443 to nginx, but
      # services.nginx doesn't touch the firewall on its own — see below.
      openFirewall = true;
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # Public-issued cert for the derper vhost. ACME http-01 needs port 80
    # reachable from the internet and an A/AAAA record for derp.davec.xyz
    # pointing at sisyphus's public IP.
    security.acme = {
      acceptTerms = true;
      defaults.email = "kinbd8@gmail.com";
    };

    services.nginx.virtualHosts."derp.davec.xyz" = {
      enableACME = true;
    };
  };
}
