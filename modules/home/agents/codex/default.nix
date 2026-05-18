{
  flake.modules.homeManager.codex =
    { lib, ... }:
    {
      programs.codex = {
        enable = true;
        # Writes to ~/.codex/AGENTS.md.
        context = ../instructions.md;
      };
    };
}
