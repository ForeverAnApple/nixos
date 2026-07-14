{ config, ... }:
{
  flake.modules.homeManager."homes/wallfacer" =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      open-interpreter = pkgs.symlinkJoin {
        name = "open-interpreter-0.0.23";
        paths = [ inputs.open-interpreter-darwin-aarch64 ];
        meta = {
          description = "Coding agent optimized for low-cost models";
          homepage = "https://www.openinterpreter.com";
          license = lib.licenses.asl20;
          mainProgram = "interpreter";
          platforms = [ "aarch64-darwin" ];
          sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        };
      };
    in
    {
      home.username = "daaaa";
      home.homeDirectory = "/Users/daaaa";

      home.packages = [ open-interpreter ];

      imports = with config.flake.modules.homeManager; [
        dev
        kitty
      ];

      # The shared kitty module sets font_size = 10, which looks fine on the
      # Linux Hi-DPI hosts but is uncomfortably small on macOS Retina. Bump
      # it just for this host (mkForce because the shared module sets a
      # plain value at the same priority).
      programs.kitty.settings.font_size = lib.mkForce 14;

      # Auto-open a local herdr tab and a catjailer SSH tab on launch.
      # `launch` with no command runs the login shell, which auto-starts
      # herdr (see herdr.nix). The names come from the session, but the
      # shared cwd-basename tab_title_template ignores them, so swap to
      # {title} here — unnamed tabs then show their program title instead.
      programs.kitty.settings.startup_session = "${pkgs.writeText "wallfacer.session" ''
        new_tab wallfacer
        launch

        new_tab catjailer
        launch ssh catjailer
      ''}";
      programs.kitty.settings.tab_title_template = lib.mkForce "{title}";
    };
}
