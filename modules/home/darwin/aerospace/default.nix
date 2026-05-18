# Home Manager module: AeroSpace tiling WM config.
#
# Binary itself ships as the `aerospace` cask (modules/darwin/core/homebrew.nix);
# the cask handles the .app bundle + login agent. This module owns only the
# user config at ~/.config/aerospace/aerospace.toml.
#
# AeroSpace reloads on `aerospace reload-config` (or via the service-mode
# `esc` binding), so a `nrs` followed by either is enough — no logout needed.
{
  flake.modules.homeManager.aerospace = {
    xdg.configFile."aerospace/aerospace.toml".source = ./aerospace.toml;
  };
}
