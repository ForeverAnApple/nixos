{
  flake.modules.homeManager.niri = { inputs, lib, pkgs, ... }: {
    programs.niri = {
      config = builtins.readFile ./config.kdl;
    };
  };
}
