# The server has no signup endpoint; this list is the account database.
# New account = new entry here + a matching sops secret.
{
  flake.modules.nixos.anki-sync-server =
    { config, ... }:
    {
      sops.secrets."anki/faa_password" = { };

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
    };
}
