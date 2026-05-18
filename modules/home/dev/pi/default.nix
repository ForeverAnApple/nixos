{
  flake.modules.homeManager.pi =
    { inputs, pkgs, ... }:
    {
      home.packages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
      ];
    };
}
