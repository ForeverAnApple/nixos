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

  selected = lib.filterAttrs (n: _: builtins.elem n deployHosts) config.flake.nixosConfigurations;
in
{
  flake.deploy.nodes = lib.mapAttrs (
    hostname: nixos:
    let
      system = nixos.config.nixpkgs.hostPlatform.system;
    in
    {
      inherit hostname;
      profilesOrder = [ "system" ];
      profiles.system = {
        sshUser = "faa";
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
      apps.deploy = {
        type = "app";
        program = "${pkgs.writeShellScript "deploy" ''
          host="$(${pkgs.coreutils}/bin/uname -n)"
          kernel="$(${pkgs.coreutils}/bin/uname -s)"

          if [ "$host" != "catjailer" ] && [ "$kernel" != "Darwin" ]; then
            export NIX_CONFIG='max-jobs = 0'
          fi

          exec ${inputs.deploy-rs.packages.${system}.deploy-rs}/bin/deploy "$@"
        ''}";
      };
    };
}
