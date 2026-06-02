{
  flake.modules.darwin.dev-overlays =
    { inputs, ... }:
    {
      nixpkgs.overlays = [
        (
          final: _prev:
          let
            masterPkgs = import inputs.nixpkgs-master {
              system = final.stdenv.hostPlatform.system;
              config.allowUnfree = true;
            };

            arch = if final.stdenv.hostPlatform.isAarch64 then "aarch64" else "x86_64";
            codexSrc = inputs."codex-darwin-${arch}";
            codexBin = "${codexSrc}/codex-${arch}-apple-darwin";

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
              installPhase = ''
                runHook preInstall
                install -Dm755 ${codexBin} $out/bin/codex
                runHook postInstall
              '';
              meta = {
                description = "OpenAI Codex CLI (prebuilt darwin binary, latest GitHub release)";
                mainProgram = "codex";
                platforms = [
                  "aarch64-darwin"
                  "x86_64-darwin"
                ];
              };
            };
          }
        )
      ];
    };
}
