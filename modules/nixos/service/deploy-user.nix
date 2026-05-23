{
  flake.modules.nixos.deploy-user =
    { pkgs, ... }:
    let
      wallfacerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBFfp88mw/pc5SWlQh56cnOqWDK0B2QZ4rncqLrUXKL daaaa@wallfacer";
      catjailerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9kOV2Q1F92O4tmO9tOZEstJswoRAcVSoU+K81hTxvZ faa@catjailer";
      fishspeakerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkJnLL3cD38k0Tgfn2NI4QjjBddCfOgPGOMWATl5A3U faa@fishspeaker";
    in
    {
      users.users.deploy = {
        isNormalUser = true;
        description = "Fleet deployment account (deploy-rs)";
        shell = pkgs.bash;
        openssh.authorizedKeys.keys = [
          wallfacerKey
          catjailerKey
          fishspeakerKey
        ];
      };

      # Required so deploy can push closures via nix-copy-closure without being root.
      nix.settings.trusted-users = [ "deploy" ];

      # deploy-rs's activation runs `sudo -H -u root <activate-script>`. NOPASSWD ALL
      # is the deploy-rs convention; can be scoped to the activation paths later.
      security.sudo.extraRules = [
        {
          users = [ "deploy" ];
          commands = [
            {
              command = "ALL";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
        }
      ];
    };
}
