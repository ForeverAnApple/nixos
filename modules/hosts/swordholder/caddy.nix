{
  flake.modules.nixos."hosts/swordholder" = {
    services.caddy.virtualHosts = {
      # MagicDNS owns jura.moe locally and NXDOMAINs the SOA probe, so
      # certmagic's zone detection walks up to the TLD and renewal fails;
      # resolve via public DNS (docs/acme.md).
      "*.jura.moe".extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          resolvers 1.1.1.1
        }

        handle {
          respond "no route for {host}" 404
        }
      '';

      "qbit.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:8080
      '';

      "plex.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:32400
      '';

      "abs.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:7999 {
          header_up Host {host}
        }
      '';

      "ha.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:8123 {
          header_up Host {host}
        }
      '';

      "immich.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:2283
      '';

      "git.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:3000
      '';

      "paperless.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:28981
      '';

      "dash.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:8082
      '';

      "manga.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:25600
      '';

      "suwayomi.jura.moe".extraConfig = ''
        reverse_proxy 127.0.0.1:4567
      '';
    };
  };
}
