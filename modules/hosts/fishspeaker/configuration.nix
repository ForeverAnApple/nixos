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

      # Distributed builds: delegate Linux derivations to catjailer instead
      # of grinding this 16GB laptop. `nix run .#deploy` additionally forces
      # `max-jobs = 0` so every closure goes remote; routine local builds
      # still run here when fishspeaker has the headroom. Mirrors the
      # wallfacer setup in modules/darwin/core/nix.nix.
      #
      # i686-linux is advertised because NixOS x86_64 hosts auto-add it to
      # extra-platforms; without it 32-bit derivations (nvidia libs, perl
      # builder hooks) refuse to delegate and stall the build. aarch64-linux
      # is omitted because catjailer has no binfmt/qemu set up.
      nix.distributedBuilds = true;
      nix.buildMachines = [
        {
          hostName = "catjailer";
          systems = [
            "x86_64-linux"
            "i686-linux"
          ];
          sshUser = "faa";
          # Root reads through POSIX mode bits on Linux, so faa's key works
          # directly — no need to provision a separate /root/.ssh key.
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

      # System-wide SSH config for the nix daemon (runs as root, doesn't
      # read ~faa/.ssh/config). Goes in programs.ssh.extraConfig because
      # NixOS's /etc/ssh/ssh_config doesn't `Include ssh_config.d/*.conf`
      # — drop-ins there are silently ignored (differs from macOS).
      programs.ssh.extraConfig = ''
        Host catjailer catjailer.*
          Port 22022
          User faa
          StrictHostKeyChecking accept-new
      '';
    };
}
