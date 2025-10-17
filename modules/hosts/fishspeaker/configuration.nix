{
  flake.modules.nixos."nixosConfigurations/fishspeaker" = {
    networking.hostName = "fishspeaker";
    system.stateVersion = "25.11";
  };
}
