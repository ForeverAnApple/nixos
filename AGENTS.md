# Agents

## Hosts

See [HOSTS.md](HOSTS.md) for the full host breakdown.

## Dendritic Architecture

This repo follows the [Dendritic](https://github.com/mightyiam/dendritic) pattern for Nix configuration:

- **Every file is a module.** Every `.nix` file (except `flake.nix`) is a flake-parts module imported into a single top-level evaluation via `import-tree`.
- **Flat value sharing.** Instead of threading values through `specialArgs` across nested evaluations, all modules share one unified configuration space.
- **File paths are labels.** The directory structure (`modules/nixos/core/`, `modules/home/desktop/`, etc.) is purely organizational. Files can be moved or renamed without breaking anything.
- **Hosts compose modules.** Each host's `imports.nix` picks which modules it needs. Host-specific overrides live in `modules/hosts/<name>/`.

## Workflow Note

- Stage new flake module files with `git add` before running `nix eval` or other flake evaluations. In this repo, unstaged new module files may be invisible to the flake loader and produce misleading missing-module errors.

## Commit Style

- Single-line subject only. No body, no `Co-Authored-By:` trailer. Match the historical pattern in `git log` (e.g. `home-assistant`, `monitors off on idle`, `samba: require SMB3 + signing + encryption`).

## Comment Style

- Default to zero comments. Code + good names carry the meaning.
- Only comment a genuine non-obvious: host-specific quirk, workaround for a known upstream bug, invariant the types can't express.
- Never narrate what the next line does, restate option names in prose, or write multi-line module headers. Design rationale belongs in the commit message, not the source.

## This Repo Is Public

- No PII or activity-revealing prose in code, comments, or commit messages. Don't narrate what services do, who uses them, what's stored where, or which providers are paid for.
- Functional config (mount paths, env vars, container names) stays — there's no way around it. Narrative around it does not.
- Commit messages: factual subject only. No "why we run X for Y" bodies.

```
modules/
├── flake/    # Flake output wiring (host builders, systems, formatter)
├── nixos/    # NixOS system modules (core, desktop, dev, server)
├── home/     # Home Manager modules (core, desktop, dev)
├── darwin/   # macOS modules (core, dev)
└── hosts/    # Per-host config and imports
```
