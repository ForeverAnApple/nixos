{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        xwayland-satellite
        vrcft
      ];

      programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          extraPkgs = pkgs: [ pkgs.gamescope ];
        };
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
        extraPackages = with pkgs; [
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-ugly
          gst_all_1.gst-libav
        ];
      };
    };
}
