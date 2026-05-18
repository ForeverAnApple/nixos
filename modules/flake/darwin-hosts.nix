{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption;
in
{
  options = {
    darwinHosts =
      let
        darwinHostType = types.submodule {
          options = {
            system = mkOption {
              type = types.str;
              default = "aarch64-darwin";
            };
          };
        };
      in
      mkOption {
        type = types.attrsOf darwinHostType;
      };
  };

  config = {
    flake.darwinConfigurations =
      let
        mkHost =
          hostname: options:
          inputs.nix-darwin.lib.darwinSystem {
            inherit (options) system;
            specialArgs.inputs = inputs;
            modules = [
              config.flake.modules.darwin.core
              (config.flake.modules.darwin."hosts/${hostname}" or { })
            ];
          };
      in
      lib.mapAttrs mkHost config.darwinHosts;
  };
}
