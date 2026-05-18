{
  flake.modules.homeManager.obsidian = {
    programs.obsidian = {
      enable = true;
      cli.enable = true;

      defaultSettings = {
        corePlugins = [
          "backlink"
          "bases"
          "bookmarks"
          "canvas"
          "command-palette"
          {
            name = "daily-notes";
            settings = {
              folder = "daily";
              autorun = false;
            };
          }
          "editor-status"
          "file-explorer"
          "file-recovery"
          "global-search"
          {
            name = "graph";
            settings = {
              collapse-filter = false;
              search = "";
              showTags = true;
              showAttachments = false;
              hideUnresolved = false;
              showOrphans = true;
              collapse-color-groups = false;
              colorGroups = [ ];
              collapse-display = false;
              showArrow = false;
              textFadeMultiplier = 0.1;
              nodeSizeMultiplier = 1.62271970481033;
              lineSizeMultiplier = 1.93295234666787;
              collapse-forces = false;
              centerStrength = 0.518713248970312;
              repelStrength = 10;
              linkStrength = 1;
              linkDistance = 250;
              scale = 0.7395158602219696;
              close = true;
            };
          }
          "markdown-importer"
          "note-composer"
          "outgoing-link"
          "outline"
          "page-preview"
          "switcher"
          "tag-pane"
          "templates"
          "word-count"
          "workspaces"
          "audio-recorder"
        ];

        app = {
          attachmentFolderPath = "./attachments";
          pdfExportSettings = {
            includeName = true;
            pageSize = "Letter";
            landscape = false;
            margin = "0";
            downscalePercent = 100;
          };
          vimMode = true;
          promptDelete = false;
          alwaysUpdateLinks = true;
          spellcheck = true;
          livePreview = true;
          strictLineBreaks = false;
        };

        appearance = {
          accentColor = "#6ed4b2";
          theme = "obsidian";
          cssTheme = "Catppuccin";
          baseFontSize = 18;
          interfaceFontFamily = "Hack Nerd Font";
          monospaceFontFamily = "Iosevka Nerd Font";
          textFontFamily = "Iosevka Aile,Iosevka Nerd Font";
        };

        hotkeys = {
          "insert-current-date" = [
            {
              modifiers = [
                "Ctrl"
                "Mod"
                "Shift"
              ];
              key = "T";
            }
          ];
        };
      };

      vaults = {
        Notes = {
          target = "Documents/Obsidian/Notes";
        };
      };
    };
  };
}
