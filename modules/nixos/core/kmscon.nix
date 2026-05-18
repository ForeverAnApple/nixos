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
          hwRender = true;
          fonts = [
            {
              name = "Hack Nerd Font";
              package = pkgs.nerd-fonts.hack;
            }
          ];
        };
      };

      # Also add the pretty fonts
      fonts.packages = with pkgs; [
        nerd-fonts.symbols-only
        powerline-symbols
        noto-fonts-color-emoji
      ];
    };
}
