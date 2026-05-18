{
  flake.modules.nixos."hosts/sisyphus" =
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
        # Use latest linux kernel
        kernelPackages = pkgs.linuxPackages_latest;

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

        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
      };

      # Bring the WAN NIC up via systemd-networkd in initrd so the operator
      # can SSH in to unlock LUKS before stage 2. Match by glob so we don't
      # bake a NIC name into the repo; Vultr provides DHCP.
      boot.initrd.systemd.network = {
        enable = true;
        networks."10-wan" = {
          matchConfig.Name = "en*";
          networkConfig.DHCP = "ipv4";
        };
      };

      networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
