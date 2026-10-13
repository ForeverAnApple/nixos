# Updating

`nh-up` updates the flake inputs, shows the lock changes, asks for `approve`, then builds and switches the local host to that exact closure. It does not deploy the fleet. `nix run .#update` uses the same path.

Use `nh-up --no-update` to rebuild the pinned configuration. `--update` is an alias for the default. `nh-up --update-input NAME` updates only the named input; repeat the flag for several inputs.

Codex comes from `llm-agents` and moves with `nix flake update`; numtide's cache serves it. The agent-browser release inputs use moving latest-release URLs. Their lock entries pin downloaded bytes, but a cold cache can fail when a URL moves before the lock is refreshed. The moving browser source and release binaries can also diverge.

A fixed-output mismatch is repaired only when one old hash identifies one occurrence in a tracked Nix file. The helper shows its source context and both hashes, then requires another `approve`. Approval trusts the downloaded bytes. It does not prove who published them. Ambiguous diagnostics stop the update.

Rejected changes and failed builds or switches restore the prior lock and every source hash edited by the helper. Concurrent edits are preserved; saved originals are retained for recovery. This restores source files, not a system that partly activated before failing. Keep the previous system generation for rollback.
