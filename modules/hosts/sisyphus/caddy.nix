{
  flake.modules.nixos."hosts/sisyphus" = {
    services.caddy.virtualHosts = {
      "headscale.davec.xyz".extraConfig = ''
        reverse_proxy 127.0.0.1:8080
      '';
      "derp.davec.xyz".extraConfig = ''
        reverse_proxy 127.0.0.1:8010
      '';
      # :443 here is open to the internet; only tailnet sources reach anki.
      # MagicDNS owns jura.moe locally, breaking Caddy's TXT propagation
      # check; let LE's own resolver validate at the authoritative NS.
      "anki.jura.moe".extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          propagation_delay 30s
          propagation_timeout -1
        }
        @external not remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
        abort @external
        reverse_proxy 127.0.0.1:27701
      '';
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
