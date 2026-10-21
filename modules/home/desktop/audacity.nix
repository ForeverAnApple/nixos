{
  flake.modules.homeManager.audacity =
    { inputs, pkgs, ... }:
    let
      stablePkgs = import inputs.nixpkgs-stable {
        system = pkgs.stdenv.hostPlatform.system;
      };
    in
    {
      home.packages = [ stablePkgs.audacity ];
    };
}
