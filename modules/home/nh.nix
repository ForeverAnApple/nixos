{
  flake.modules.homeManager.nh = { lib, config, ... }: {
    home.shellAliases = {
      u = "nh os switch -u";
      t = "nh os test";
      nrs = "nh os switch";
    };
    programs.nh = {
      enable = true;

      flake = lib.mkDefault "${config.home.homeDirectory}/nixos";

      clean = {
        enable = true;

        dates = "daily";
        extraArgs = "--keep 1 --keep-since 8d";
      };
    };
  };
}
