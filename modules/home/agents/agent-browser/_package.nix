{
  lib,
  rustPlatform,
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
in
rustPlatform.buildRustPackage {
  pname = manifest.name;
  version = manifest.version;

  inherit src;

  # The crate lives at cli/, but cli/build.rs and rust-embed reach into
  # ../packages/dashboard/out/. So we keep the whole repo and just build the
  # subdir; the build.rs self-heals the dashboard dir with a placeholder.
  cargoRoot = "cli";
  buildAndTestSubdir = "cli";

  # Read the upstream lockfile directly so cargo vendor needs no aggregated
  # hash. `nix flake update agent-browser-src` is the only step to upgrade.
  cargoLock.lockFile = "${src}/cli/Cargo.lock";

  # Tests spawn a real Chrome daemon and bind sockets; the Nix sandbox blocks
  # both.
  doCheck = false;

  nativeBuildInputs = lib.optional (chromeBin != null) makeBinaryWrapper;

  # Ship the skill content next to the binary. The CLI's `find_package_root`
  # walks `../skills` and `../skill-data` from the executable, so dropping
  # both dirs at $out/ makes `agent-browser skills …` work without setting
  # AGENT_BROWSER_SKILLS_DIR. Without this, every skills subcommand fails
  # with "Skills directory not found. Set AGENT_BROWSER_SKILLS_DIR or
  # reinstall via npm." even though skills ship in the upstream repo.
  postInstall = ''
    cp -r ${src}/skills      $out/skills
    cp -r ${src}/skill-data  $out/skill-data
  ''
  + lib.optionalString (chromeBin != null) ''
    wrapProgram $out/bin/agent-browser \
      --set-default AGENT_BROWSER_EXECUTABLE_PATH ${lib.escapeShellArg chromeBin}
  '';

  meta = {
    description = "Fast browser-automation CLI for AI coding agents";
    homepage = "https://agent-browser.dev";
    license = lib.licenses.asl20;
    mainProgram = "agent-browser";
    platforms = lib.platforms.unix;
  };
}
