# Architectural Log

Append-only record of structural decisions. New entries on top. Do not edit old entries — if the thinking changed, write a new entry citing the old one.

Format: `## [YYYY-MM-DD] <short topic>` followed by what changed, why, and what it cost.

---

## [2026-05-18] Bauhaus cleanup pass

Four cleanups applied as a single philosophy-tight pass.

1. **`worker` → `service`.** The aggregate was named for the operator (deploy account), not the function. Renamed module, folder, `serviceHosts` variable in `flake/deploy.nix`, and `nixos-services` ssh matchblock. See [PHILOSOPHY.md](../PHILOSOPHY.md).
2. **`server` aggregate dissolved.** It bundled `[sshd, fail2ban]` as a middle layer between `service` and the leaves. Inlined those two into `service/imports.nix`. The `modules/nixos/server/` folder remains as a holding location for server-side leaf modules (sshd, fail2ban, caddy, audiobookshelf, …) — its function is now "leaves," not "aggregate."
3. **`users` → `human-user`.** Generic name → function-honest name. Now parallels `deploy-user`. Renamed `dev/users.nix` → `dev/human-user.nix` and `service/users.nix` → `service/deploy-user.nix` for the same reason (file path reveals function).
4. **Dead code removed.** `core/impermanence.nix` was orphaned (defined but never imported). `nixosHosts.<name>.unstable` was a vestigial option referencing `inputs.nixpkgs-stable` which doesn't exist; every host set it to `true`. Both removed.

Cost: one round of `nix eval` per host to confirm zero closure-hash regression. Renames preserve git history via `git mv`.

## [2026-05-18] Tier system introduced

Added `workstation` and `service` aggregates to capture the two functional classes of host in the fleet (human-accessible vs unattended). Each host's `imports.nix` now opens with the tier name, followed by addons. See [tiers.md](tiers.md).

Reason: hosts were declaring identical baseline imports (`networking, bootloader, docker`) inline with no shared identity. Tier aggregates make the host's function readable in one word and centralize the baseline.

Tradeoff accepted: the tier name is now load-bearing — renaming a tier means touching every host. The fleet is small enough that this is fine; if it grows past ~20 hosts, revisit.
