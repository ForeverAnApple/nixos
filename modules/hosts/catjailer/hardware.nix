{
  flake.modules.nixos."hosts/catjailer" =
    {
      config,
      lib,
      modulesPath,
      pkgs,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        kernelPackages = pkgs.linuxPackages_latest;

        initrd = {
          availableKernelModules = [
            "nvme"
            "xhci_pci"
            "ahci"
            "usbhid"
            "sd_mod"
          ];

          kernelModules = [ ];
        };

        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];

        # slow OEM SSD: cap flush backlog so write floods can't stall the desktop
        kernel.sysctl = {
          "vm.dirty_bytes" = 268435456;
          "vm.dirty_background_bytes" = 134217728;
        };
      };

      services.udev.extraRules = ''
        ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme*n*|sd*", ATTR{queue/scheduler}="mq-deadline"
      '';

      networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
