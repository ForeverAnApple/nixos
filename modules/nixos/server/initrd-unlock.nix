{
  flake.modules.nixos.initrd-unlock =
    { config, ... }:
    {
      boot.initrd.network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          # Same admin keys as the interactive faa user — single source of truth.
          # Login is still root@:2222 (stage-1 minimal env, no other users);
          # only the keys list is sourced from faa.
          authorizedKeys = config.users.users.faa.openssh.authorizedKeys.keys;
          hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        };
      };

      # Drop the operator straight into the password agent on SSH login.
      boot.initrd.systemd.users.root.shell = "/bin/systemd-tty-ask-password-agent";
    };
}
