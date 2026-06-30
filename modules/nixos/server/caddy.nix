{
  flake.modules.nixos.caddy =
    { config, pkgs, ... }:
    {
      sops.secrets."cloudflare/api_token" = {
        owner = "caddy";
        group = "caddy";
      };

      # sops decrypts the raw token at runtime and renders it into KEY=value
      # form so systemd's EnvironmentFile can hand it to caddy as
      # $CLOUDFLARE_API_TOKEN. Storing it raw in the encrypted yaml keeps the
      # secret value clean of env-file framing.
      sops.templates."caddy.env" = {
        content = "CLOUDFLARE_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}\n";
        owner = "caddy";
        group = "caddy";
      };

      services.caddy = {
        enable = true;

        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
          hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
        };

        # All certs issue via Cloudflare DNS-01. disable_redirects keeps
        # caddy from binding :80 just to serve HTTP→HTTPS bounces — under
        # tailnet-only DNS that listener is pure surface, no callers.
        globalConfig = ''
          acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          auto_https disable_redirects
        '';
      };

      systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy.env".path;

      # tailscale0 is in trustedInterfaces; the explicit allow keeps :443
      # reachable from tailnet even after we tighten the trust model later.
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 443 ];
    };
}
