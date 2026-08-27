{
  flake.modules.nixos.suwayomi-server =
    { config, pkgs, ... }:
    {
      sops.secrets."suwayomi/basic_auth_password".owner = "suwayomi";

      services.suwayomi-server = {
        enable = true;
        # nixpkgs 2.1.x speaks the old extension index; Keiyoushi only serves
        # it "update your app" stubs. Drop when nixpkgs reaches 2.3.
        package = pkgs.suwayomi-server.overrideAttrs (old: rec {
          version = "2.3.2243";
          src = pkgs.fetchurl {
            url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${version}/Suwayomi-Server-v${version}.jar";
            hash = "sha256-ghFBsy4XDUoC08vf7Vd+2PB70iOD/19BMuu1rkDpjdU=";
          };
        });
        settings.server = {
          ip = "127.0.0.1";
          port = 4567;
          downloadAsCbz = true;
          basicAuthEnabled = true;
          basicAuthUsername = "faa";
          basicAuthPasswordFile = config.sops.secrets."suwayomi/basic_auth_password".path;
          # The server deletes any store missing from this list on every boot
          # (syncPrefsToDb); UI-added stores don't survive a restart, so the
          # list lives here. nixpkgs' extensionRepos option is deprecated
          # upstream — use the extensionStores key it migrated to.
          extensionStores = [
            "https://raw.githubusercontent.com/suwayomi/tachiyomi-extension/repo/repo.json"
            "https://raw.githubusercontent.com/keiyoushi/extensions/repo/repo.json"
          ];
        };
      };
    };
}
