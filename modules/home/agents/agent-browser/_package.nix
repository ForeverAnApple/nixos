{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  src,
  # When set, bakes AGENT_BROWSER_EXECUTABLE_PATH into the binary via a
  # wrapper so `home.sessionVariables` isn't a hard prerequisite (the env
  # var would otherwise be missed by anything invoked outside an HM-sourced
  # shell — systemd user units, GUI launchers, `nix run`, ...).
  chromeBin ? null,
}:

let
  manifest = (lib.importTOML "${src}/cli/Cargo.toml").package;
  inherit (manifest) version;

  # Upstream ships prebuilt binaries per platform on each release. macOS gets
  # a normal dynamic Mach-O; Linux gets a statically-linked musl build, which
  # sidesteps patchelf and glibc-version drift entirely.
  assets = {
    aarch64-darwin = {
      suffix = "darwin-arm64";
      hash = "sha256-pwP9m3SDbShJz9besnnl2N3Ldoqns9nAA1IWbLkwdXo=";
    };
    x86_64-darwin = {
      suffix = "darwin-x64";
      hash = "sha256-dILPyn9Vu4dKZJJH1dnCIMQEvlJ+bw4Bw2hhlJqemWk=";
    };
    aarch64-linux = {
      suffix = "linux-musl-arm64";
      hash = "sha256-E4ERDlTA2ebG3EoKfpemTeSnu01rwGfeLgkclAcA50E=";
    };
    x86_64-linux = {
      suffix = "linux-musl-x64";
      hash = "sha256-lHJdpyw4zpMRGKD6O+MU3sU1AQCvZFNBrx6XJ3voigs=";
    };
  };

  asset =
    assets.${stdenvNoCC.hostPlatform.system}
      or (throw "agent-browser: no prebuilt binary for ${stdenvNoCC.hostPlatform.system}");

  binary = fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/agent-browser-${asset.suffix}";
    inherit (asset) hash;
  };
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
    platforms = builtins.attrNames assets;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
