{
  flake.modules.nixos.tmux =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wl-clipboard
      ];

      programs.tmux = {
        enable = lib.mkDefault true;
        clock24 = true;
        keyMode = "vi";
        terminal = "tmux-256color";
        historyLimit = 50000;
        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          catppuccin
        ];
        extraConfig = ''
          set -g mouse on
          set -g xterm-keys on
          set -g extended-keys on
          set -ga terminal-features ",*:extkeys"
          set -g focus-events on
          set -g set-clipboard on
          set -g renumber-windows on
          set -g base-index 1
          setw -g pane-base-index 1
          set -s escape-time 10
          set -g repeat-time 300
          set -g status-interval 5
          set -g allow-rename off
          set -g set-titles on
          set -g set-titles-string "#I: #W"
          set -g @catppuccin_flavor "frappe"
          set -g @catppuccin_window_status_style "rounded"
          set -g @yank_selection "clipboard"
          set -g @yank_with_mouse on
          if-shell 'command -v wl-copy >/dev/null 2>&1' 'set -g @yank_command "wl-copy"' 'set -g @yank_command "xclip -i -selection clipboard"'
          bind-key r source-file /etc/tmux.conf \; display-message "tmux.conf reloaded"
        '';
      };
    };
}
