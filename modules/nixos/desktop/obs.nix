{
  flake.modules.nixos.obs =
    { pkgs, ... }:
    {
      programs.droidcam.enable = true;

      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [ droidcam-obs ];
      };
    };
}
