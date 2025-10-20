{
  flake.modules.nixos.kmscon = { pkgs, ... }: {

    # Enable kmscon and utilize keyboard configs
    # I literally cannot use a text editor without escape swap lmao
    services = {
      xserver.xkb = {
        options = "caps:swapescape";
        layout = "us";
        variant = "";
      };
      kmscon = {
        enable = true;
        useXkbConfig = true;
        hwRender = true;
        fonts = [{
          name = "Hack Nerd Font";
          package = pkgs.nerd-fonts.hack;
        }];
      };
    };

    # Also add the pretty fonts
    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
      powerline-symbols
      noto-fonts-emoji
    ];
  };
}
