{
  flake.modules.nixos."hosts/swordholder" =
    { lib, pkgs, ... }:
    {
      services.smartd = {
        enable = true;
        autodetect = true;
        notifications.wall.enable = true;
      };

      services.samba = {
        enable = true;
        openFirewall = true;
        settings = {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "swordholder";
            "security" = "user";
            "map to guest" = "never";
            "passdb backend" = "tdbsam";
            "server min protocol" = "SMB3";
            "server signing" = "mandatory";
            "smb encrypt" = "required";
            # Keeps macOS Finder from littering ._ AppleDouble files.
            "vfs objects" = "catia fruit streams_xattr";
            "fruit:metadata" = "stream";
            "fruit:model" = "MacSamba";
            "fruit:posix_rename" = "yes";
            "fruit:veto_appledouble" = "no";
            "fruit:wipe_intentionally_left_blank_rfork" = "yes";
            "fruit:delete_empty_adfiles" = "yes";
          };

          THICC = {
            path = "/THICC/THICC";
            comment = "Main sharing tree";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "force group" = "+audiobookshelf";
          };
          Plex = {
            path = "/THICC/Plex";
            comment = "Holds only plex stuffs";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
          };
          SHARED = {
            path = "/THICC/SHARED";
            comment = "SHARED BETWEEN ALL";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
          };
          Finn = {
            path = "/THICC/Finn";
            comment = "Finn use only.";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "valid users" = "finn faa";
          };
          Noah = {
            path = "/THICC/Noah";
            comment = "Noah use only.";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "valid users" = "noah faa";
          };
        };
      };

      services.samba-wsdd = {
        enable = true;
        openFirewall = true;
      };
      services.avahi = {
        enable = true;
        openFirewall = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      services.plex = {
        enable = true;
        openFirewall = true;
        dataDir = "/var/lib/plex";
        user = "plex";
        group = "plex";
      };

      fileSystems."/media" = {
        device = "/THICC/Plex";
        fsType = "none";
        options = [
          "bind"
          "x-systemd.automount"
        ];
      };

      systemd.services.plex.serviceConfig = {
        TimeoutStopSec = 10;
        NoNewPrivileges = lib.mkForce true;
        ProtectSystem = lib.mkForce "strict";
        ProtectHome = lib.mkForce true;
        ProtectKernelTunables = lib.mkForce true;
        ProtectKernelModules = lib.mkForce true;
        ProtectControlGroups = lib.mkForce true;
        ProtectClock = lib.mkForce true;
        ProtectHostname = lib.mkForce true;
        RestrictRealtime = lib.mkForce true;
        LockPersonality = lib.mkForce true;
        PrivateTmp = lib.mkForce true;
        # No PrivateDevices — Plex needs /dev/dri for HW transcode.
        # /media is the same inodes as /THICC/Plex via bind mount, but
        # systemd matches ReadWritePaths by literal path, so list both.
        ReadWritePaths = [
          "/var/lib/plex"
          "/THICC/Plex"
          "/media"
        ];
      };
    };
}
