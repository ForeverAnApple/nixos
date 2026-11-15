{
  flake.modules.nixos.dev-overlays =
    { inputs, ... }:
    {
      nixpkgs.overlays = [
        (
          final: _prev:
          let
            opencode2 = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.opencode2;
            masterPkgs = import inputs.nixpkgs-master {
              system = final.stdenv.hostPlatform.system;
              config.allowUnfree = true;
            };
          in
          {
            inherit (masterPkgs)
              claude-code
              agent-browser
              herdr
              typescript-language-server
              ;

            codex = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.codex;
            opencode = final.symlinkJoin {
              name = "opencode-${opencode2.version}";
              paths = [ opencode2 ];
              postBuild = ''
                ln -s $out/bin/opencode2 $out/bin/opencode
              '';
              meta = opencode2.meta // {
                mainProgram = "opencode";
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
