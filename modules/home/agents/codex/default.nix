{
  flake.modules.homeManager.codex =
    { lib, ... }:
    {
      programs.codex = {
        enable = true;
        # Writes to ~/.codex/AGENTS.md.
        context = ../instructions.md;
        settings = {
          check_for_update_on_startup = false;
          analytics.enabled = false;
          feedback.enabled = false;
          otel.metrics_exporter = "none";
        };
      };
    };
}
