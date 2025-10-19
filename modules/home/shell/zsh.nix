{
  flake.modules.homeManager.core = { lib, config, pkgs, ... }: {
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };

    programs.zsh.oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "";
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
  };
}
