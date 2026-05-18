{
  flake.modules.homeManager.niri =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      programs.niri = {
        config = builtins.readFile ./config.kdl;
      };
    };
}
