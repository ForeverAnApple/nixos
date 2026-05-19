{
  flake.modules.nixos."hosts/sisyphus" = {
    services.caddy.virtualHosts = {
      "headscale.davec.xyz".extraConfig = ''
        reverse_proxy 127.0.0.1:8080
      '';
      "derp.davec.xyz".extraConfig = ''
        reverse_proxy 127.0.0.1:8010
      '';
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
