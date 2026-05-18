{
  flake.modules.nixos.desktop =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        libnotify
        brightnessctl
        nautilus
        pamixer
        playerctl
      ];
    };
}
