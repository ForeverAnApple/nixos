{
  flake.modules.homeManager.core =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      home = {
        username = lib.mkDefault "faa";
        homeDirectory = lib.mkDefault "/home/${config.home.username}";

        # IMPORTANT - Read release notes before updating this value.
        stateVersion = "26.05";

        packages = [ ];
      };

      programs.home-manager.enable = true;
    };
}
