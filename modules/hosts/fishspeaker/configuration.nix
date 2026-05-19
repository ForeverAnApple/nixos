{
  flake.modules.nixos."hosts/fishspeaker" =
    { pkgs, ... }:
    {
      networking.hostName = "fishspeaker";
      system.stateVersion = "25.11";

      # Electron apps on Wayland
      environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # SSL certs - cover all the picky tools
      environment.variables = {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        CURL_CA_BUNDLE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        REQUESTS_CA_BUNDLE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };

      # Memory safeguards (16GB RAM laptop)
      zramSwap = {
        enable = true;
        memoryPercent = 50;
      };

      services.earlyoom = {
        enable = true;
        freeMemThreshold = 10; # Kill earlier, before thrashing
        freeSwapThreshold = 20; # 20% of 24GB = ~5GB buffer
        enableNotifications = true; # Desktop notification on kill
        extraArgs = [
          "--prefer"
          "rust-analyzer" # Kill this first when OOM
        ];
      };

      boot.kernel.sysctl."vm.swappiness" = 10;

      nix.distributedBuilds = true;
      nix.buildMachines = [
        {
          hostName = "catjailer";
          # i686-linux: NixOS x86_64 hosts auto-add it to extra-platforms;
          # 32-bit drvs (nvidia, perl builder hooks) stall without it.
          systems = [
            "x86_64-linux"
            "i686-linux"
          ];
          sshUser = "faa";
          sshKey = "/home/faa/.ssh/id_ed25519";
          maxJobs = 4;
          speedFactor = 2;
          supportedFeatures = [
            "nixos-test"
            "benchmark"
            "big-parallel"
            "kvm"
          ];
          protocol = "ssh-ng";
        }
      ];

      nix.settings.builders-use-substitutes = true;

      # NixOS /etc/ssh/ssh_config doesn't Include ssh_config.d, so this
      # can't live as a drop-in (differs from macOS).
      programs.ssh.extraConfig = ''
        Host catjailer catjailer.*
          Port 22022
          User faa
          StrictHostKeyChecking accept-new
      '';
    };
}
