{ inputs, ... }:
{
  flake.modules.homeManager.firefox =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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
            # Bitwarden — pinned: 2026.7.0 renders an empty vault on Firefox
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/file/4875950/bitwarden_password_manager-2026.6.1.xpi";
              updates_disabled = true;
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
            settings."sidebar.verticalTabs" = true;
            settings."sidebar.visibility" = "always-show";
            settings."browser.compactmode.show" = true;
            settings."browser.uidensity" = 1;
            userChrome = lib.concatMapStrings (f: builtins.readFile "${inputs.firefox-csshacks}/chrome/${f}") [
              "autohide_toolbox.css"
              "autohide_tabstoolbar_v2.css"
            ]
            # FF 159 dropped this var; csshacks' hover width goes invalid without it
            + "sidebar-main { --tab-pinned-container-margin-inline-expanded: 0px; }\n"
            # csshacks stacks the sidebar above the revealed toolbox
            + "#navigator-toolbox { z-index: 10 !important; }\n";
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
