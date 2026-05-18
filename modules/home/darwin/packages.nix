# Darwin-only home-manager packages. Kept separate from
# modules/home/core/packages.nix so the cross-platform set evaluates on Linux
# without tripping nixpkgs platform checks (home-manager's fontconfig module
# walks every home.packages entry to discover fonts, forcing derivation
# evaluation — `terminal-notifier` is darwin-only and refuses to evaluate on
# x86_64-linux otherwise).
{
  flake.modules.homeManager.darwin-packages =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.btop
        pkgs.terminal-notifier
      ];
    };
}
