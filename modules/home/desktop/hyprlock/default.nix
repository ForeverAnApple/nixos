{
  flake.modules.homeManager.hyprlock =
    {
      pkgs,
      ...
    }:
    {
      # hyprlock is a screen locker for Wayland
      # This module adds the hyprlock package and configures it with
      # a blurred screenshot background, clock widget, and password input
      # The Inter font is required by hyprlock.conf
      home.packages = with pkgs; [
        hyprlock
        inter
      ];

      xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
      xdg.configFile."hypr/hyprlock.png".source = ./hyprlock.png;

      systemd.user.services.hyprlock = {
        Unit = {
          Description = "Hyprlock screen locker";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          X-SwitchMethod = "keep-old";
        };
        Service = {
          ExecStart = "${pkgs.hyprlock}/bin/hyprlock";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };
    };
}
