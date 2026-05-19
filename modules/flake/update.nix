{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      apps.update = {
        type = "app";
        program = "${pkgs.writeShellScript "update" ''
          set -euo pipefail
          cd "$HOME/nixos"
          host="$(${pkgs.coreutils}/bin/uname -n)"
          kernel="$(${pkgs.coreutils}/bin/uname -s)"

          case "$kernel" in
            Darwin)
              nh darwin switch .#"$host"
              ;;
            Linux)
              if [ "$host" = "catjailer" ]; then
                nh os switch .#"$host"
              else
                nh os switch --build-host catjailer .#"$host"
              fi
              ;;
            *)
              echo "update: unsupported kernel '$kernel'" >&2
              exit 1
              ;;
          esac

          exec nix run .#deploy -- "$@"
        ''}";
      };
    };
}
