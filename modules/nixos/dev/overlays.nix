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

            arch = if final.stdenv.hostPlatform.isAarch64 then "aarch64" else "x86_64";
            codexSrc = inputs."codex-linux-${arch}";
            codexBin = "${codexSrc}/bin/codex";

            # The "latest" tarball carries no version in its name, so read it
            # from the binary (IFD). Without this the package stays
            # codex-latest forever and nh never reports a codex bump.
            codexVersion = final.lib.fileContents (
              final.runCommandLocal "codex-version" { } ''
                export HOME=$TMPDIR
                install -m755 ${codexBin} ./codex
                ./codex --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 | tr -d '\n' > $out
              ''
            );
          in
          {
            inherit (masterPkgs)
              claude-code
              opencode
              ;

            codex = final.stdenvNoCC.mkDerivation {
              pname = "codex";
              version = codexVersion;
              src = codexSrc;
              dontUnpack = true;
              nativeBuildInputs = [ final.makeBinaryWrapper ];
              installPhase = ''
                runHook preInstall
                install -Dm755 ${codexBin} $out/bin/codex
                install -Dm755 ${codexSrc}/bin/codex-code-mode-host $out/bin/codex-code-mode-host
                wrapProgram $out/bin/codex --prefix PATH : ${
                  final.lib.makeBinPath [
                    final.ripgrep
                    final.bubblewrap
                  ]
                }
                runHook postInstall
              '';
              meta = {
                description = "OpenAI Codex CLI (prebuilt static musl binary, latest GitHub release)";
                mainProgram = "codex";
                platforms = [
                  "x86_64-linux"
                  "aarch64-linux"
                ];
              };
            };

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
