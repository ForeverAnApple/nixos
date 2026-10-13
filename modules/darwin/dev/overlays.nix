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
          in
          {
            inherit (masterPkgs)
              claude-code
              opencode
              ;

            codex = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.codex;
          }
        )
      ];
    };
}
