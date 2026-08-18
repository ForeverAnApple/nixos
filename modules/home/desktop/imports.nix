{ config, ... }:
{
  flake.modules.homeManager.desktop.imports = with config.flake.modules.homeManager; [
    anki
    imv
    firefox
    fuzzel
    hypridle
    hyprlock
    kitty
    mako
    nautilus
    niri
    obsidian
    screencast
    spotify
    swaybg
    waybar
    wlsunset
    yazi
  ];
}
