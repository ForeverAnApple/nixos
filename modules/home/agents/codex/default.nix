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
        model = "gpt-6.2-astra";
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
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.bubblewrap ];

      programs.codex = {
        enable = true;
        # Writes to ~/.codex/AGENTS.md.
        context = ../ALL_AGENTS.md;
        skills.critical-info-ui-design = ../skills/critical-info-ui-design;
        skills.prose-style = ../skills/prose-style;
        skills.voice-notifications = ../skills/voice-notifications;
        skills.skill-creator = "${inputs.anthropic-skills}/skills/skill-creator";
        skills.agent-browser = "${pkgs.agent-browser}/skills/agent-browser";
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

      home.activation.codexDaemon = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
        lib.hm.dag.entryAfter [ "codexConfig" ] ''
          daemonPackage="${home}/.codex/packages/app-server-daemon/current"
          if [ -L "$daemonPackage" ] && [ "$(readlink "$daemonPackage")" != "${config.programs.codex.package}/libexec/codex" ]; then
            run env CODEX_HOME="${home}/.codex" "${lib.getExe config.programs.codex.package}" app-server daemon update --from-cli --yes
          fi
        ''
      );
    };
}
