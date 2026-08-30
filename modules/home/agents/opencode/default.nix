{ inputs, ... }:
{
  flake.modules.homeManager.opencode =
    { lib, ... }:
    {
      programs.opencode = {
        enable = true;
        # Writes to $XDG_CONFIG_HOME/opencode/AGENTS.md.
        context = ../ALL_AGENTS.md;
        skills.critical-info-ui-design = ../skills/critical-info-ui-design;
        skills.prose-style = ../skills/prose-style;
        skills.voice-notifications = ../skills/voice-notifications;
        skills.skill-creator = "${inputs.anthropic-skills}/skills/skill-creator";
      };
    };
}
