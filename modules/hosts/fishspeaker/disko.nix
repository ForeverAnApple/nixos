{
  flake.modules.nixos."hosts/fishspeaker" = {
    boot.supportedFilesystems = [ "zfs" ];
    networking.hostId = "ada03dbb";
    disko.devices = {
      disk = {
        nvme0n1 = {
          device = "/dev/nvme0n1";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
      zpool = {
        zroot = {
          type = "zpool";
          rootFsOptions = {
            mountpoint = "none";
            compression = "zstd";
            acltype = "posixacl";
            xattr = "sa";
            "com.sun:auto-snapshot" = "true";
          };
          options.ashift = "12";
          datasets = {
            "root" = {
              type = "zfs_fs";
              options = {
                encryption = "aes-256-gcm";
                keyformat = "passphrase";
                keylocation = "prompt";
		mountpoint = "none";
              };
            };
            "root/nixos" = {
              type = "zfs_fs";
              options.mountpoint = "/";
              mountpoint = "/";
            };
            "root/home" = {
              type = "zfs_fs";
              options.mountpoint = "/home";
              mountpoint = "/home";
            };
            "root/nix" = {
              type = "zfs_fs";
              options.mountpoint = "/nix";
              mountpoint = "/nix";
            };

	    # README MORE: https://wiki.archlinux.org/title/ZFS#Swap_volume
            "root/swap" = {
              type = "zfs_volume";
              size = "16384M";
              content = {
                type = "swap";
              };
              options = {
                volblocksize = "4096";
                compression = "zle";
                logbias = "throughput";
                sync = "always";
                primarycache = "metadata";
                secondarycache = "none";
                "com.sun:auto-snapshot" = "false";
              };
            };
          };
        };
      };
    };
  };
}
