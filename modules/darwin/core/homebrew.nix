{
  flake.modules.darwin.homebrew =
    { lib, ... }:
    {
      # Own brew's shell integration here (HOMEBREW_* + PATH) so users
      # don't need ~/.zprofile's `eval "$(brew shellenv)"`, which would
      # prepend /opt/homebrew ahead of the Nix profiles.
      environment = {
        variables = {
          HOMEBREW_NO_ANALYTICS = "1";
          HOMEBREW_PREFIX = "/opt/homebrew";
          HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
          HOMEBREW_REPOSITORY = "/opt/homebrew";
        };

        # Explicit PATH order: Nix profiles > brew > system. mkForce
        # because nix-darwin merges profile and default entries at the
        # same priority, so plain additions can't slot brew between them.
        systemPath = lib.mkForce [
          "$HOME/.nix-profile/bin"
          "/etc/profiles/per-user/$USER/bin"
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
          "/opt/homebrew/bin"
          "/opt/homebrew/sbin"
          "/usr/local/bin"
          "/usr/bin"
          "/bin"
          "/usr/sbin"
          "/sbin"
        ];
      };

      homebrew = {
        enable = true;

        # Every rebuild fully reconciles brew with the declared state below:
        # tap refresh → bundle install (with upgrades) → cleanup uninstalls
        # anything not declared. One command (`nrs`/`u`) updates everything.
        onActivation = {
          autoUpdate = true;
          cleanup = "uninstall";
          upgrade = true;
          # Homebrew now refuses `brew bundle --cleanup` without an explicit
          # force flag; nix-darwin doesn't pass one yet, so activation aborts.
          extraFlags = [ "--force-cleanup" ];
        };

        # Third-party taps for brews/casks not on homebrew-core/cask.
        taps = [
          "felixkratz/formulae" # sketchybar
          "homebrew/services" # `brew services` for sketchybar daemon
          "jackielii/tap" # skhd-zig
          "nikitabobko/tap" # aerospace cask
        ];

        # CLIs not in nixpkgs (or whose brew build we track upstream).
        brews = [
          "felixkratz/formulae/sketchybar"
          "pnpm"
        ];

        # GUI apps. macOS .app bundles install cleaner via brew cask than
        # nixpkgs darwin GUI builds in most cases.
        casks = [
          "aerospace"
          "android-platform-tools"
          "anki"
          "antigravity"
          "arc"
          "basictex"
          "blackhole-2ch"
          "claude"
          "cursor"
          "cutter"
          "discord"
          "docker-desktop"
          "flutter"
          "google-chrome"
          "gstreamer-development"
          "gstreamer-runtime"
          "hiddenbar"
          "iterm2"
          "jackielii/tap/skhd-zig" # upstream switched formula→cask in e8fc799
          "linearmouse"
          "font-iosevka-aile" # used by obsidian; no clean nixpkgs equivalent
          "macfuse"
          "malwarebytes"
          "moonlight"
          "obs"
          "raspberry-pi-imager"
          "sf-symbols"
          "steam"
          "tailscale-app" # menu bar GUI (was renamed from `tailscale`; CLI bundled in this cask)
          "teamviewer"
          "telegram"
          "thinkorswim"
          "ubersicht"
          "veracrypt"
        ];
      };
    };
}
