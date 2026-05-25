{
  flake.modules.nixos.nvidia =
    { config, lib, ... }:
    {
      hardware.graphics.enable = true;

      services.xserver.videoDrivers = [ "nvidia" ];

      # Proprietary > nvidia-open: nvidia-open regresses QtWebEngine on the desktop
      # and sustained NVENC on the server.
      hardware.nvidia = {
        modesetting.enable = true;
        open = lib.mkDefault false;
        package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
        powerManagement.enable = lib.mkDefault false;
      };

      nixpkgs.overlays = [
        (_: prev: { btop = prev.btop.override { cudaSupport = true; }; })
      ];
    };
}
