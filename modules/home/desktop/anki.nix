{
  flake.modules.homeManager.anki =
    { lib, pkgs, ... }:
    {
      programs.anki = {
        enable = true;

        theme = "dark";

        profiles = {
          "ForeverAnApple" = {
            default = true;
          };
        };

        addons = [
          (pkgs.anki-utils.buildAnkiAddon {
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
          })
          (pkgs.ankiAddons.anki-connect.withConfig {
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
          })
          pkgs.ankiAddons.review-heatmap
        ];

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
    };
}
