{
  flake.modules.homeManager.core =
    { ... }:
    {
      programs.tmux = {
        enable = true;
        # Keep the config minimal and explicit — sensibleOnTop=true pulls
        # tmux-sensible which silently changes defaults.
        sensibleOnTop = false;
        extraConfig = ''
          # Use Vim shortcuts
          setw -g mode-keys vi

          # Enable mouse support — needed for touch scrolling on mobile
          # (Termux / Blink / iSH) and trackpad scroll in terminal emulators.
          set -g mouse on

          # Pass CSI-u modified keys (e.g. shift+enter) through to apps like
          # Claude Code / Codex. `always` (not `on`) so we don't depend on
          # the app requesting DECSET 2017 — this is the negotiation step
          # that keeps regressing across tmux/claude-code versions.
          set -g xterm-keys on
          set -g extended-keys always
          set -ga terminal-features ",*:extkeys"

          # Reload the config file
          unbind r
          bind r source-file ~/.config/tmux/tmux.conf
        '';
      };
    };
}
