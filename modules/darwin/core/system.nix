{ inputs, ... }:
{
  flake.modules.darwin.system-defaults = {
    # Surface the git rev that built this system in `darwin-version`.
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

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

      # macOS dispatches ⌘H/⌥⌘H to the app menu before Moonlight's SDL window
      # can forward them to the stream; rebind the menu items out of the way.
      CustomUserPreferences."com.moonlight-stream.Moonlight".NSUserKeyEquivalents = {
        "Hide Moonlight" = "@~^h";
        "Hide Others" = "@~^$h";
      };
    };
  };
}
