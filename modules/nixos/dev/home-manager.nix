topLevel@{ inputs, ... }:
{
  flake.modules.nixos.home-manager =
    { config, ... }:
    let
      inherit (config.networking) hostName;
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        backupFileExtension = "bak";

        useGlobalPkgs = true;
        useUserPackages = true;

        users.faa.imports = [
          topLevel.config.flake.modules.homeManager.core
          (topLevel.config.flake.modules.homeManager."homes/${hostName}" or { })
        ];

        extraSpecialArgs.inputs = inputs;
      };
    };
}
