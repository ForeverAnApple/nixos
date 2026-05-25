{
  flake.modules.nixos."hosts/swordholder" =
    { config, pkgs, ... }:
    {
      hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;

      hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];

      hardware.nvidia-container-toolkit.enable = true;
    };
}
