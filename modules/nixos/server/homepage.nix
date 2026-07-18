{
  flake.modules.nixos.homepage = {
    services.homepage-dashboard = {
      enable = true;
      allowedHosts = "dash.jura.moe";

      settings = {
        title = "swordholder";
      };

      services = [
        {
          Media = [
            {
              Plex = {
                href = "https://plex.jura.moe";
                icon = "plex.png";
              };
            }
            {
              Audiobookshelf = {
                href = "https://abs.jura.moe";
                icon = "audiobookshelf.png";
              };
            }
            {
              Immich = {
                href = "https://immich.jura.moe";
                icon = "immich.png";
              };
            }
            {
              qBittorrent = {
                href = "https://qbit.jura.moe";
                icon = "qbittorrent.png";
              };
            }
          ];
        }
        {
          Home = [
            {
              "Home Assistant" = {
                href = "https://ha.jura.moe";
                icon = "home-assistant.png";
              };
            }
          ];
        }
        {
          Tools = [
            {
              Forgejo = {
                href = "https://git.jura.moe";
                icon = "forgejo.png";
              };
            }
            {
              Paperless = {
                href = "https://paperless.jura.moe";
                icon = "paperless-ngx.png";
              };
            }
          ];
        }
      ];

      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            disk = [
              "/"
              "/THICC"
            ];
          };
        }
        {
          datetime = {
            text_size = "xl";
            format = {
              timeStyle = "short";
              dateStyle = "long";
            };
          };
        }
      ];
    };

    # module has no bind-address option; the Next standalone server honors HOSTNAME
    systemd.services.homepage-dashboard.environment.HOSTNAME = "127.0.0.1";
  };
}
