# Home Manager module for hypridle idle daemon
# Automatically locks the screen after 5 minutes of inactivity
# Turns off monitors after 5.5 minutes
# Designed for Niri compositor on Wayland
{
  flake.modules.homeManager.hypridle =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.hypridle ];

      xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;

      systemd.user.services.hypridle = {
        Unit = {
          Description = "Hypridle idle daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.hypridle}/bin/hypridle";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
