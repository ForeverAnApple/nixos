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
            codexVersion = (builtins.fromJSON (builtins.readFile "${codexSrc}/codex-package.json")).version;
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
                mkdir -p $out/lib $out/bin
                cp -r ${codexSrc} $out/lib/codex
                ln -s $out/lib/codex/bin/codex $out/bin/codex
                runHook postInstall
              '';
              meta = {
                description = "OpenAI Codex CLI (prebuilt darwin binary, pinned GitHub release)";
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
