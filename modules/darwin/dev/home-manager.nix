topLevel@{ inputs, ... }:
{
  flake.modules.darwin.home-manager =
    { config, ... }:
    let
      inherit (config.networking) hostName;
    in
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ];

      home-manager = {
        backupFileExtension = "bak";

        useGlobalPkgs = true;
        useUserPackages = true;

        users.daaaa.imports = [
          topLevel.config.flake.modules.homeManager.core
          # Darwin-only home modules (terminal-notifier, mas, …).
          # Defined in modules/home/darwin/; routing lives only here.
          (topLevel.config.flake.modules.homeManager.darwin or { })
          (topLevel.config.flake.modules.homeManager."homes/${hostName}" or { })
        ];

        extraSpecialArgs.inputs = inputs;
      };
    };
}
