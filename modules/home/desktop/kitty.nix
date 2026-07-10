{
  flake.modules.homeManager.kitty =
    { lib, pkgs, ... }:
    {
      home.sessionVariables = {
        TERMINAL = "kitty";
      };
      programs.kitty = {
        enable = true;
        themeFile = "Catppuccin-Frappe";
        shellIntegration.enableZshIntegration = true;
        font = {
          name = "Hack Nerd Font";
        };
        settings = {
          font_size = 10;
          hide_window_decorations = "yes";
          tab_title_template = "{tab.active_wd.rsplit('/', 1)[-1]}";
          strip_trailing_spaces = "smart";
        }
        # macOS sends Option as a compose key by default, which would swallow
        # herdr's Alt/Ctrl+Alt nav chords. Map left Option to Alt; right
        # Option still types special characters. No-op on Linux.
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          macos_option_as_alt = "left";
        };
        # The default new_window / new_tab / new_os_window actions ignore
        # the active shell's cwd and reuse kitty's launch directory; the
        # _with_cwd variants pick up the cwd via shell integration so a
        # new pane opens where you were working.
        keybindings = {
          "ctrl+shift+enter" = "new_window_with_cwd";
          "ctrl+shift+t" = "new_tab_with_cwd";
          "ctrl+shift+n" = "new_os_window_with_cwd";
          # Always emit CSI-u for shift+enter / ctrl+enter so coding agents
          # (Claude Code, Codex) see them through ssh+tmux without depending
          # on kitty keyboard-protocol negotiation, which keeps regressing.
          "shift+enter" = ''send_text all \x1b[13;2u'';
          "ctrl+enter" = ''send_text all \x1b[13;5u'';
        };
        quickAccessTerminalConfig = {
          start_as_hidden = true;
          hide_on_focus_loss = true;
          background_opacity = 0.85;
          lines = 45;
          # The dropdown is a scratch shell, never a herdr host: its persistent
          # singleton client would otherwise make every main kitty tab see a
          # live client and skip its own herdr (herdr.nix). Tags the shell
          # regardless of launcher (skhd, niri).
          kitty_override = "env=HERDR_NO_AUTOSTART=1";
        };
      };
    };
}
