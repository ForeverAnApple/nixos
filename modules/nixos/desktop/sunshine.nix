{
  flake.modules.nixos.sunshine =
    { ... }:
    {
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = false;
        settings.capture = "wlr";

        # No openFirewall: ports stay tailnet-only, off enp4s0.

        # Web UI is reached over the tailnet, so CSRF needs those origins trusted.
        settings.csrf_allowed_origins = "https://100.64.0.7:47990,https://[fd7a:115c:a1e0::7]:47990,https://catjailer:47990,https://catjailer.jura.moe:47990";

        # Apps are declarative here, not in the web UI. "Low Res Desktop" flips
        # DP-1 to native 1080p, restoring 4K on disconnect. Only ever change the
        # output in prep-cmd (before capture) — never mid-stream.
        applications = {
          env.PATH = "$(PATH):$(HOME)/.local/bin";
          apps = [
            {
              name = "Desktop";
              image-path = "desktop.png";
            }
            {
              name = "Low Res Desktop";
              image-path = "desktop.png";
              prep-cmd = [
                {
                  do = "niri msg output DP-1 mode 1920x1080@60.000 && niri msg output DP-1 scale 1.0";
                  undo = "niri msg output DP-1 mode 3840x2160@59.997 && niri msg output DP-1 scale 1.25";
                }
              ];
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

      # Backstop: a capture-reinit FD leak blows past the 1024 default and drops the client.
      systemd.user.services.sunshine.serviceConfig.LimitNOFILE = 65536;
      systemd.user.services.sunshine.environment.LD_LIBRARY_PATH = "/run/opengl-driver/lib";

      # Sunshine feeds client input through /dev/uinput; without group access,
      # video streams but mouse/keyboard are dead.
      hardware.uinput.enable = true;
      users.users.faa.extraGroups = [ "uinput" ];
    };
}
