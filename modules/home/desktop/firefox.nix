{
  flake.modules.homeManager.firefox =
    { config, pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-bin;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
        policies = {
          Homepage = "previous-session";
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          DefaultDownloadDirectory = "~/Downloads";
          DisableBuiltinPDFViewer = false;
          DisableMasterPasswordCreation = true;
          DisablePocket = true;
          DisableSetDesktopBackground = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          ExtensionSettings = {
            # asbplayer
            "{e4b27483-2e73-4762-b2ec-8d988a143a40}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/{e4b27483-2e73-4762-b2ec-8d988a143a40}/latest.xpi";
            };
            # Bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/{446900e4-71c2-419f-a6a7-df9c091e268b}/latest.xpi";
            };
            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi";
            };
            # Vimium
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/{d7742d87-e61d-4b78-b8a1-b469842139fa}/latest.xpi";
            };
          };
          FirefoxHome = {
            SponsoredTopSites = false;
            Highlights = false;
            Pocket = false;
            SponsoredPocket = false;
            Snippets = false;
          };
          FirefoxSuggest = {
            WebSuggestions = false;
            SponsoredSuggestions = false;
            ImproveSuggestions = false;
            Locked = true;
          };
          HttpsOnlyMode = "enabled";
          NoDefaultBookmarks = true;
          PasswordManagerEnabled = false;
          OfferToSaveLogins = false;
          PromptForDownloadLocation = true;
          SearchSuggestEnabled = false;
        };
        profiles = {
          primary = {
            id = 0;
            settings."toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            settings."browser.ctrlTab.sortByRecentlyUsed" = true;
            settings."browser.tabs.closeWindowWithLastTab" = false;
            userChrome = "";
            userContent = "";
          };
          vpn = {
            id = 1;
          };
        };
      };

      # stylix.targets.firefox.profileNames = [ "primary" ];
    };
}
