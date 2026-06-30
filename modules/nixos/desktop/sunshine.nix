{
  flake.modules.nixos.sunshine =
    { lib, pkgs, ... }:
    {
      services.sunshine = {
        enable = true;
        autoStart = true;
        # niri is not wlroots, so the screen-capture path is KMS, which needs
        # cap_sys_admin. Without it the stream is a black frame.
        capSysAdmin = true;

        # NVENC dlopens libcuda/libnvidia-encode by bare soname, but the
        # cudaSupport build hard-sets LD_LIBRARY_PATH to vulkan-loader alone,
        # leaving the driver libs unreachable — every hardware encoder then
        # fails and Sunshine silently drops to software x264. Re-wrap with the
        # driver link appended so NVENC actually loads.
        package = (pkgs.sunshine.override { cudaSupport = true; }).overrideAttrs (_: {
          postFixup = ''
            wrapProgram $out/bin/sunshine \
              --set LD_LIBRARY_PATH ${lib.makeLibraryPath [ pkgs.vulkan-loader ]}:/run/opengl-driver/lib
          '';
        });

        # No openFirewall: the ports stay off enp4s0 and are reachable only
        # over tailscale0 (trusted interface). Remote desktop is tailnet-only.
      };

      # Sunshine injects client input through /dev/uinput; without group access
      # the video streams but mouse/keyboard do nothing.
      hardware.uinput.enable = true;
      users.users.faa.extraGroups = [ "input" ];
      services.udev.extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="input"
      '';
    };
}
