{
  flake.modules.homeManager.kitty =
    { lib, ... }:
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
        };
        # The default new_window / new_tab / new_os_window actions ignore
        # the active shell's cwd and reuse kitty's launch directory; the
        # _with_cwd variants pick up the cwd via shell integration so a
        # new pane opens where you were working.
        keybindings = {
          "ctrl+shift+enter" = "new_window_with_cwd";
          "ctrl+shift+t" = "new_tab_with_cwd";
          "ctrl+shift+n" = "new_os_window_with_cwd";
        };
        quickAccessTerminalConfig = {
          start_as_hidden = true;
          hide_on_focus_loss = true;
          background_opacity = 0.85;
          lines = 45;
        };
      };
    };
}
