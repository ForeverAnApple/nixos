# Home Manager module: skhd hotkey daemon config.
#
# The skhd binary itself (jackielii/tap/skhd-zig) is installed via brew in
# modules/darwin/core/homebrew.nix — it isn't packaged in nixpkgs (only the
# original C `skhd` is), so the brew tap remains the source of the binary.
# This module owns only the dotfile.
#
# skhd hot-reloads ~/.config/skhd/skhdrc on save, so a `nrs` is enough to
# pick up changes — no restart needed. Accessibility permission is per-binary
# (TCC anchors on cdHash), not config-driven, so it's untouched by us here.
{
  flake.modules.homeManager.skhd = {
    xdg.configFile."skhd/skhdrc".source = ./skhdrc;
  };
}
