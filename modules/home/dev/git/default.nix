{
  flake.modules.homeManager.git =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.forgejo-cli ];

      programs.git = {
        enable = true;
        signing = {
          format = "ssh";
          key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
          signByDefault = true;
        };
        ignores = [
          ".envrc"
          ".direnv/"
        ];
        settings = {
          user.name = "ForeverAnApple";
          user.email = "kinbd8@gmail.com";
          pull.rebase = true;
          gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
        };
      };

      programs.gh = {
        enable = true;
        settings.git_protocol = "ssh";
      };
    };
}
