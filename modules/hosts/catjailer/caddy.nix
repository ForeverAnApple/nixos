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
        }
      '';
    in
    {
      services.caddy.virtualHosts = {
        "catjailer.jura.moe".extraConfig = ''
          ${tlsBlock}
          respond "catjailer caddy ok"
        '';
      };
    };
}
