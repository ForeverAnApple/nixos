{
  flake.modules.nixos."hosts/swordholder" = {
    networking.hostName = "swordholder";

    # Do NOT change after THICC has been imported here — ZFS will refuse to mount.
    networking.hostId = "5d11a3a1";

    system.stateVersion = "25.11";

    sops.defaultSopsFile = ./secrets.yaml;
  };
}
