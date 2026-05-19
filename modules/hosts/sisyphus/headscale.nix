{
  flake.modules.nixos."hosts/sisyphus".services.headscale.settings = {
    server_url = "https://headscale.davec.xyz";

    prefixes = {
      v4 = "100.64.0.0/10";
      v6 = "fd7a:115c:a1e0::/48";
    };

    dns = {
      magic_dns = true;
      base_domain = "ts.davec.xyz";
      override_local_dns = true;
      nameservers.global = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };

    derp = {
      urls = [ "https://controlplane.tailscale.com/derpmap/default" ];
      auto_update_enabled = true;
      update_frequency = "24h";
    };
  };
}
