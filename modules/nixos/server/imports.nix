{ config, inputs, ... }:
{
  flake.modules.nixos.server.imports = with config.flake.modules.nixos; [
    sshd
    fail2ban
  ];
}
