# Darwin-only home-manager packages. Kept separate from
# modules/home/core/packages.nix so the cross-platform set evaluates on Linux
# without tripping nixpkgs platform checks (home-manager's fontconfig module
# walks every home.packages entry to discover fonts, forcing derivation
# evaluation — `terminal-notifier` is darwin-only and refuses to evaluate on
# x86_64-linux otherwise).
{
  flake.modules.homeManager.darwin-packages =
    { pkgs, ... }:
    let
      # Upstream's prebuilt signed app; the from-source build SIGTRAPs
      # current cctools ld and isn't cached for this nixpkgs pin.
      terminal-notifier = pkgs.stdenvNoCC.mkDerivation {
        pname = "terminal-notifier";
        version = "2.0.0";
        src = pkgs.fetchzip {
          url = "https://github.com/julienXX/terminal-notifier/releases/download/2.0.0/terminal-notifier-2.0.0.zip";
          hash = "sha256-YMFO/pg41FDXBrqdwpgxGkDUii5zfNp9ni5EKNImJT4=";
        };
        installPhase = ''
          mkdir -p $out/Applications $out/bin
          cp -R terminal-notifier.app $out/Applications/
          ln -s $out/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier $out/bin/terminal-notifier
        '';
      };
    in
    {
      home.packages = [
        terminal-notifier
      ];
    };
}
