{
  flake.modules.nixos."hosts/swordholder" = {
    boot.supportedFilesystems = [ "zfs" ];

    boot.zfs = {
      devNodes = "/dev/disk/by-id";
      extraPools = [ "THICC" ];
      forceImportRoot = false;
      forceImportAll = false;
    };

    # Do NOT `zpool upgrade THICC` — burns the one-way rollback option.
    services.zfs.autoScrub = {
      enable = true;
      interval = "Sun *-*-* 03:00:00";
      pools = [ "THICC" ];
    };

    services.zfs.trim.enable = true;
    services.zfs.zed.enableMail = false;
  };
}
