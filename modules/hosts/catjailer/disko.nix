{
  flake.modules.nixos."hosts/catjailer" = {
    networking.hostId = "b7c4e1a2";

    disko.devices = {
      disk = {
        fast-cow = {
          type = "disk";
          device = "/dev/disk/by-id/ata-ADATA_SP600_2E4420035599";
          content = {
            type = "gpt";
            partitions = {
              data = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/fast-cow";
                  mountOptions = [
                    "defaults"
                    "x-gvfs-show"
                    "x-gvfs-name=Fast-Cow"
                  ];
                };
              };
            };
          };
        };

        alpha-oguri = {
          type = "disk";
          device = "/dev/disk/by-id/ata-Crucial_CT275MX300SSD1_1742194411F6";
          content = {
            type = "gpt";
            partitions = {
              data = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/alpha-oguri";
                  mountOptions = [
                    "defaults"
                    "x-gvfs-show"
                    "x-gvfs-name=Alpha-Oguri"
                  ];
                };
              };
            };
          };
        };

        omega-beef = {
          type = "disk";
          device = "/dev/disk/by-id/ata-ST2000DM006-2DM164_Z4ZA15NG";
          content = {
            type = "gpt";
            partitions = {
              data = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/omega-beef";
                  mountOptions = [
                    "defaults"
                    "nofail"
                    "x-gvfs-show"
                    "x-gvfs-name=Omega-Beef"
                  ];
                };
              };
            };
          };
        };

        theta-beef = {
          type = "disk";
          device = "/dev/disk/by-id/ata-WDC_WD30EZRX-00D8PB0_WD-WCC4N6RUJCRL";
          content = {
            type = "gpt";
            partitions = {
              data = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/theta-beef";
                  mountOptions = [
                    "defaults"
                    "nofail"
                    "x-gvfs-show"
                    "x-gvfs-name=Theta-Beef"
                  ];
                };
              };
            };
          };
        };
      };
    };

    boot.initrd.luks.devices."luks-caa4b2df-d195-4fc6-b7e7-b327941722e1" = {
      device = "/dev/disk/by-uuid/caa4b2df-d195-4fc6-b7e7-b327941722e1";
      allowDiscards = true;
    };
    boot.initrd.luks.devices."luks-c2c6542b-5e7c-42ff-be6f-bb61e004faa9" = {
      device = "/dev/disk/by-uuid/c2c6542b-5e7c-42ff-be6f-bb61e004faa9";
      allowDiscards = true;
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/f2174243-7b9b-4e2c-b3d8-397836b8f321";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/FC96-6303";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/cd498e66-a389-46b7-be01-5e65769627da"; }
    ];
  };
}
