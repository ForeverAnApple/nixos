# An attempt at the Nixos dendrix setup
{
  description = "My nixos config file.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Bleeding-edge channel used *only* for fast-moving AI CLIs
    # (claude-code, opencode) via modules/nixos/dev/overlays.nix.
    # Unstable lags master by days on these and the AI tools ship daily,
    # so we prefer master for them and unstable for everything else.
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agent multiplexer (tmux-like) — built from source, no upstream cache.
    # Pinned to a release tag; bump the tag here to upgrade.
    herdr = {
      url = "github:herdrdev/herdr/v0.8.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    open-interpreter-darwin-aarch64 = {
      url = "https://github.com/openinterpreter/openinterpreter/releases/download/rust-v0.0.23/open-interpreter-package-aarch64-apple-darwin.tar.gz";
      flake = false;
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    # Source tree only supplies the version, skills/, and skill-data/ dirs —
    # the executable comes from the prebuilt release binaries below. `nix flake
    # update` bumps both. See modules/home/agents/agent-browser/.
    agent-browser-src = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };

    # Prebuilt release binaries, one input per platform. `file+https` fetches
    # the raw executable without tarball unpacking; the hash lands in
    # flake.lock, so `nix flake update` is the version bump — no hashes to
    # hand-edit. Only the matching platform's input is fetched at build time.
    agent-browser-darwin-aarch64 = {
      url = "file+https://github.com/vercel-labs/agent-browser/releases/latest/download/agent-browser-darwin-arm64";
      flake = false;
    };
    agent-browser-darwin-x86_64 = {
      url = "file+https://github.com/vercel-labs/agent-browser/releases/latest/download/agent-browser-darwin-x64";
      flake = false;
    };
    agent-browser-linux-aarch64 = {
      url = "file+https://github.com/vercel-labs/agent-browser/releases/latest/download/agent-browser-linux-musl-arm64";
      flake = false;
    };
    agent-browser-linux-x86_64 = {
      url = "file+https://github.com/vercel-labs/agent-browser/releases/latest/download/agent-browser-linux-musl-x64";
      flake = false;
    };

    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };

    # GitHub serves /releases/latest/download/<asset> as a redirect to the
    # current release. Nix follows the redirect, hashes the resolved tarball,
    # and pins it in flake.lock — so `nix flake update` is the version bump.
    # One input per platform; only the matching one is fetched at build time.
    codex-darwin-aarch64 = {
      url = "https://github.com/openai/codex/releases/latest/download/codex-package-aarch64-apple-darwin.tar.gz";
      flake = false;
    };
    codex-darwin-x86_64 = {
      url = "https://github.com/openai/codex/releases/latest/download/codex-package-x86_64-apple-darwin.tar.gz";
      flake = false;
    };
    codex-linux-aarch64 = {
      url = "https://github.com/openai/codex/releases/latest/download/codex-package-aarch64-unknown-linux-musl.tar.gz";
      flake = false;
    };
    codex-linux-x86_64 = {
      url = "https://github.com/openai/codex/releases/latest/download/codex-package-x86_64-unknown-linux-musl.tar.gz";
      flake = false;
    };
  };

  outputs =
    { ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules)
        inputs.treefmt-nix.flakeModule
      ];
    };
}
