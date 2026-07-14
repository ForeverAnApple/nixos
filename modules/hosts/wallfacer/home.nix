{ config, ... }:
{
  flake.modules.homeManager."homes/wallfacer" =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      notionUrl = "https://mcp.notion.com/mcp";
      syncNotionMcp = pkgs.writeShellApplication {
        name = "sync-notion-mcp";
        runtimeInputs = with pkgs; [
          coreutils
          jq
          perl
        ];
        text = ''
          notion_url=${lib.escapeShellArg notionUrl}
          codex_config_dir="$HOME/.codex"
          codex_config="$codex_config_dir/config.toml"
          mkdir -p "$codex_config_dir"
          codex_tmp=$(mktemp "$codex_config_dir/.config.toml.XXXXXX")
          opencode_config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
          opencode_config_dir="$opencode_config_home/opencode"
          opencode_config="$opencode_config_dir/opencode.json"
          mkdir -p "$opencode_config_dir"
          opencode_tmp=$(mktemp "$opencode_config_dir/.opencode.json.XXXXXX")
          trap 'rm -f "$codex_tmp" "$opencode_tmp"' EXIT

          if [[ -e "$codex_config" ]]; then
            codex_source="$codex_config"
            codex_mode=$(stat -c %a "$codex_config")
          else
            codex_source=/dev/null
            codex_mode=600
          fi

          NOTION_URL="$notion_url" perl -0777 -pe '
            BEGIN {
              my $url = $ENV{NOTION_URL};
              $url =~ s/\\/\\\\/g;
              $url =~ s/"/\\"/g;
              $replacement = qq{[mcp_servers.notion]\nurl = "$url"\n};
              $section = qr{^[ \t]*\[mcp_servers\.notion\][ \t]*(?:\#[^\r\n]*)?(?:\r?\n|\z).*?(?=^[ \t]*\[|\z)}ms;
            }

            if (!s{$section}{$replacement}) {
              if (length == 0) {
                $_ = $replacement;
              } elsif (/\n\z/) {
                $_ .= "\n$replacement";
              } else {
                $_ .= "\n\n$replacement";
              }
            }
          ' "$codex_source" > "$codex_tmp"

          chmod "$codex_mode" "$codex_tmp"
          if [[ -e "$codex_config" ]] && cmp -s "$codex_tmp" "$codex_config"; then
            rm "$codex_tmp"
          else
            mv "$codex_tmp" "$codex_config"
          fi

          if [[ -s "$opencode_config" ]]; then
            if ! jq -e 'type == "object"' "$opencode_config" > /dev/null; then
              echo "OpenCode config is not a JSON object: $opencode_config" >&2
              exit 1
            fi
            jq --arg url "$notion_url" \
              '.mcp = (.mcp // {}) | .mcp.notion = { type: "remote", url: $url }' \
              "$opencode_config" > "$opencode_tmp"
          else
            jq -n --arg url "$notion_url" \
              '{ mcp: { notion: { type: "remote", url: $url } } }' \
              > "$opencode_tmp"
          fi

          chmod 600 "$opencode_tmp"
          if [[ -e "$opencode_config" ]] && cmp -s "$opencode_tmp" "$opencode_config"; then
            chmod 600 "$opencode_config"
          else
            mv "$opencode_tmp" "$opencode_config"
          fi
        '';
      };
      open-interpreter = pkgs.symlinkJoin {
        name = "open-interpreter-0.0.23";
        paths = [ inputs.open-interpreter-darwin-aarch64 ];
        meta = {
          description = "Coding agent optimized for low-cost models";
          homepage = "https://www.openinterpreter.com";
          license = lib.licenses.asl20;
          mainProgram = "interpreter";
          platforms = [ "aarch64-darwin" ];
          sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        };
      };
    in
    {
      home.username = "daaaa";
      home.homeDirectory = "/Users/daaaa";

      home.packages = [ open-interpreter ];

      imports = with config.flake.modules.homeManager; [
        dev
        kitty
      ];

      programs.mcp = {
        enable = true;
        servers.notion.url = notionUrl;
      };

      programs.claude-code.enableMcpIntegration = true;

      home.activation.notionMcp =
        lib.hm.dag.entryAfter
          [
            "codexConfig"
            "writeBoundary"
          ]
          ''
            run ${lib.getExe syncNotionMcp}
          '';

      # The shared kitty module sets font_size = 10, which looks fine on the
      # Linux Hi-DPI hosts but is uncomfortably small on macOS Retina. Bump
      # it just for this host (mkForce because the shared module sets a
      # plain value at the same priority).
      programs.kitty.settings.font_size = lib.mkForce 14;

      # Auto-open a local herdr tab and a catjailer SSH tab on launch.
      # `launch` with no command runs the login shell, which auto-starts
      # herdr (see herdr.nix). The names come from the session, but the
      # shared cwd-basename tab_title_template ignores them, so swap to
      # {title} here — unnamed tabs then show their program title instead.
      programs.kitty.settings.startup_session = "${pkgs.writeText "wallfacer.session" ''
        new_tab wallfacer
        launch

        new_tab catjailer
        launch ssh catjailer
      ''}";
      programs.kitty.settings.tab_title_template = lib.mkForce "{title}";
    };
}
