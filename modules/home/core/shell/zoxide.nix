{
  flake.modules.homeManager.core = { lib, config, pkgs, ... }: {
    home.shellAliases = {
      cd = "z";
    };
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
