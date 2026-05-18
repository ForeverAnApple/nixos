{
  flake.modules.homeManager.imv =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.imv ];
    };
}
