{
  flake.modules.nixos.nix = {
    nixpkgs.config.allowUnfree = true;

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      settings = {
        auto-optimise-store = true;
        min-free = 2 * 1024 * 1024 * 1024;
        max-free = 10 * 1024 * 1024 * 1024;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };
  };
}
