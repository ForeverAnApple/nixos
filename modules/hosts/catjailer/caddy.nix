{
  flake.modules.nixos."hosts/catjailer" =
    let
      # Local DNS interception breaks Caddy's TXT propagation check; let
      # LE's own resolver validate at the authoritative NS instead.
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
