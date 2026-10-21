{
  flake.modules.nixos.niri =
    { lib, pkgs, ... }:
    {
      programs = {
        niri = {
          enable = true;
        };
      };

      systemd.user.services.niri-polkit = {
        description = "PolicyKit Authentication Agent";
        wantedBy = [ "niri.service" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      xdg.portal.config = {
        niri.default = lib.mkForce [
          "gtk"
          "gnome"
        ];
      };
    };
}
