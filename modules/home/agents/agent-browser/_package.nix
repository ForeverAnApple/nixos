{
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  src,
  # Prebuilt release executable for this platform, fetched as a flake input
  # (see flake.nix). macOS gets a dynamic Mach-O; Linux gets a statically
  # linked musl build, which sidesteps patchelf and glibc-version drift.
  binary,
  # When set, bakes AGENT_BROWSER_EXECUTABLE_PATH into the binary via a
  # wrapper so `home.sessionVariables` isn't a hard prerequisite (the env
  # var would otherwise be missed by anything invoked outside an HM-sourced
  # shell — systemd user units, GUI launchers, `nix run`, ...).
  chromeBin ? null,
}:

let
  manifest = (lib.importTOML "${src}/cli/Cargo.toml").package;
  inherit (manifest) version;
in
stdenvNoCC.mkDerivation {
  pname = manifest.name;
  inherit version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = lib.optional (chromeBin != null) makeBinaryWrapper;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${binary} $out/bin/agent-browser

    # The CLI's `find_package_root` walks `../skills` and `../skill-data`
    # from the executable. Without these dirs alongside, every `skills`
    # subcommand fails with "Skills directory not found".
    cp -r ${src}/skills      $out/skills
    cp -r ${src}/skill-data  $out/skill-data

    runHook postInstall
  '';

  postInstall = lib.optionalString (chromeBin != null) ''
    wrapProgram $out/bin/agent-browser \
      --set-default AGENT_BROWSER_EXECUTABLE_PATH ${lib.escapeShellArg chromeBin}
  '';

  meta = {
    description = "Fast browser-automation CLI for AI coding agents";
    homepage = "https://agent-browser.dev";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
