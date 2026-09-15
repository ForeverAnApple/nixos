{
  flake.modules.nixos."hosts/dreameater" = {
    networking.networkmanager.ensureProfiles.profiles.eth0 = {
      connection = {
        id = "eth0";
        type = "ethernet";
        interface-name = "eth0";
        autoconnect = true;
        autoconnect-priority = 100;
      };
      ipv4 = {
        method = "manual";
        address1 = "152.53.83.187/22";
        gateway = "152.53.80.1";
        dns = "46.38.252.230;46.38.225.230";
      };
      ipv6 = {
        method = "manual";
        address1 = "2a0a:4cc0:2000:33a8:58e1:caff:fed7:2d13/64";
        gateway = "fe80::1";
        dns = "2a03:4000:0:1::e1e6";
      };
    };

    # NM would otherwise auto-activate a DHCP fallback before the
    # profile above is written, and never switch over to it.
    networking.networkmanager.settings.main.no-auto-default = "*";

    networking.firewall.allowedTCPPorts = [
      80
      443
      22022
    ];
  };
}
