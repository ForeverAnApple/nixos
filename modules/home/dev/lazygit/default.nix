{
  flake.modules.homeManager.lazygit =
    { pkgs, ... }:
    {
      programs.lazygit = {
        enable = true;
        settings = {
          git.overrideGpg = true;
          git.pagers = [
            { pager = "bat --plain --paging=never"; }
          ];
        };
      };
    };
}
