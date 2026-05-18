{
  flake.modules.nixos.home-assistant =
    { pkgs, ... }:
    let
      # The Wyze cloud client used by the ha-wyzeapi custom component.
      # Not in nixpkgs, so vendored from PyPI here.
      # Build against HA's bundled Python so the version matches the
      # interpreter that loads the custom component (HA tracks ahead of
      # the default python3 in nixpkgs).
      hassPy = pkgs.home-assistant.python.pkgs;
      wyzeapy = hassPy.buildPythonPackage rec {
        pname = "wyzeapy";
        version = "0.5.31";
        format = "pyproject";
        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-5NJt/ygrbeDZ6J5ovZ6FLAiI+f3yIFSmoHIzi6cRVJw=";
        };
        nativeBuildInputs = with hassPy; [ hatchling ];
        propagatedBuildInputs = with hassPy; [
          aiodns
          aiohttp
          pycryptodome
        ];
        doCheck = false;
      };

      # Community Wyze integration (not in nixpkgs' custom-components set).
      ha-wyzeapi = pkgs.buildHomeAssistantComponent {
        owner = "SecKatie";
        domain = "wyzeapi";
        version = "0.1.36";
        src = pkgs.fetchFromGitHub {
          owner = "SecKatie";
          repo = "ha-wyzeapi";
          rev = "0.1.36";
          hash = "sha256-4i5Ne3LYV7DXn6F6e5MCVZhIdDYR7fe3tT2GeSmYb/k=";
        };
        postPatch = ''
          substituteInPlace custom_components/wyzeapi/light.py \
            --replace-fail \
              'self._local_control = config_entry.options.get(BULB_LOCAL_CONTROL)' \
              'self._local_control = bool(config_entry.options.get(BULB_LOCAL_CONTROL) and self._bulb.ip)' \
            --replace-fail \
              'self._local_control = self._config_entry.options.get(BULB_LOCAL_CONTROL)' \
              'self._local_control = bool(self._config_entry.options.get(BULB_LOCAL_CONTROL) and self._bulb.ip)'
        '';
        dependencies = [ wyzeapy ];
      };
    in
    {
      services.home-assistant = {
        enable = true;
        openFirewall = false;

        customComponents = [ ha-wyzeapi ];

        extraComponents = [
          "default_config"
          "homekit"
          "homekit_controller"
          "met"
          "radio_browser"
          "google_translate"
          "isal"
          # Required by the wyzeapi manifest's `dependencies` list.
          "bluetooth_adapters"
        ];

        config = {
          default_config = { };

          homeassistant.external_url = "https://ha.jura.moe";

          http = {
            server_host = "127.0.0.1";
            use_x_forwarded_for = true;
            trusted_proxies = [
              "127.0.0.1"
              "::1"
            ];
          };

          homekit = [
            {
              name = "HASS Bridge";
              filter = {
                include_domains = [
                  "light"
                  "switch"
                  "scene"
                  "script"
                  "cover"
                  "fan"
                ];
              };
            }
          ];

          automation = "!include automations.yaml";
          scene = "!include scenes.yaml";
          script = "!include scripts.yaml";
        };
      };

      # mDNS / Bonjour — required for HomeKit pairing and for the HA Companion
      # app to auto-discover the server on Wi-Fi.
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
      };

      # HomeKit Bridge listens on a dynamic port; 21063 is the HA default.
      networking.firewall.allowedTCPPorts = [ 21063 ];

      # The `!include` directives above need these files to exist before HA
      # starts, otherwise HA bails into recovery mode on first boot. tmpfiles
      # `f` only creates them if missing, so user edits via the UI persist.
      systemd.tmpfiles.rules = [
        "f /var/lib/hass/automations.yaml 0644 hass hass -"
        "f /var/lib/hass/scenes.yaml 0644 hass hass -"
        "f /var/lib/hass/scripts.yaml 0644 hass hass -"
      ];
    };
}
