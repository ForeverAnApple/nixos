{
  flake.modules.homeManager.core =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;
        # Sourced by every zsh invocation, before the guarded hm-session-vars.sh,
        # so PATH additions survive home-manager's __HM_SESS_VARS_SOURCED guard
        # and apply on rebuild without needing a full relogin.
        envExtra = ''
          for dir in "$HOME/scripts" "$HOME/.local/bin"; do
            case ":$PATH:" in
              *":$dir:"*) ;;
              *) PATH="$dir:$PATH" ;;
            esac
          done
          export PATH
        '';
        initContent = ''
          export GPG_TTY=$(tty)
          # batpipe internally calls `ps -o ...time...`; on recent macOS
          # that field needs a TCC entitlement and the unprivileged shell
          # gets `ps: time: requires entitlement` on stderr per invocation.
          # The stdout payload (LESSOPEN/BATPIPE) is fine, so silence stderr.
          eval "$(batpipe 2>/dev/null)"
          [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
          if [[ $- == *i* && -n "$SSH_CONNECTION" && -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
            tmux new-session -A -s "ssh-$USER@$(hostname)"
          fi
        '';
      };

      programs.zsh.oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "";
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = true;
          command_timeout = 1300;
          scan_timeout = 50;
        };
      };

      home.sessionVariables = {
        CARGO_TARGET_DIR = "$HOME/.cache/cargo-target";
        LANG = "en_US.UTF-8";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      };

      home.shellAliases = {
        grep = "batgrep";
        c = "claude";
        oc = "opencode";
        x = "codex";
      };
    };
}
