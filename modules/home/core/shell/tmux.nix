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

          # Reload the config file
          unbind r
          bind r source-file ~/.config/tmux/tmux.conf
        '';
      };
    };
}
