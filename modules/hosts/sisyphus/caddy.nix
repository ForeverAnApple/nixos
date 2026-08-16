{
  flake.modules.nixos."hosts/sisyphus" = {
    services.caddy.virtualHosts = {
      "headscale.davec.xyz".extraConfig = ''
        reverse_proxy 127.0.0.1:8080
      '';
      "derp.davec.xyz".extraConfig = ''
        reverse_proxy 127.0.0.1:8010
      '';
      # Deliberately internet-facing; the sync server has no auth rate
      # limiting, so the access log feeds a fail2ban jail below.
      # MagicDNS owns jura.moe locally and NXDOMAINs SOA probes, breaking
      # certmagic zone detection and TXT propagation checks; resolve via
      # public DNS (docs/acme.md).
      # Caddy's default read_buffer truncates media download streams
      # mid-body; clients see "stream failure (code=303)".
      "anki.jura.moe".extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          resolvers 1.1.1.1
          propagation_delay 30s
          propagation_timeout -1
        }
        log {
          output file /var/log/caddy/access-anki.jura.moe.log
        }
        reverse_proxy 127.0.0.1:27701 {
          transport http {
            read_buffer 512k
          }
        }
      '';
    };

    environment.etc."fail2ban/filter.d/anki-sync.conf".text = ''
      [Definition]
      failregex = ^.*"remote_ip":"<HOST>".*"uri":"/sync/hostKey".*"status":40[13].*$
      datepattern = LongEpoch
    '';
    services.fail2ban.jails.anki-sync.settings = {
      enabled = true;
      filter = "anki-sync";
      # NixOS defaults fail2ban to the journal backend; the caddy access
      # log is a file.
      backend = "auto";
      logpath = "/var/log/caddy/access-anki.jura.moe.log";
      maxretry = 5;
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
