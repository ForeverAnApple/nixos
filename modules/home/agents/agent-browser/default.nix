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

  packageFor =
    pkgs: browserPackage:
    pkgs.symlinkJoin {
      name = "agent-browser-${browserPackage.version}";
      paths = [ browserPackage ];
      nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
      postBuild = ''
        wrapProgram $out/bin/agent-browser \
          --set-default AGENT_BROWSER_EXECUTABLE_PATH ${pkgs.lib.escapeShellArg (chromeBinFor pkgs)}
      '';
      meta = browserPackage.meta;
    };
in
{
  flake.modules.homeManager.agent-browser =
    { pkgs, ... }:
    {
      home.packages = [ (packageFor pkgs pkgs.agent-browser) ];
    };

  # Expose the package at the flake level so `nix build .#agent-browser`
  # rebuilds just the CLI without rebuilding a whole home generation.
  perSystem =
    { pkgs, system, ... }:
    let
      masterPkgs = import inputs.nixpkgs-master {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages.agent-browser = packageFor pkgs masterPkgs.agent-browser;
    };
}
