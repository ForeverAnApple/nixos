{
  flake.modules.nixos.kmscon =
    { pkgs, ... }:
    {

      # Enable kmscon and utilize keyboard configs
      # caps/escape swap handled by keyd (per-device, laptop only)
      services = {
        xserver.xkb = {
          layout = "us";
          variant = "";
        };
        kmscon = {
          enable = true;
          useXkbConfig = true;
          config = {
            hwaccel = true;
            font-name = "Hack Nerd Font";
          };
        };
      };

      hardware.graphics.enable = true;

      # Also add the pretty fonts
      fonts.packages = with pkgs; [
        nerd-fonts.hack
        nerd-fonts.symbols-only
        powerline-symbols
        noto-fonts-color-emoji
      ];
    };
}
