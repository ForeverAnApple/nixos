{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings.sisyphus-unlock = {
        hostname = "sisyphus.davec.xyz";
        port = 2222;
        user = "root";
      };
      # Real sshd on these hosts lives on :22022 — endlessh holds :22.
      settings.nixos-fleet = {
        host = "catjailer catjailer.* sisyphus sisyphus.* swordholder swordholder.*";
        port = 22022;
        user = "faa";
      };
      settings.dreameater = {
        hostname = "dreameater.davec.xyz";
      };
    };
  };
}
