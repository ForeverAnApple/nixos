{
  flake.modules.darwin.power-logger =
    { config, ... }:
    {
      security.sudo.extraConfig = ''
        ${config.system.primaryUser} ALL=(root) NOPASSWD: /usr/bin/powermetrics --samplers tasks --show-process-energy -n 1 -i 5000
      '';
    };
}
