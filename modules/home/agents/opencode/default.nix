{
  flake.modules.homeManager.opencode =
    { lib, ... }:
    {
      programs.opencode = {
        enable = true;
        # Writes to $XDG_CONFIG_HOME/opencode/AGENTS.md.
        context = ../instructions.md;
      };
    };
}
