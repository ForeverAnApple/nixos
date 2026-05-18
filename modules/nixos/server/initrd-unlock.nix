{
  flake.modules.nixos.initrd-unlock =
    { config, ... }:
    {
      boot.initrd.network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          # Same admin keys as the deploy user — single source of truth.
          authorizedKeys = config.users.users.deploy.openssh.authorizedKeys.keys;
          hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        };
      };

      # Drop the operator straight into the password agent on SSH login.
      boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
    };
}
