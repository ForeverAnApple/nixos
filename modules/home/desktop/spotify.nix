{
  flake.modules.homeManager.spotify =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.spotify ];
    };
}
