# Tiers

A host is one of two functional classes: **workstation** or **service**. The tier is the primary axis of the fleet — every other classification (form factor, hardware, services) is a modifier on top.

## The two tiers

Every NixOS host gets the interactive `faa` user via `core/human-user.nix`: zsh, wheel/sudo NOPASSWD, the operator ssh keys. Tier on top of that.

### `workstation` — a human creates on it

Provides:
- Desktop environment (Wayland, niri, fuzzel, …)
- Development tooling (overlays for fast-moving AI CLIs, wireguard, openvpn)
- nix-ld, envfs (so pre-built Linux binaries run without packaging effort)
- Networking, bootloader, docker rootless

Wants:
- A graphical session
- Local builds

Hosts: fishspeaker, catjailer, wallfacer.

### `service` — it serves something to others, unattended

Provides:
- Hardened sshd + fail2ban
- Networking, bootloader, docker rootless

Wants:
- No graphical session
- Remote deploy via deploy-rs (as `faa`, same as workstation)
- Long uptime

Hosts: sisyphus, swordholder.

## Form-factor addons

Form factor is orthogonal to tier. Currently only one addon exists:

- `laptop` (NixOS-only) — TLP, powertop, suspend-on-lid, hibernate. Composed onto `workstation` for portable hardware.

macOS has no `laptop` analogue because macOS handles laptop concerns natively. wallfacer (a macOS laptop) imports `workstation` and nothing else for portability — the platform takes care of it, we don't double-declare.

## Mixed-purpose hosts

A host should be one tier. Mixing tiers (workstation that also runs services, service that also has interactive shells) is a smell — but sometimes a transitional one.

Today: `catjailer` is a workstation that also imports `sshd, fail2ban, caddy`. Those services are pending migration off catjailer. The mixed state is named honestly in `modules/hosts/catjailer/imports.nix` — first import is `workstation` (its real identity), the rest are the debt.

When the migration completes, catjailer becomes pure: `[workstation, nvidia, gaming, obs]`.

## Adding a new host

1. Decide the tier first. Ask: *is a human creating on it, or is it serving something unattended?*
2. If both: pick the dominant one and name the impurity. If genuinely both forever, the design is wrong — split into two hosts.
3. Import the tier in `imports.nix`. Add form-factor or service modules as siblings.
4. The host's import list should read as a one-sentence description of what the machine is.

## Why these names

Function-named, not role-named. `service` names what the host *does*, not who logs into it. See [PHILOSOPHY.md](../PHILOSOPHY.md).
