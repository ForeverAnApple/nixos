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

      # vesktop pins electron_40; drop when nixpkgs bumps it.
      nixpkgs.config.permittedInsecurePackages = [
        "pnpm-10.29.2"
        "electron-40.10.5"
      ];

      # Cap core dumps: multi-GB crash cores stall the disk for minutes. Both
      # keys needed — the bound is MIN(rlimit, MAX(Process, External)).
      # MaxUse bounds the pool; per-core caps alone let crash-loops fill the disk.
      systemd.coredump.settings.Coredump = {
        ProcessSizeMax = "256M";
        ExternalSizeMax = "256M";
        MaxUse = "2G";
      };

      # Delays NVIDIA bug 5762513 (BAR1 mapping leak): stop niri pooling freed
      # GPU buffers so BAR1 fills slower. Mitigation, not a cure.
      environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri-limit-buffer-pool.json".text =
        builtins.toJSON
          {
            rules = [
              {
                pattern = {
                  feature = "procname";
                  matches = "niri";
                };
                profile = "LimitFreeBufferPool";
              }
            ];
            profiles = [
              {
                name = "LimitFreeBufferPool";
                settings = [
                  {
                    key = "GLVidHeapReuseRatio";
                    value = 0;
                  }
                ];
              }
            ];
          };

      # Early KMS — avoids the text-mode flash at boot on display-attached GPUs.
      boot.initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];

      environment.systemPackages = [
        pkgs.alcom
        # withSystemVencord pins Vencord to the reproducible nixpkgs build so it
        # can't silently rot against Discord's rolling web client; it forces a
        # source build of vesktop, which needs the (build-time only) pnpm above.
        (pkgs.vesktop.override { withSystemVencord = true; })
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

      # Kill all RGB at boot. The SDK server above does the I/O; this just
      # sends each controller its mode once it enumerates.
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

            if wait_for "3090 FE"; then
              "$OPENRGB" --device "NVIDIA GeForce RTX 3090 FE" --mode Off || rc=1
            else
              echo "rgb-quiet: 3090 FE not detected after 30s" >&2
              rc=1
            fi

            # Hue 2 has no Off mode; firmware-held Static + black is the
            # persistent equivalent (Direct mode isn't).
            if wait_for "NZXT Smart Device V2"; then
              "$OPENRGB" --device "NZXT Smart Device V2" --mode Static --color 000000 || rc=1
            else
              echo "rgb-quiet: NZXT Smart Device V2 not detected after 30s" >&2
              rc=1
            fi

            # Best-effort cosmetic: never fail activation. A non-zero exit here
            # aborts `nh os switch` before it writes the boot generation.
            [ "$rc" -ne 0 ] && echo "rgb-quiet: finished with warnings" >&2
            exit 0
          '';
        };
      };

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
        # Fully parallel builds can spike RAM enough to stall the machine.
        max-jobs = lib.mkDefault 2;
        cores = lib.mkDefault 4;
      };

      # No built-in laptop keyboard on a desktop
      services.keyd.keyboards.laptop.ids = lib.mkForce [ ];
    };
}
