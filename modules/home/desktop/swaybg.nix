{
  flake.modules.homeManager.swaybg =
    { pkgs, config, ... }:
    {
      systemd.user.services.swaybg = {
        Unit = {
          Description = "Wallpaper daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg --image ${config.home.homeDirectory}/Pictures/wallpaper --mode fill";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
