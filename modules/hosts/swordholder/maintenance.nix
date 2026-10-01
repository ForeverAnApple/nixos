{
  flake.modules.nixos."hosts/swordholder" = {
    services.journald.settings.Journal.SystemMaxUse = "1G";
  };
}
