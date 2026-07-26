# The server has no signup endpoint; accounts are static config, read once
# at start. faa is declarative (SYNC_USER1 via sops); extra users live in
# /etc/anki-sync-users.env on the host as SYNC_USER2=name:pass onward —
# append + `systemctl restart anki-sync-server`, no redeploy. The server
# stops reading at the first numbering gap.
{
  flake.modules.nixos.anki-sync-server =
    { config, ... }:
    {
      sops.secrets."anki/faa_password".restartUnits = [ "anki-sync-server.service" ];

      services.anki-sync-server = {
        enable = true;
        address = "127.0.0.1";
        openFirewall = false;
        users = [
          {
            username = "faa";
            passwordFile = config.sops.secrets."anki/faa_password".path;
          }
        ];
      };

      systemd.services.anki-sync-server.serviceConfig.EnvironmentFile = "-/etc/anki-sync-users.env";
      systemd.tmpfiles.rules = [ "f /etc/anki-sync-users.env 0600 root root -" ];
    };
}
