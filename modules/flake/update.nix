{ ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    {
      apps.update = {
        type = "app";
        program = "${pkgs.writeShellScript "update" ''
          set -euo pipefail
          export TMPDIR=/var/tmp
          export PATH="${
            lib.makeBinPath [
              pkgs.gnused
              pkgs.gnugrep
              pkgs.git
              pkgs.jq
              pkgs.coreutils
              pkgs.diffutils
              pkgs.nh
              pkgs.nix
              pkgs.perl
            ]
          }${
            if pkgs.stdenv.hostPlatform.isDarwin then ":/usr/bin:/bin:/usr/sbin:/sbin" else ":/run/wrappers/bin"
          }"
          case "$(${pkgs.coreutils}/bin/uname -s)" in
            Darwin) export NH_CMD="nh darwin" ;;
            Linux) export NH_CMD="nh os" ;;
            *) exit 1 ;;
          esac
          exec ${pkgs.bash}/bin/bash ${../home/core/nh-up.sh} "$@"
        ''}";
      };
    };
}
