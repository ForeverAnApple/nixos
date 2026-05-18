{
  flake.modules.homeManager.core =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
}
