{
  flake.modules.darwin.dev-overlays =
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
          }
        )
      ];
    };
}
