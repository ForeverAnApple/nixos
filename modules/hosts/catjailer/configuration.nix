{
  flake.modules.nixos."hosts/catjailer" =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      networking.hostName = "catjailer";
      system.stateVersion = "25.11";

      sops.defaultSopsFile = ./secrets.yaml;
      sops.secrets."users/faa/hashedPassword".neededForUsers = true;

      users.users.faa.hashedPasswordFile = config.sops.secrets."users/faa/hashedPassword".path;

      networking.firewall.checkReversePath = "loose";

      networking.firewall.interfaces.enp4s0.allowedTCPPorts = [ 22022 ];

      # Electron apps on Wayland
      environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # Desktop — prefer proprietary NVIDIA kernel module here.
      # The open module is triggering kernel crashes with Anki/QtWebEngine.
      hardware.nvidia.open = lib.mkForce false;

      # Desktop — no GPU power management (causes input lag on wake)
      hardware.nvidia.powerManagement.enable = lib.mkForce false;

      # btop with GPU monitoring and host-specific desktop apps
      environment.systemPackages = [
        (pkgs.btop.override { cudaSupport = true; })
        pkgs.alcom
        pkgs.vesktop
        pkgs.unityhub
        pkgs.vrcx
        pkgs.pwvucontrol
        pkgs.qpwgraph
      ];

      programs.coolercontrol.enable = true;

      services.hardware.openrgb = {
        enable = true;
        motherboard = "amd";
        package = pkgs.openrgb-with-all-plugins;
      };

      # Kill all RGB at boot:
      #   - 3090 FE "GeForce RTX" logo  → Off mode (NVIDIA's libnvidia-api.so,
      #     shipped by driver >=525, lets OpenRGB drive the FE illumination
      #     controller on Linux).
      #   - NZXT Smart Device V2 (Hue 2) case strip → Static / black. The
      #     Hue 2 controller has no Off mode, so we use the firmware-held
      #     Static mode at #000000 — survives if the openrgb server later
      #     stops sending frames (unlike Direct mode).
      # The SDK server (services.hardware.openrgb above) does the actual I/O;
      # this service just sends the right mode to each controller once they
      # enumerate.
      systemd.services.rgb-quiet = {
        description = "Silence GPU + case RGB via OpenRGB";
        after = [ "openrgb.service" ];
        requires = [ "openrgb.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "rgb-quiet" ''
            set -u
            OPENRGB=${pkgs.openrgb-with-all-plugins}/bin/openrgb

            wait_for() {
              # $1 = grep pattern that must appear in --list-devices
              for _ in $(seq 1 30); do
                if "$OPENRGB" --list-devices 2>/dev/null | grep -q "$1"; then
                  return 0
                fi
                sleep 1
              done
              return 1
            }

            rc=0

            # NVIDIA 3090 FE — has a real "Off" mode.
            if wait_for "3090 FE"; then
              "$OPENRGB" --device "NVIDIA GeForce RTX 3090 FE" --mode Off || rc=1
            else
              echo "rgb-quiet: 3090 FE not detected after 30s" >&2
              rc=1
            fi

            # NZXT Smart Device V2 — no Off mode; Static + black is the
            # firmware-persistent equivalent.
            if wait_for "NZXT Smart Device V2"; then
              "$OPENRGB" --device "NZXT Smart Device V2" --mode Static --color 000000 || rc=1
            else
              echo "rgb-quiet: NZXT Smart Device V2 not detected after 30s" >&2
              rc=1
            fi

            exit $rc
          '';
        };
      };

      # Keep large Unity/VRChat project data on the secondary disk while
      # leaving the packages themselves in the Nix store.
      systemd.tmpfiles.rules = [
        "d /mnt/alpha-oguri/Unity 0775 faa users - -"
        "d /mnt/alpha-oguri/Unity/Hub 0775 faa users - -"
        "d /mnt/alpha-oguri/Unity/Editors 0775 faa users - -"
        "d /mnt/alpha-oguri/Unity/Projects 0775 faa users - -"
        "d /mnt/alpha-oguri/VRChat 0775 faa users - -"
        "d /mnt/alpha-oguri/VRChat/ALCOM 0775 faa users - -"
        "d /mnt/alpha-oguri/VRChat/Backups 0775 faa users - -"
        "L+ /mnt/alpha-oguri/Unity/Hub/unityhub - - - - /run/current-system/sw/bin/unityhub"
      ];

      # Keep big CUDA builds from taking the whole machine down.
      zramSwap = {
        enable = true;
        memoryPercent = 50;
      };

      services.earlyoom = {
        enable = true;
        freeMemThreshold = 5;
        freeSwapThreshold = 10;
        enableNotifications = true;
        extraArgs = [
          "--prefer"
          "nix|nix-daemon|nix-build|cc1plus|c\+\+|ld|nvcc|ptxas"
        ];
      };

      boot.kernel.sysctl."vm.swappiness" = 80;

      nix.settings = {
        # vLLM/CUDA builds can spike RAM usage badly when left fully parallel.
        max-jobs = lib.mkDefault 2;
        cores = lib.mkDefault 4;
      };

      # No built-in laptop keyboard on a desktop
      services.keyd.keyboards.laptop.ids = lib.mkForce [ ];
    };
}
