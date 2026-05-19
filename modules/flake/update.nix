{ ... }:
{
  perSystem =
    { system, pkgs, ... }:
    {
      apps.update = {
        type = "app";
        program = "${pkgs.writeShellScript "update" ''
          set -euo pipefail
          cd "$HOME/nixos"
          host="$(${pkgs.coreutils}/bin/uname -n)"
          case "$host" in
            catjailer)
              exec nix run .#deploy -- "$@"
              ;;
            fishspeaker)
              nh os switch --build-host catjailer .#fishspeaker
              exec nix run .#deploy -- "$@"
              ;;
            wallfacer)
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
