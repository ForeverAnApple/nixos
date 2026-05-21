{
  flake.modules.homeManager.codex =
    { lib, ... }:
    {
      programs.codex = {
        enable = true;
        # Writes to ~/.codex/AGENTS.md.
        context = ../ALL_AGENTS.md;
        skills.prose-style = ../skills/prose-style;
        settings = {
          check_for_update_on_startup = false;
          analytics.enabled = false;
          feedback.enabled = false;
          otel.metrics_exporter = "none";
        };
      };
    };
}
