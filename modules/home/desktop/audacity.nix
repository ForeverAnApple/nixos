{
  flake.modules.homeManager.audacity =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.audacity ];
    };
}
