{
  flake.modules.homeManager.core = { lib, config, pkgs, ... }: {
    home = {
      username = lib.mkDefault "faa";
      homeDirectory = "/home/${config.home.username}";

      # IMPORTANT - Read release notes before updating this value.
      stateVersion = "25.05";

      # Test to make sure home manager is working.
      packages = [ pkgs.hello ];
    };


    programs.home-manager.enable = true;
  };
}
