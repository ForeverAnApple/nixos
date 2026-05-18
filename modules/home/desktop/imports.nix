{ config, ... }:
{
  flake.modules.homeManager.desktop.imports = with config.flake.modules.homeManager; [
    anki
    imv
    mpv
    firefox
    fuzzel
    hypridle
    hyprlock
    hyprpaper
    kitty
    mako
    nautilus
    niri
    obsidian
    screencast
    spotifyPlayer
    waybar
    wlsunset
    yazi
  ];
}
