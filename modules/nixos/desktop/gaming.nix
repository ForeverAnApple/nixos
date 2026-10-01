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
          # gamescope 3.16.24 links sdl2-compat, which dlopens libSDL3 at
          # startup; SDL3 is not in its closure, so without this it core-dumps.
          extraPkgs = pkgs: [
            pkgs.gamescope
            pkgs.sdl3
          ];
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
