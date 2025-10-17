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
  };
}
