{
  flake.modules.nixos."hosts/swordholder" =
    { config, pkgs, ... }:
    {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        # Proprietary still beats nvidia-open for sustained NVENC under load (2026).
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.production;
        modesetting.enable = true;
        powerManagement.enable = false;
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
      };

      hardware.nvidia-container-toolkit.enable = true;
    };
}
