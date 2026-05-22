{
  flake.modules.nixos.dev-overlays =
    { inputs, ... }:
    {
      nixpkgs.overlays = [
        (
          final: _prev:
          let
            # Pull AI CLIs from nixpkgs/master — they ship daily and
            # nixos-unstable lags by several days. Everything else stays
            # on unstable. Keep this list tight: each entry doubles the
            # eval cost of touching nixpkgs-master, so only packages
            # where "freshness now" beats "tested a bit" belong here.
            masterPkgs = import inputs.nixpkgs-master {
              system = final.stdenv.hostPlatform.system;
              config.allowUnfree = true;
            };
            # codex from nixos-unstable-small: Hydra-built (always cached),
            # hours behind master. Source builds aren't worth the marginal
            # freshness for this one.
            smallPkgs = import inputs.nixpkgs-unstable-small {
              system = final.stdenv.hostPlatform.system;
              config.allowUnfree = true;
            };
          in
          {
            inherit (masterPkgs)
              claude-code
              opencode
              ;
            inherit (smallPkgs) codex;

            vrcft = final.appimageTools.wrapType2 {
              pname = "VRCFaceTracking";
              version = "1.1.1.0";
              src = final.fetchurl {
                url = "https://github.com/dfgHiatus/VRCFaceTracking.Avalonia/releases/download/v1.1.1.0/VRCFaceTracking.Avalonia.1.1.1.0.x64.AppImage";
                hash = "sha256-oW8tsrJfC8woL2rCVyItFk4oR8M1SlQ/Y0vA1EaOhGQ=";
              };
              extraPkgs =
                pkgs: with pkgs; [
                  icu
                  openssl
                  vulkan-loader
                ];
            };
          }
        )
      ];
    };
}
