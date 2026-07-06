{ inputs, ... }:
{
  flake.modules.darwin.system-defaults = {
    # Surface the git rev that built this system in `darwin-version`.
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # nix-darwin's manual still passes --toc-depth, removed from
    # nixos-render-docs in nixpkgs unstable; re-enable when upstream fixes it.
    # The uninstaller embeds a vanilla system that rebuilds the manual too.
    documentation.doc.enable = false;
    system.tools.darwin-uninstaller.enable = false;

    security.pam.services.sudo_local = {
      touchIdAuth = true;
      watchIdAuth = true;
    };

    system.defaults = {
      dock = {
        autohide = true;
        show-recents = false;
      };

      finder.AppleShowAllExtensions = true;

      loginwindow.GuestEnabled = false;

      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };
  };
}
