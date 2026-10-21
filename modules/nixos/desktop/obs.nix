{
  flake.modules.nixos.obs =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: prev: {
          linuxPackages = prev.linuxPackages.extend (
            _: kernelPrev: {
              v4l2loopback = kernelPrev.v4l2loopback.overrideAttrs (old: {
                # NixOS generates depmod indexes after merging all kernel modules.
                makeFlags = (old.makeFlags or [ ]) ++ [ "DEPMOD=true" ];
              });
            }
          );
        })
      ];

      programs.droidcam.enable = true;

      programs.obs-studio = {
        enable = true;
        package = pkgs.obs-studio.override { cudaSupport = true; };
        plugins = with pkgs.obs-studio-plugins; [ droidcam-obs ];
      };
    };
}
