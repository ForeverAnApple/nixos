{
  flake.modules.nixos.keyd = {
    # Swap caps/escape only on the built-in laptop keyboard.
    # keyd operates at evdev level (before Wayland/XKB), so it works
    # everywhere: niri, kmscon TTY, etc. External keyboards are untouched.
    services.keyd = {
      enable = true;
      keyboards = {
        laptop = {
          ids = [ "0001:0001" ]; # AT Translated Set 2 keyboard
          settings = {
            main = {
              capslock = "escape";
              escape = "capslock";
            };
          };
        };
      };
    };
  };
}
