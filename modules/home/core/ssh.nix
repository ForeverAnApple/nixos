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
      matchBlocks.nixos-dev = {
        host = "catjailer catjailer.*";
        port = 22022;
        user = "faa";
      };
      # Service hosts (sisyphus, swordholder) have no interactive faa user;
      # the deploy account is the only login path.
      matchBlocks.nixos-services = {
        host = "sisyphus sisyphus.* swordholder swordholder.*";
        port = 22022;
        user = "deploy";
      };
      matchBlocks.dreameater = {
        hostname = "dreameater.davec.xyz";
      };
    };
  };
}
