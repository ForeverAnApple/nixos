{
  flake.modules.nixos.komf =
    { config, pkgs, ... }:
    let
      jar = pkgs.fetchurl {
        url = "https://github.com/Snd-R/komf/releases/download/1.7.1/komf-1.7.1.jar";
        hash = "sha256-reVCSNj4FlKILXSRuRw/m7uv/SjTXS0Ch1snrNWJBNE=";
      };
      configFile = (pkgs.formats.yaml { }).generate "komf.yml" {
        komga = {
          baseUri = "http://localhost:25600";
          eventListener.enabled = true;
          metadataUpdate.default.seriesCovers = true;
        };
        metadataProviders.defaultProviders = {
          mangaUpdates = {
            priority = 10;
            enabled = true;
          };
          aniList = {
            priority = 20;
            enabled = true;
          };
        };
        database.file = "/var/lib/komf/database.sqlite";
        server.port = 8085;
      };
    in
    {
      sops.secrets."komf/env" = { };

      users.users.komf = {
        isSystemUser = true;
        group = "komf";
      };
      users.groups.komf = { };

      systemd.services.komf = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [
          "network-online.target"
          "komga.service"
        ];
        serviceConfig = {
          User = "komf";
          Group = "komf";
          StateDirectory = "komf";
          EnvironmentFile = config.sops.secrets."komf/env".path;
          ExecStart = "${pkgs.jdk21_headless}/bin/java -jar ${jar} ${configFile}";
          Restart = "on-failure";
        };
      };
    };
}
