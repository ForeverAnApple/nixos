{
  flake.modules.homeManager.claude =
    { pkgs, ... }:
    let
      statusLine = pkgs.writeShellApplication {
        name = "claude-statusline";
        runtimeInputs = with pkgs; [
          jq
          coreutils
        ];
        # Loose mode: a missing rate_limits field or an early-session null
        # should never make the statusline exit non-zero.
        bashOptions = [ "pipefail" ];
        text = builtins.readFile ./statusline.sh;
      };
    in
    {
      programs.claude-code = {
        enable = true;
        # Writes to ~/.claude/CLAUDE.md (symlink → nix store).
        # Shared with opencode + codex so all agents read the same rules.
        context = ../ALL_AGENTS.md;
        skills.prose-style = ../skills/prose-style;
        settings = {
          env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
          permissions.defaultMode = "auto";
          # Without this, Claude shows the "make auto mode your default?"
          # opt-in dialog every session: clicking "yes" tries to write
          # skipAutoPermissionPrompt back to settings.json, but our file is
          # a read-only nix-store symlink so the write silently fails.
          # Setting it here in the source of truth is the actual fix.
          skipAutoPermissionPrompt = true;
          # Extended thinking on by default, with summaries surfaced in the
          # transcript view (Ctrl+O, Ctrl+E) so long pauses are inspectable.
          alwaysThinkingEnabled = true;
          showThinkingSummaries = true;
          statusLine = {
            type = "command";
            command = "${statusLine}/bin/claude-statusline";
            padding = 1;
          };
        };
      };
    };
}
