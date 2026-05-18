{
  flake.modules.homeManager.neovim =
    { lib, ... }:
    {
      programs.neovim = {
        enable = true;
        # Real symlinks reach nvim from non-interactive callers too
        # (git editor, sudoedit, scripts), unlike shell aliases.
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        withPython3 = false;
        withRuby = false;
      };
      xdg.configFile."nvim" = {
        source = ./config;
        recursive = true;
      };
    };
}
