{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks.sisyphus-unlock = {
        hostname = "sisyphus.davec.xyz";
        port = 2222;
        user = "root";
      };
      # Real sshd on these hosts lives on :22022 — endlessh holds :22.
      # Default to user `faa` so `rsync host:path/` and `ssh host` from
      # a different local username (daaaa on the Mac) don't try to auth
      # as a nonexistent user.
      matchBlocks.nixos-hosts = {
        host = "catjailer catjailer.* sisyphus sisyphus.* swordholder swordholder.*";
        port = 22022;
        user = "faa";
      };
      matchBlocks.dreameater = {
        hostname = "dreameater.davec.xyz";
      };
    };
  };
}
