{
  flake.modules.nixos.printing = {
    services = {
      printing.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
    systemd.services.cups-browsed.enable = false;
  };
}
