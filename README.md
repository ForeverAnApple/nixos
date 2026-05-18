# nixos

My NixOS configurations for five machines. Three are workstations I use directly: a Linux laptop, a Linux desktop, and a Mac. Two are servers that run unattended. The repo is public because I learned NixOS by reading other people's repos, and I hope this will help you as well.

## Hosts

| Host | Tier | Platform | Form factor | Role |
|------|------|----------|-------------|------|
| fishspeaker | workstation | NixOS (x86_64) | laptop | mobile workstation |
| catjailer | workstation | NixOS (x86_64) | desktop | primary workstation |
| wallfacer | workstation | nix-darwin (aarch64) | laptop | macOS workstation |
| sisyphus | service | NixOS (x86_64) | VM | network utility |
| swordholder | service | NixOS (x86_64) | bare metal | media / storage |

```
workstation
├── fishspeaker   NixOS · laptop
├── catjailer     NixOS · desktop
└── wallfacer     macOS · laptop
        │
        ↕  tailscale mesh
        │
service
├── sisyphus      NixOS · VM
└── swordholder   NixOS · bare metal
```

## How it's organized

This uses the [dendritic](https://github.com/mightyiam/dendritic) pattern. Every `.nix` file under `modules/` is a flake-parts module addressable by name in one flat namespace, not by import path.

Hosts fall into one of two tiers. `workstation` is for machines I use directly. `service` is for machines that run unattended. Each tier is itself a module that bundles the things every host of that tier needs. A host's `imports.nix` picks the tier plus whatever else is specific to that host. You should be able to read the import list and tell what the machine is.

## Installing

Fresh install onto a disk (uses disko to partition):

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run \
  'github:nix-community/disko/latest#disko-install' -- \
  --write-efi-boot-entries --flake .#<hostname> --disk main /dev/nvme0n1
```

If the partitions are already mounted at `/mnt`:

```bash
sudo nixos-install --flake .#<hostname>
```

Apply changes on a running system:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
# or, what I actually use:
nh os switch
```

Deploy to a service host remotely:

```bash
nix run .#deploy -- .#<hostname>
```

If `disko-install` runs out of RAM (it fits the whole install into tmpfs by default), add swap and enlarge the nix store:

```bash
sudo swapon /dev/sda1
sudo mount -o remount,size=24G,noatime /nix/.rw-store
```

Or temporarily drop `desktop` from the host's `imports.nix` and add it back after the first boot.

## Layout

```
modules/
├── flake/    flake output wiring (host builders, deploy, formatter)
├── nixos/    NixOS modules: core, workstation, service, desktop, dev, server (leaves)
├── home/     Home Manager modules: core, desktop, dev, linux, darwin, agents
├── darwin/   macOS modules: core, dev, workstation
└── hosts/    per-host config and imports (one folder per host)
```

## More

- [PHILOSOPHY.md](PHILOSOPHY.md) — the one principle the repo is structured around
- [docs/](docs/) — short pages on dendritic, tiers, hosts, and the change log
- [AGENTS.md](AGENTS.md) — how the repo and wiki are kept consistent

## References

Configurations I read and copied from:

- [nat543207/nixos](https://github.com/nat543207/nixos)
- [bivsk/nix-iv](https://github.com/bivsk/nix-iv)
- [GaetanLepage/nix-config](https://github.com/GaetanLepage/nix-config)
- [gvolpe/nix-config](https://github.com/gvolpe/nix-config)
- [mightyiam/dendritic](https://github.com/mightyiam/dendritic) — composition pattern
- [badele/nix-homelab](https://github.com/badele/nix-homelab) — README ideas
