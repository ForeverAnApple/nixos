{
  flake.modules.nixos."hosts/swordholder" = {
    services.journald.settings.Journal.SystemMaxUse = "1G";

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    nix.settings.auto-optimise-store = true;
  };
}
