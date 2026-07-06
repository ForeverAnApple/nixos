{
  flake.modules.nixos."hosts/sisyphus" =
    let
      derpMap = builtins.toFile "derp-map.yaml" ''
        regions:
          900:
            regionid: 900
            regioncode: davec
            regionname: davec.xyz
            nodes:
              - name: davec
                regionid: 900
                hostname: derp.davec.xyz
                stunport: 3478
      '';
    in
    {
      services.headscale.settings = {
        server_url = "https://headscale.davec.xyz";

        policy = {
          mode = "file";
          path = "${./headscale-policy.hujson}";
        };

        prefixes = {
          v4 = "100.64.0.0/10";
          v6 = "fd7a:115c:a1e0::/48";
        };

        dns = {
          magic_dns = true;
          base_domain = "jura.moe";
          override_local_dns = true;
          nameservers.global = [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
          extra_records = [
            {
              name = "qbit.jura.moe";
              type = "A";
              value = "100.64.0.8";
            }
            {
              name = "plex.jura.moe";
              type = "A";
              value = "100.64.0.8";
            }
            {
              name = "abs.jura.moe";
              type = "A";
              value = "100.64.0.8";
            }
            {
              name = "ha.jura.moe";
              type = "A";
              value = "100.64.0.8";
            }
            {
              name = "immich.jura.moe";
              type = "A";
              value = "100.64.0.8";
            }
            {
              name = "anki.jura.moe";
              type = "A";
              value = "100.64.0.5";
            }
          ];
        };

        derp = {
          urls = [ "https://controlplane.tailscale.com/derpmap/default" ];
          paths = [ "${derpMap}" ];
          auto_update_enabled = true;
          update_frequency = "24h";
        };
      };
    };
}
