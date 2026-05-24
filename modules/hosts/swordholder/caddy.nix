{
  flake.modules.nixos."hosts/swordholder" = {
    services.caddy.virtualHosts = {
      "*.jura.moe".extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
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
    };
  };
}
