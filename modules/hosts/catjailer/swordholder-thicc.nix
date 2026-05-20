{
  flake.modules.nixos."hosts/catjailer" =
    { pkgs, ... }:
    {
      sops.secrets."smb/thicc_creds" = {
        path = "/etc/.smbcreds-thicc";
        mode = "0600";
        owner = "root";
        group = "root";
      };

      environment.systemPackages = [ pkgs.cifs-utils ];

      fileSystems."/mnt/swordholder-thicc" = {
        device = "//swordholder/THICC";
        fsType = "cifs";
        options = [
          "credentials=/etc/.smbcreds-thicc"
          "uid=1000"
          "gid=100"
          "file_mode=0664"
          "dir_mode=0775"
          "iocharset=utf8"
          "vers=3.1.1"
          "seal"
          "rsize=1048576"
          "wsize=1048576"
          "nofail"
          "_netdev"
          "x-systemd.automount"
          "noauto"
        ];
      };
    };
}
