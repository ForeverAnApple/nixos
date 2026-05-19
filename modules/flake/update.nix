{ ... }:
{
  # `nix run .#update` — one entry point per human-controlled host that
  # (a) rebuilds the local system and (b) pushes the latest closures to the
  # fleet via deploy-rs. Hostname-dispatched so catjailer / fishspeaker /
  # wallfacer can share a single command in muscle memory.
  perSystem =
    { system, pkgs, ... }:
    {
      apps.update = {
        type = "app";
        program = "${pkgs.writeShellScript "update" ''
          set -euo pipefail
          # cd into the flake checkout so the `nru` alias (see
          # modules/home/core/nh.nix) and any other invocation from an
          # arbitrary cwd resolves `.#deploy` / `.#fishspeaker` / `.#wallfacer`
          # against the right tree. ~/nixos is the convention every
          # human-user host follows (matches programs.nh.flake).
          cd "$HOME/nixos"
          host="$(${pkgs.coreutils}/bin/uname -n)"
          case "$host" in
            catjailer)
              # catjailer is itself a deploy target (see modules/flake/deploy.nix),
              # so a single deploy run covers it + the service hosts. No
              # separate self-build step.
              exec nix run .#deploy -- "$@"
              ;;
            fishspeaker)
              # `nh --build-host catjailer` ssh's the nix-build invocation
              # to catjailer instead of grinding this 16GB laptop. nh reads
              # the user's ssh config (see modules/home/core/ssh.nix), so
              # no system-level builder wiring is needed for this path.
              nh os switch --build-host catjailer .#fishspeaker
              exec nix run .#deploy -- "$@"
              ;;
            wallfacer)
              # Same deal, but darwin-rebuild under the hood. wallfacer is
              # aarch64-darwin and physically can't realise x86_64-linux
              # closures locally — the build-host flag is load-bearing.
              nh darwin switch --build-host catjailer .#wallfacer
              exec nix run .#deploy -- "$@"
              ;;
            *)
              echo "update: '$host' is not a known orchestrator host" >&2
              echo "expected one of: catjailer, fishspeaker, wallfacer" >&2
              exit 1
              ;;
          esac
        ''}";
      };
    };
}
