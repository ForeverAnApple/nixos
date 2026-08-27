{
  flake.modules.nixos.komga = {
    services.komga = {
      enable = true;
      openFirewall = false;
      settings.server = {
        address = "127.0.0.1";
        port = 25600;
      };
    };
  };
}
