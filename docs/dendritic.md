# Dendritic Composition

## What we keep from the spec

- **Every `.nix` file is a flake-parts module.** `import-tree` walks `modules/` and pulls them all into one evaluation.
- **Flat namespace.** Modules address each other via `flake.modules.<system>.<name>` — no `specialArgs` threading.
- **No nested evaluations.** One top-level `mkFlake` call sees everything.

## What we modify

The spec says "file paths are labels — purely organizational." We don't go that far. The folder a module lives in *is* a semantic claim about what it does. Drift is a smell.

Folders in `modules/nixos/`:

| Folder | Claim |
|--------|-------|
| `core/` | universal NixOS bits every host gets via the top-level builder |
| `workstation/` | tier aggregate: human-accessible host |
| `service/` | tier aggregate: unattended host |
| `desktop/` | GUI/Wayland leaves a workstation host pulls in |
| `dev/` | development tooling + the interactive `human-user` |
| `server/` | server-side service leaves (sshd, fail2ban, caddy, audiobookshelf, …) — no longer an aggregate, just a folder of leaves |

Folders in `modules/home/`:

| Folder | Claim |
|--------|-------|
| `core/` | every home gets these (shell, ssh, nh) |
| `desktop/` | GUI applications |
| `dev/` | development tools (editor, git) |
| `linux/` | home modules that only make sense on Linux (auto-routed by the NixOS HM wiring) |
| `darwin/` | home modules that only make sense on macOS (auto-routed by the Darwin HM wiring) |
| `agents/` | LLM agent CLIs |

## Two contribution patterns

A leaf module can:

1. **Declare its own named module** (`flake.modules.nixos.tailscale = { ... };`). The aggregator pulls it in via `imports`.
2. **Inject directly into a parent's namespace** (`flake.modules.nixos.core = { time.timeZone = "..."; };`). Multiple files merge into the same name.

We prefer pattern 1: it's discoverable, removable, and renameable. Pattern 2 is reserved for tiny ambient settings (locale, common packages) that don't deserve a named module of their own.

## Adding a module

1. Write a `.nix` file under the folder that matches what it does.
2. Declare `flake.modules.<system>.<name>` with the config.
3. Add `<name>` to the relevant aggregator's `imports.nix` (or directly to a host's `imports.nix` if it's host-specific).
4. `git add` the new file. The flake loader uses git-tracked status; unstaged new files are invisible and produce misleading missing-module errors.

## Adding a host

1. Create `modules/hosts/<name>/` with `imports.nix`, `configuration.nix`, `hardware.nix`, `disko.nix` as needed.
2. In `imports.nix`: register the host (`nixosHosts.<name> = { };`) and pick one tier plus addons (`workstation` + `laptop`, or `service` + service modules).
3. Per-host config lives in this folder. Anything used by more than one host belongs in a shared module.

## Why a flat namespace at all

Threading config through `specialArgs` across nested evaluations is ceremony that scales badly. A flat namespace means any module can reference any other directly. Cost: no static enforcement of contracts — see PHILOSOPHY.md for how we manage the opacity.
