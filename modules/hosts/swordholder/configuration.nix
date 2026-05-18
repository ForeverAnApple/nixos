{
  flake.modules.nixos."hosts/swordholder" =
    { config, ... }:
    {
      networking.hostName = "swordholder";

      # Do NOT change after THICC has been imported here — ZFS will refuse to mount.
      networking.hostId = "5d11a3a1";

      system.stateVersion = "25.11";

      sops.defaultSopsFile = ./secrets.yaml;
      sops.secrets."users/faa/hashedPassword".neededForUsers = true;
      users.users.faa.hashedPasswordFile =
        config.sops.secrets."users/faa/hashedPassword".path;

      security.sudo.extraRules = [
        {
          users = [ "faa" ];
          commands = [
            {
              command = "ALL";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
        }
      ];
    };
}
