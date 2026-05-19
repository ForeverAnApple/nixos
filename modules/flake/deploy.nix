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
    { system, pkgs, ... }:
    {
      # Force every closure through whichever remote builder this host has
      # configured (catjailer, in practice — see nix.buildMachines on
      # fishspeaker / wallfacer). `max-jobs = 0` makes the local nix daemon
      # refuse all build slots, so deploy-rs's nix-build hands every drv to
      # the remote. Laptops (eg. fishspeaker, 16GB) OOM building several
      # host closures back-to-back without this.
      #
      # Skip on catjailer itself: it has no buildMachines and *is* the
      # builder, so it just builds locally.
      apps.deploy = {
        type = "app";
        program = "${pkgs.writeShellScript "deploy" ''
          if [ "$(${pkgs.coreutils}/bin/uname -n)" != "catjailer" ]; then
            export NIX_CONFIG='max-jobs = 0'
          fi
          exec ${inputs.deploy-rs.packages.${system}.deploy-rs}/bin/deploy "$@"
        ''}";
      };
    };
}
