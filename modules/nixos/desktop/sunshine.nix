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

        # The web UI is reached over the tailnet, not localhost, so its CSRF
        # guard rejects the pairing POST unless the tailnet origins are trusted.
        settings.csrf_allowed_origins =
          "https://100.64.0.7:47990,https://[fd7a:115c:a1e0::7]:47990,https://catjailer:47990,https://catjailer.jura.moe:47990";

        # Declarative apps: this replaces the web-UI-managed apps.json, so app
        # edits must happen here, not in the UI. No app mutates the live output
        # mode — runtime mode-flips race niri's auto-scale and corrupt the
        # output, which thrashes the capture. For a lower-res stream, set the
        # resolution in the Moonlight client; Sunshine scales the 4K capture.
        applications = {
          env.PATH = "$(PATH):$(HOME)/.local/bin";
          apps = [
            {
              name = "Desktop";
              image-path = "desktop.png";
            }
            {
              name = "Steam Big Picture";
              image-path = "steam.png";
              detached = [ "setsid steam steam://open/bigpicture" ];
              prep-cmd = [
                {
                  do = "";
                  undo = "setsid steam steam://close/bigpicture";
                }
              ];
            }
          ];
        };
      };

      # Backstop: a capture reinit loop leaks FDs fast; the default 1024 soft
      # limit exhausts in seconds and drops the client. Give it headroom.
      systemd.user.services.sunshine.serviceConfig.LimitNOFILE = 65536;

      # Sunshine injects client input through /dev/uinput; without group access
      # the video streams but mouse/keyboard do nothing.
      hardware.uinput.enable = true;
      users.users.faa.extraGroups = [ "input" ];
      services.udev.extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="input"
      '';
    };
}
