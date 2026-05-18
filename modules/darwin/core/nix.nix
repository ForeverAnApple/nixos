{
  flake.modules.darwin.nix = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # auto-optimise-store on Darwin races the daemon and can corrupt the
      # store; nix.optimise.automatic below is the safe replacement.

      # When a remote builder produces a closure, prefer pulling its
      # substitutes from cache.nixos.org rather than streaming it back
      # through our laptop — saves tunneling 1–2 GB per deploy.
      builders-use-substitutes = true;
    };

    nix.gc = {
      automatic = true;
      interval = {
        Hour = 3;
        Minute = 15;
      };
      options = "--delete-older-than 30d";
    };
    nix.optimise.automatic = true;

    nixpkgs.config.allowUnfree = true;

    # Distributed builds: hand off any x86_64-linux derivation to catjailer.
    # Why: wallfacer is aarch64-darwin and physically cannot realize
    # x86_64-linux closures. catjailer is the always-on Linux box in the
    # fleet, so it builds for itself, sisyphus, and swordholder.
    #
    # Without this, `nh os switch -H swordholder` from wallfacer fails at
    # the build phase because nh uses `nix build` (which has no
    # --build-host), and you have to ssh to catjailer and run from there.
    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        # hostName is plain — port goes into the system SSH config below.
        # The `[host]:port` notation is reserved for IPv6 addresses and
        # blows up nix's store-URL parser as `ssh-ng://faa@[host]:port`.
        hostName = "catjailer";
        # i686-linux is included because NixOS x86_64-linux hosts
        # auto-add it to extra-platforms (x86_64 CPUs natively execute
        # 32-bit binaries). Without it here, wallfacer's daemon won't
        # delegate 32-bit derivations (eg. nvidia's 32-bit graphics
        # libs) to catjailer and tries to build them on aarch64-darwin,
        # which fails with "platform mismatch".
        systems = [
          "x86_64-linux"
          "i686-linux"
          "aarch64-linux"
        ];
        sshUser = "faa";
        # The nix daemon runs as root; this key must therefore be
        # readable by root. On macOS, root can read any file regardless
        # of POSIX mode, so pointing at the user's own ed25519 works.
        # If a Full Disk Access prompt appears for nix-daemon, grant it.
        sshKey = "/Users/daaaa/.ssh/id_ed25519";
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

    # System-wide SSH config for the nix daemon (runs as root, doesn't
    # read ~daaaa/.ssh/config). Sets the :22022 port for any builder
    # host in the fleet. Mirrors the per-user matchBlock at
    # modules/home/core/ssh.nix.
    environment.etc."ssh/ssh_config.d/100-nix-builders.conf".text = ''
      Host catjailer catjailer.* sisyphus sisyphus.* swordholder swordholder.*
        Port 22022
        User faa
        StrictHostKeyChecking accept-new
    '';
  };
}
