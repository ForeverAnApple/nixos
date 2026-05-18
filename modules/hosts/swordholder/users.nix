{
  flake.modules.nixos."hosts/swordholder" =
    { pkgs, ... }:
    {
      users.groups.media.gid = 8675309;
      users.groups.plex.gid = 193;
      users.users.faa.extraGroups = [ "plex" ];

      users.users = {
        plex = {
          uid = 193;
          isSystemUser = true;
          group = "plex";
          home = "/var/lib/plex";
          createHome = false;
          shell = "${pkgs.shadow}/bin/nologin";
        };

        finn = {
          uid = 1002;
          isNormalUser = true;
          createHome = false;
          home = "/var/empty";
          group = "users";
          shell = "${pkgs.shadow}/bin/nologin";
          hashedPassword = "!";
        };

        noah = {
          uid = 1003;
          isNormalUser = true;
          createHome = false;
          home = "/var/empty";
          group = "users";
          shell = "${pkgs.shadow}/bin/nologin";
          hashedPassword = "!";
        };

        vpn = {
          uid = 1001;
          isSystemUser = true;
          group = "users";
          home = "/var/empty";
          shell = "${pkgs.shadow}/bin/nologin";
        };

        media = {
          uid = 8675309;
          isSystemUser = true;
          group = "media";
          home = "/var/empty";
          shell = "${pkgs.shadow}/bin/nologin";
        };
      };
    };
}
