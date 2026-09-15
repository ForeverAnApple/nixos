{
  lib,
  stdenvNoCC,
  # Prebuilt release executable for this platform, fetched as a flake input
  # (see flake.nix). macOS gets a dynamic Mach-O against system frameworks
  # only; Linux gets a static-pie build, so neither needs patchelf.
  binary,
}:

stdenvNoCC.mkDerivation {
  pname = "herdr";
  version = "0.8.2";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 ${binary} $out/bin/herdr
    runHook postInstall
  '';

  meta = {
    description = "Terminal workspace manager for AI coding agents";
    homepage = "https://herdr.dev";
    license = lib.licenses.asl20;
    mainProgram = "herdr";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
