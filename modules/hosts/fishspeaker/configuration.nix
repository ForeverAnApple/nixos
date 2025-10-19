{
  flake.modules.nixos."hosts/fishspeaker" = {
    networking.hostName = "fishspeaker";
    system.stateVersion = "25.05";
  };
}
