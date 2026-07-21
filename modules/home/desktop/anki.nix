{
  flake.modules.homeManager.anki =
    { lib, pkgs, ... }:
    let
      # Attr name must match the addon pname — it's the install dir name.
      addons = {
        anki-vrc = pkgs.anki-utils.buildAnkiAddon {
          pname = "anki-vrc";
          version = "0.1.0";

          src = pkgs.fetchFromGitHub {
            owner = "ForeverAnApple";
            repo = "AnkiVRC";
            rev = "v0.1.0";
            hash = "sha256-sgdYs19hVI8jy2x9ZNID2DRaqhgu6055pm7ETZZZ7V4=";
          };

          meta = {
            description = "Send Anki review status to VRChat via OSC";
            homepage = "https://github.com/ForeverAnApple/AnkiVRC";
            license = lib.licenses.asl20;
          };
        };

        anki-connect = pkgs.ankiAddons.anki-connect.withConfig {
          config = {
            apiKey = null;
            apiLogPath = null;
            webBindAddress = "127.0.0.1";
            webBindPort = 8765;
            # asbplayer + mokuro for Japanese immersion workflow
            webCorsOriginList = [
              "http://localhost"
              "https://killergerbah.github.io"
              "https://reader.mokuro.app"
            ];
            ignoreOriginList = [ ];
          };
        };

        review-heatmap = pkgs.ankiAddons.review-heatmap;

        ogg2mp3 =
          (pkgs.anki-utils.buildAnkiAddon {
            pname = "ogg2mp3";
            version = "0.1.0";

            src = pkgs.fetchFromGitHub {
              owner = "ForeverAnApple";
              repo = "language";
              rev = "v0.1.0";
              hash = "sha256-ubS1uOsdMiouk34+zpNL9gi17CA2ip2k9weB7dkhfV8=";
            };

            sourceRoot = "source/ogg2mp3";

            meta = {
              description = "Convert note-referenced ogg audio to mp3 before sync";
              homepage = "https://github.com/ForeverAnApple/language";
              license = lib.licenses.asl20;
            };
          }).withConfig
            {
              config = {
                search = "deck:General";
                delete_originals = true;
              };
            };

        anki-beacon = pkgs.anki-utils.buildAnkiAddon {
          pname = "anki-beacon";
          version = "0-unstable-2026-05-03";

          src = pkgs.fetchzip {
            url = "https://ankiweb.net/shared/download/1577021707?v=2.1&p=250200";
            extension = "zip";
            stripRoot = false;
            hash = "sha256-+XR2RjI1zT9leekKsoKEGOAI+cE1NFMf60fR4g4Bfic=";
          };

          meta = {
            description = "Post JSON events from Anki to HTTP receivers";
            homepage = "https://ankiweb.net/shared/info/1577021707";
          };
        };
      };
    in
    {
      home.packages = [ pkgs.anki ];

      # Symlinked into the mutable addon dir: nix pins these (read-only,
      # configure here instead of in-app), Tools > Add-ons works for the rest.
      xdg.dataFile = lib.mapAttrs' (
        name: addon:
        lib.nameValuePair "Anki2/addons21/${name}" {
          source = "${addon}/share/anki/addons/${name}";
        }
      ) addons;

      # Remaining addons — install via AnkiWeb:
      #   1045800357 - Local Audio Server for Yomichan (needs audio DB set up first)
      #   148002038  - Japanese Pitch Accent
      #   759844606  - FSRS Helper
      #   1610304449 - Kanji Grid (Kuuube)
      #   1247171202 - Study Time Stats
      #   266436365  - Progress Graphs and Stats
      #   2089200096 - Remove Card History
      #   324600677  - Hide Leech Notification
      #   31746032   - AnkiWebView Inspector
      #   24411424   - Customize Keyboard Shortcuts
    };
}
