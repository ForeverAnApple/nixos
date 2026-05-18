{
  inputs,
  lib,
  config,
  ...
}:
let
  # Hosts that accept remote deploys via SSH. Fishspeaker is a laptop without
  # sshd — rebuild locally via `nh os switch` instead.
  deployHosts = [
    "catjailer"
    "sisyphus"
    "swordholder"
  ];

  # Hosts with no interactive faa user; deploy-rs ssh's as the dedicated
  # `deploy` account defined in modules/nixos/service/.
  serviceHosts = [
    "sisyphus"
    "swordholder"
  ];

  selected = lib.filterAttrs (n: _: builtins.elem n deployHosts) config.flake.nixosConfigurations;
in
{
  flake.deploy.nodes = lib.mapAttrs (
    hostname: nixos:
    let
      isService = builtins.elem hostname serviceHosts;
      system = nixos.config.nixpkgs.hostPlatform.system;
    in
    {
      inherit hostname;
      profilesOrder = [ "system" ];
      profiles.system = {
        sshUser = if isService then "deploy" else "faa";
        user = "root";
        path = inputs.deploy-rs.lib.${system}.activate.nixos nixos;
        magicRollback = true;
        autoRollback = true;
      };
    }
  ) selected;

  flake.checks = lib.mapAttrs (
    _system: deployLib: deployLib.deployChecks config.flake.deploy
  ) inputs.deploy-rs.lib;

  perSystem =
    { system, ... }:
    {
      apps.deploy = {
        type = "app";
        program = "${inputs.deploy-rs.packages.${system}.deploy-rs}/bin/deploy";
      };
    };
}
