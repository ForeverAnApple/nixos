{
  flake.modules.darwin.power-logger =
    { config, ... }:
    {
      # System half of the home-manager power-logger: let its unattended launchd
      # agent read per-process energy without a password prompt. powermetrics is
      # read-only telemetry, so NOPASSWD on it grants no state-changing power.
      security.sudo.extraConfig = ''
        ${config.system.primaryUser} ALL=(root) NOPASSWD: /usr/bin/powermetrics *
      '';
    };
}
