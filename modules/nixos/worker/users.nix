{
  flake.modules.nixos.deploy-user =
    { pkgs, ... }:
    let
      wallfacerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBFfp88mw/pc5SWlQh56cnOqWDK0B2QZ4rncqLrUXKL daaaa@wallfacer";
      catjailerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9kOV2Q1F92O4tmO9tOZEstJswoRAcVSoU+K81hTxvZ faa@catjailer";
    in
    {
      users.users.deploy = {
        isNormalUser = true;
        description = "Fleet deployment account (deploy-rs)";
        shell = pkgs.bash;
        openssh.authorizedKeys.keys = [
          wallfacerKey
          catjailerKey
        ];
      };

      # faa exists on workers only as a service-runner identity (rootless docker,
      # systemd --user services like seeder). No shell, no SSH keys, no sudo —
      # the dev-tier interactive faa lives in modules/nixos/dev/users.nix.
      users.users.faa = {
        isNormalUser = true;
        description = "Service runner (no interactive access)";
        shell = "${pkgs.shadow}/bin/nologin";
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
