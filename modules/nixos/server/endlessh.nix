{
  # SSH tarpit on :22 — drips a never-ending fake banner at scanners that
  # come knocking on the well-known port. Real sshd lives on a non-22 port
  # behind the firewall (tailnet-only via the trusted iface).
  #
  # Using endlessh-go (Go reimpl) over the C original for its Prometheus
  # exporter — bound to localhost so it's not exposed publicly until we
  # actually wire up a scraper.
  flake.modules.nixos.endlessh = {
    services.endlessh-go = {
      enable = true;
      port = 22;
      openFirewall = true;

      prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 2112;
      };

      # Geohash scanner IPs so the Prometheus exporter emits a country label.
      # ip-api is the free HTTP supplier (45 req/min/IP) — no DB to manage.
      extraOptions = [ "-geoip_supplier=ip-api" ];
    };
  };
}
