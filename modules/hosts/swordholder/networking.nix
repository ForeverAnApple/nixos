{
  flake.modules.nixos."hosts/swordholder" = {
    networking.firewall.interfaces.enp4s0.allowedTCPPorts = [ 22022 ];

    networking.networkmanager.ensureProfiles.profiles."lan-static" = {
      connection = {
        id = "lan-static";
        type = "ethernet";
        autoconnect = true;
        autoconnect-priority = 100;
      };
      "802-3-ethernet" = {
        mac-address = "D4:3D:7E:E0:44:BB";
      };
      ipv4 = {
        method = "manual";
        address1 = "192.168.0.16/24,192.168.0.1";
        dns = "1.1.1.1;8.8.8.8";
      };
      ipv6.method = "auto";
    };
  };
}
