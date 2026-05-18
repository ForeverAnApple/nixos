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
    };
  };
}
