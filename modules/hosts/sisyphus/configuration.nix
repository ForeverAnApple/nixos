{
  flake.modules.nixos."hosts/sisyphus" =
    { config, ... }:
    {
      networking.hostName = "sisyphus";
      networking.hostId = "5a1f9c7b";
      system.stateVersion = "25.11";

      services.qemuGuest.enable = true;

      sops.defaultSopsFile = ./secrets.yaml;
      sops.secrets."users/faa/hashedPassword".neededForUsers = true;

      users.users.faa.hashedPasswordFile =
        config.sops.secrets."users/faa/hashedPassword".path;
    };
}
