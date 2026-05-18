{
  flake.modules.nixos.fail2ban = {
    services.fail2ban = {
      enable = true;

      maxretry = 3;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        multipliers = "2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = true;
      };

      # Don't ban ourselves: loopback, RFC1918 LAN, and the tailnet.
      ignoreIP = [
        "127.0.0.0/8"
        "::1"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "100.64.0.0/10"
      ];
    };
  };
}
