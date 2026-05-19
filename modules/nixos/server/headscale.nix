{
  flake.modules.nixos.headscale =
    { pkgs, ... }:
    {
      services.headscale = {
        enable = true;
        address = "127.0.0.1";
        port = 8080;

        settings = {
          database = {
            type = "sqlite";
            sqlite.path = "/var/lib/headscale/db.sqlite";
          };

          metrics_listen_addr = "127.0.0.1:9090";

          log.level = "info";
        };
      };

      systemd.services.headscale.serviceConfig.ExecStartPre = [
        "${pkgs.coreutils}/bin/test -f /var/lib/headscale/db.sqlite"
      ];
    };
}
