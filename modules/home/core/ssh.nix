{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      # Per-host aliases that don't belong in the repo.
      includes = [ "local.d/*" ];

      settings.sisyphus-unlock = {
        hostname = "sisyphus.davec.xyz";
        port = 2222;
        user = "root";
      };
      # Real sshd on these hosts lives on :22022 — endlessh holds :22.
      settings.nixos-fleet = {
        host = "catjailer catjailer.* dreameater dreameater.* sisyphus sisyphus.* swordholder swordholder.*";
        port = 22022;
        user = "faa";
        # Forward the herdr marker (only set inside a herdr pane) so the
        # remote skips its auto-start instead of nesting herdr in the pane.
        sendEnv = [ "HERDR_ENV" ];
      };
      settings."git.jura.moe" = {
        port = 22022;
        user = "forgejo";
      };
    };
  };
}
