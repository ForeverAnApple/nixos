{
  flake.modules.nixos.niri =
    { inputs, pkgs, ... }:
    {
      nixpkgs.overlays = [
        # nixpkgs removed libdisplay-info_0_2; niri builds against 0.3 but
        # niri-flake still asserts version 0.2.0. Drop when upstream catches up.
        (final: prev: {
          libdisplay-info_0_2 = final.libdisplay-info_0_3 // {
            version = "0.2.0";
          };
        })
        inputs.niri.overlays.niri
      ];

      imports = [
        inputs.niri.nixosModules.niri
      ];

      programs = {
        niri = {
          enable = true;
          package = pkgs.niri-unstable;
        };
      };

      xdg.portal.config = {
        niri.default = [
          "gtk"
          "gnome"
        ];
      };
    };
}
