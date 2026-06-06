{ inputs, ... }:
let
  # Skip the bundled "Chrome for Testing" download — its prebuilt binary
  # can't run on NixOS without patchelf / nix-ld glue. Bake a default into
  # the wrapped binary; the env var still overrides per invocation.
  chromeBinFor =
    pkgs:
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    else
      pkgs.lib.getExe pkgs.chromium;

  binaryFor =
    pkgs:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      input =
        {
          aarch64-darwin = "agent-browser-darwin-aarch64";
          x86_64-darwin = "agent-browser-darwin-x86_64";
          aarch64-linux = "agent-browser-linux-aarch64";
          x86_64-linux = "agent-browser-linux-x86_64";
        }
        .${system} or (throw "agent-browser: no prebuilt binary for ${system}");
    in
    inputs.${input};

  packageFor =
    pkgs:
    pkgs.callPackage ./_package.nix {
      src = inputs.agent-browser-src;
      binary = binaryFor pkgs;
      chromeBin = chromeBinFor pkgs;
    };
in
{
  flake.modules.homeManager.agent-browser =
    { pkgs, ... }:
    {
      home.packages = [ (packageFor pkgs) ];
      # Surface the default in the shell too, so users can `echo $AGENT_…` to
      # see what their wrapper picked, and override it ad-hoc by re-exporting.
      home.sessionVariables.AGENT_BROWSER_EXECUTABLE_PATH = chromeBinFor pkgs;
    };

  # Expose the package at the flake level so `nix build .#agent-browser`
  # rebuilds just the CLI without rebuilding a whole home generation.
  perSystem =
    { pkgs, ... }:
    {
      packages.agent-browser = packageFor pkgs;
    };
}
