# Updating

`nh-up` updates the flake inputs, shows the lock changes, then builds and switches the local host to that exact closure. It does not deploy the fleet. `nix run .#update` uses the same path.

Use `nh-up --no-update` to rebuild the pinned configuration. `--update` is an alias for the default. `--review` asks for `approve` before trusting lock changes and each hash repair. `nh-up --update-input NAME` updates only the named input; repeat the flag for several inputs.

The base follows `nixos-unstable`; Audacity, the fcitx5/Mozc stack, and review-heatmap use the stable channel, which advances through normal flake updates. Return each fallback to the base when its stock output builds and its required features pass.

Selected tools use master. `llm-agents` retains its own upstream Nixpkgs dependency and supplies Codex through numtide's cache. Agent-browser uses the Nixpkgs package.

Build the full host closure for each candidate. Builds finish independent packages after a failure, so a retry can reuse their outputs. On catjailer, the Nix daemon uses HDD build scratch and requires that filesystem to be mounted. The store remains on the system disk; downloads and completed outputs still need space there.

A fixed-output mismatch is repaired only when one old hash identifies one occurrence in a tracked Nix file. The helper prints both hashes and trusts the downloaded bytes; nobody can verify them by eye. Ambiguous diagnostics stop the update.

Rejected changes and failed builds or switches restore the prior lock and every source hash edited by the helper. Concurrent edits are preserved; saved originals are retained for recovery. This restores source files, not a system that partly activated before failing. Keep the previous system generation for rollback.
