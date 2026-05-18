{
  flake.modules.homeManager.core =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      home = {
        packages = [ pkgs.bat-extras.batpipe pkgs.bat-extras.batgrep ];
        sessionVariables = {
          PAGER = "bat --plain";
        };
        shellAliases = {
          cat = "bat";
          less = "bat --plain";
        };
      };
      programs.bat = {
        enable = true;
        config.pager = "less -FR";
      };
    };
}
