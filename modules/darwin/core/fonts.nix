{
  flake.modules.darwin.fonts =
    { pkgs, ... }:
    {
      # Installs into `/Library/Fonts/Nix Fonts/`. Mirrors the nerd-font set
      # the NixOS hosts pull via `pkgs.nerd-fonts.{hack,iosevka}` so kitty's
      # "Hack Nerd Font" and obsidian's "Iosevka Nerd Font" resolve on darwin.
      fonts.packages = with pkgs; [
        nerd-fonts.hack
        nerd-fonts.iosevka
      ];
    };
}
