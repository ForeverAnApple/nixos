{
  flake.modules.nixos."hosts/swordholder" =
    { ... }:
    {
      services.sanoid = {
        enable = true;

        templates.media = {
          hourly = 36;
          daily = 30;
          monthly = 3;
          yearly = 0;
          autosnap = true;
          autoprune = true;
        };

        datasets."THICC" = {
          useTemplate = [ "media" ];
          recursive = true;
        };
      };
    };
}
