{ inputs, ... }:
{
  flake.modules.homeManager.agent-browser =
    { lib, pkgs, ... }:
    let
      # Skip the bundled "Chrome for Testing" download — its prebuilt binary
      # can't run on NixOS without patchelf / nix-ld glue. Bake a default into
      # the wrapped binary; the env var still overrides per invocation.
      chromeBin =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        else
          lib.getExe pkgs.chromium;
      agent-browser = pkgs.callPackage ./_package.nix {
        src = inputs.agent-browser-src;
        inherit chromeBin;
      };
    in
    {
      home.packages = [ agent-browser ];
      # Surface the default in the shell too, so users can `echo $AGENT_…` to
      # see what their wrapper picked, and override it ad-hoc by re-exporting.
      home.sessionVariables.AGENT_BROWSER_EXECUTABLE_PATH = chromeBin;
    };

  # Expose the package at the flake level so `nix build .#agent-browser`
  # rebuilds just the CLI without rebuilding a whole home generation. Wrapped
  # the same way the HM module wraps it, so `nix run` and direct invocations
  # of the store path Just Work without any shell-env prerequisites.
  perSystem =
    { lib, pkgs, ... }:
    {
      packages.agent-browser = pkgs.callPackage ./_package.nix {
        src = inputs.agent-browser-src;
        chromeBin =
          if pkgs.stdenv.hostPlatform.isDarwin then
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
          else
            lib.getExe pkgs.chromium;
      };
    };
}
