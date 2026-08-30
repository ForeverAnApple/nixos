{
  flake.modules.nixos."hosts/catjailer" =
    let
      # Skip Caddy's own TXT propagation check; LE validates at the
      # authoritative NS regardless.
      tlsBlock = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          propagation_delay 30s
          propagation_timeout -1
          resolvers 1.1.1.1 1.0.0.1
        }
      '';
    in
    {
      services.caddy.virtualHosts = {
        "catjailer.jura.moe".extraConfig = ''
          ${tlsBlock}
          @tailnet remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
          handle @tailnet {
            reverse_proxy 127.0.0.1:8088
          }
          respond "tailnet only" 403
        '';
        "notebook.jura.moe".extraConfig = ''
          ${tlsBlock}
          reverse_proxy 127.0.0.1:3000
        '';
      };
    };
}
