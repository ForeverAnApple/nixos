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
      # Pin every closure build to catjailer, regardless of where the deploy
      # is invoked. Laptops in the fleet (eg. fishspeaker, 16GB) OOM building
      # several host closures back-to-back. All hosts in `deployHosts` above
      # are x86_64-linux, so catjailer alone covers them — the aarch64-darwin
      # box (wallfacer) is deliberately not a deploy target.
      #
      # Skip the override when the deploy is run *on* catjailer; it builds
      # locally and doesn't need to ssh into itself.
      apps.deploy = {
        type = "app";
        program = "${pkgs.writeShellScript "deploy" ''
          if [ "$(${pkgs.coreutils}/bin/uname -n)" != "catjailer" ]; then
            export NIX_CONFIG=$(${pkgs.coreutils}/bin/printf '%s\n' \
              'builders = ssh-ng://catjailer x86_64-linux' \
              'max-jobs = 0' \
              'builders-use-substitutes = true')
          fi
          exec ${inputs.deploy-rs.packages.${system}.deploy-rs}/bin/deploy "$@"
        ''}";
      };
    };
}
