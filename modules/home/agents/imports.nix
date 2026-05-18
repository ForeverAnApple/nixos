{ config, ... }:
{
  flake.modules.homeManager.agents.imports = with config.flake.modules.homeManager; [
    agent-browser
    claude
    codex
    opencode
  ];
}
