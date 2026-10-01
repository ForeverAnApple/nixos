{ inputs, ... }:
{
  flake.modules.homeManager.codex =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      seed = (pkgs.formats.toml { }).generate "codex-config.toml" {
        model = "gpt-6-astra";
        approval_policy = "on-request";
        check_for_update_on_startup = false;
        analytics.enabled = false;
        feedback.enabled = false;
        otel.metrics_exporter = "none";
        approvals_reviewer = "auto_review";
      };
      home = config.home.homeDirectory;
    in
    {
      programs.codex = {
        enable = true;
        # Writes to ~/.codex/AGENTS.md.
        context = ../ALL_AGENTS.md;
        skills.critical-info-ui-design = ../skills/critical-info-ui-design;
        skills.prose-style = ../skills/prose-style;
        skills.voice-notifications = ../skills/voice-notifications;
        skills.skill-creator = "${inputs.anthropic-skills}/skills/skill-creator";
        skills.agent-browser = "${inputs.agent-browser-src}/skills/agent-browser";
      };

      # config.toml is left unmanaged on purpose. Codex persists directory- and
      # hook-trust into it at runtime via config/batchWrite, which fails against
      # a read-only nix-store symlink. Seed a writable copy and re-seed only when
      # the declarative content changes, so runtime trust survives rebuilds.
      home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        dst="${home}/.codex/config.toml"
        stamp="${home}/.codex/.config-seed"
        if [ ! -e "$dst" ] || [ "$(cat "$stamp" 2>/dev/null)" != "${seed}" ]; then
          run mkdir -p "${home}/.codex"
          run install -m644 "${seed}" "$dst"
          run sh -c 'printf %s "${seed}" > "'"$stamp"'"'
        fi
      '';

      # Pin the app-server daemon to this build; unpinned it self-updates from GitHub.
      # Each pin copies a ~400M release, so drop the ones no longer current.
      home.activation.codexDaemonPin = lib.hm.dag.entryAfter [ "codexConfig" ] ''
        codex="${config.programs.codex.package}"
        daemon="${home}/.codex/packages/app-server-daemon"
        stamp="${home}/.codex/.daemon-pin"
        if [ -e "$daemon/current" ] && [ "$(cat "$stamp" 2>/dev/null)" != "$codex" ]; then
          run "$codex/bin/codex" app-server daemon update --from-cli -y
          run sh -c 'printf %s "'"$codex"'" > "'"$stamp"'"'
          current="$(readlink -f "$daemon/current")"
          for r in "$daemon"/releases/*; do
            [ "$(readlink -f "$r")" = "$current" ] || run rm -rf "$r"
          done
        fi
      '';
    };
}
