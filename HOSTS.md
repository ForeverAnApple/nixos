# Hosts

| Host | Platform | Role | Hardware |
|------|----------|------|----------|
| **fishspeaker** | NixOS (x86_64) | Laptop | Intel CPU, NVMe, Thunderbolt |
| **catjailer** | NixOS (x86_64) | Desktop | AMD Ryzen 7 3700X, NVIDIA GPU, BT dongle |
| **sisyphus** | NixOS (x86_64) | Server | Intel CPU, virtual disk (VM) |
| **wallfacer** | nix-darwin (aarch64) | macOS | Apple Silicon |

Each host picks the modules it needs from `modules/nixos/` and `modules/home/` via its own `imports.nix`. Host-specific overrides live in `modules/hosts/<name>/`.
