# Audiobookshelf serves on localhost; Caddy on the same host terminates
# TLS and reverse-proxies. No tailnet binding, no firewall hole — only
# the local Caddy process can reach :7999.
{
  flake.modules.nixos.audiobookshelf = {
    services.audiobookshelf = {
      enable = true;
      host = "127.0.0.1";
      port = 7999;
      openFirewall = false;
    };
  };
}
