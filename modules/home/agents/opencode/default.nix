{
  flake.modules.homeManager.opencode =
    { lib, ... }:
    {
      programs.opencode = {
        enable = true;
        # Writes to $XDG_CONFIG_HOME/opencode/AGENTS.md.
        context = ../ALL_AGENTS.md;
        skills.prose-style = ../skills/prose-style;
      };
    };
}
