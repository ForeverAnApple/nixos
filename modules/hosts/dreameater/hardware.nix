{
  flake.modules.nixos."hosts/dreameater" =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        initrd = {
          availableKernelModules = [
            "virtio_pci"
            "virtio_blk"
            "virtio_net"
            "virtio_scsi"
            "sd_mod"
          ];

          kernelModules = [ ];
        };

        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
      };

      # The VM boots legacy BIOS; core/bootloader.nix assumes UEFI.
      boot.loader = {
        systemd-boot.enable = lib.mkForce false;
        efi.canTouchEfiVariables = lib.mkForce false;
        grub.enable = true;
      };

      networking.useDHCP = lib.mkDefault false;

      # The provider image boots with net.ifnames=0 and the address profile is bound to eth0.
      networking.usePredictableInterfaceNames = false;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
