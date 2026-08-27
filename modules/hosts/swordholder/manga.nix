{
  flake.modules.nixos."hosts/swordholder" = {
    services.suwayomi-server.settings.server.downloadsPath = "/THICC/Manga";

    systemd.tmpfiles.rules = [
      "d /THICC/Manga 0755 suwayomi suwayomi -"
    ];
  };
}
