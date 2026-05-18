{
  flake.modules.nixos."hosts/sisyphus" = {
    networking.hostName = "sisyphus";
    networking.hostId = "5a1f9c7b";
    system.stateVersion = "25.11";

    services.qemuGuest.enable = true;

    sops.defaultSopsFile = ./secrets.yaml;
  };
}
