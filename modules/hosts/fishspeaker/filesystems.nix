{
  flake.modules.nixos."nixosConfigurations/fishspeaker" = { ... } : {
    
    fileSystems."/" =
      { device = "/dev/disk/by-uuid/105ec169-951f-44be-a5a1-4d02a358a960";
        fsType = "ext4";
      };

    boot.initrd.luks.devices."luks-d342d12f-cb15-45eb-8704-ca58e3238abc".device = "/dev/disk/by-uuid/d342d12f-cb15-45eb-8704-ca58e3238abc";

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/AA9E-51F5";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    # swapDevices =
    #   [ { device = "/dev/disk/by-uuid/5f9d9d02-845c-4857-b771-a453a32c6f9a"; }
    #   ];
    environment.etc.crypttab = {
      mode = "0600";
      text = ''
        swap UUID=71c7df5a-2fe5-4a2d-8de0-5b251cefedde /root/swappart.key swap
      '';
    };
    swapDevices =
      [ { device = "/dev/mapper/swap"; }
      ];

  };
}
