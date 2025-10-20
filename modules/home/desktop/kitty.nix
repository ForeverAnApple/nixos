{
  flake.modules.homeManager.kitty = { lib, ... }: {
    home.sessionVariables = {
      TERMINAL = "kitty";
    };
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      font = {
        name = "Hack Nerd Font";
	size = 12;
      };
      quickAccessTerminalConfig = {
        start_as_hidden = true;
	hide_on_focus_loss = true;
	background_opacity = 0.85;
      };
    };
  };
}
