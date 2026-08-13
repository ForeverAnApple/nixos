{
  flake.modules.homeManager.lazygit =
    { pkgs, ... }:
    {
      programs.lazygit = {
        enable = true;
        settings = {
          git.overrideGpg = true;
          git.diffRenderers = [
            { command = "bat --plain --paging=never"; }
          ];
        };
      };
    };
}
