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
          # Linux-only home modules (systemd timers, Wayland services, …).
          # Defined in modules/home/linux/; routing lives only here.
          (topLevel.config.flake.modules.homeManager.linux or { })
          (topLevel.config.flake.modules.homeManager."homes/${hostName}" or { })
        ];

        extraSpecialArgs.inputs = inputs;
      };
    };
}
