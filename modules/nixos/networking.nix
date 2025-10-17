{
  flake.modules.nixos.networking = { ... }: {
    networking = {
      hostName = "fishspeaker";
      networkmanager.enable = true;
    };
  };
}
