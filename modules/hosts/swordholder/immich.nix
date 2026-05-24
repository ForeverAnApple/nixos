{
  flake.modules.nixos."hosts/swordholder" = {
    services.immich.mediaLocation = "/THICC/Immich";

    systemd.tmpfiles.rules = [
      "d /THICC/Immich 0700 immich immich -"
    ];
  };
}
