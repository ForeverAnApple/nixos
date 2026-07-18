# Hosts

| Host | Tier | Platform | Form factor | Hardware | Role |
|------|------|----------|-------------|----------|------|
| **fishspeaker** | workstation | NixOS (x86_64) | laptop | Intel, NVMe, Thunderbolt | mobile workstation |
| **catjailer** | workstation | NixOS (x86_64) | desktop | AMD Ryzen 7 3700X, NVIDIA | primary workstation |
| **wallfacer** | workstation | nix-darwin (aarch64) | laptop | Apple Silicon | macOS workstation |
| **sisyphus** | service | NixOS (x86_64) | VM | Intel, virtual disk | network utility (relay, anti-spam) |
| **swordholder** | service | NixOS (x86_64) | bare metal | NVIDIA, ZFS pool | media / storage |

Tier aggregates: `modules/nixos/workstation/`, `modules/nixos/service/`, `modules/darwin/workstation/`.
Per-host config: `modules/hosts/<name>/`. Each host's `imports.nix` picks one tier plus addons.

## Per-host notes

### fishspeaker
NixOS laptop. Imports: `[workstation, laptop]`. No remote deploy (no exposed sshd); rebuild locally via `nh os switch`.

### catjailer
NixOS desktop. Imports today: `[workstation, nvidia, gaming, obs, sshd, fail2ban, caddy]`. Last three are transitional service load, migrating to a dedicated service host. Post-migration target: `[workstation, nvidia, gaming, obs]`. Accepts remote deploy as `faa`.

### wallfacer
nix-darwin laptop. Imports: `[workstation]` (darwin tier — bundles `dev`). macOS handles laptop power management; no `laptop` addon needed.

### sisyphus
NixOS service VM. Imports: `[service, endlessh, initrd-unlock, derper]`. Headless. Deploy via deploy-rs as `faa`. Initrd LUKS unlock via `ssh -p 2222 root@sisyphus.davec.xyz` (stage-1 minimal env; authorized_keys sourced from the live faa user).

### swordholder
NixOS service bare-metal. Imports: `[service, nvidia, nix-ld, caddy, home-assistant, audiobookshelf, immich, forgejo, paperless, homepage]`. ZFS pool, NVIDIA for transcoding. Host-local config carries the storage and media-pipeline specifics. Deploy via deploy-rs as `faa`.
