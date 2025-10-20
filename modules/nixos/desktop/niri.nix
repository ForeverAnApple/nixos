{
  flake.modules.nixos.niri = { inputs, pkgs, ... }: {
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

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
      niri.default = [ "gtk" "gnome" ];
    };
  };
}
