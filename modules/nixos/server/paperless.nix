{
  flake.modules.nixos.paperless =
    { config, ... }:
    {
      sops.secrets."paperless/admin_password" = { };

      services.paperless = {
        enable = true;
        address = "127.0.0.1";
        passwordFile = config.sops.secrets."paperless/admin_password".path;
        settings = {
          PAPERLESS_URL = "https://paperless.jura.moe";
          PAPERLESS_ADMIN_USER = "faa";
          PAPERLESS_OCR_LANGUAGE = "jpn+jpn_vert+eng";
        };
      };
    };
}
