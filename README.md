# A [Dendritic](https://github.com/mightyiam/dendritic) NixOs configuration

NixOS is extremly complicated for a beginner like me, I've tried to keep everything as minimal as possible for ease of readability within my configurations. Hope this helps you.

## Install

Clone the repo, enter its directory then:
```bash
sudo nix --extra-experimental-features 'nix-command flakes' run 'github:nix-community/disko/latest#disko-install' -- --write-efi-boot-entries --flake .#fishspeaker --disk main /dev/nvme0n1
```

Or, if you've already partitioned and mounted your drives manually to `/mnt`:
```bash
sudo nixos-install --flake .#<hostname>
```

To apply config changes on an existing system:
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

Sometimes, the installer may run of space due to limitations of disko-install, requiring that the entire system be fit into ram (the default tmpfs), if that's the case, try the following:

Enable an external swap device.
```
sudo swapon /dev/sda1
```

Remount the nix store.
```
sudo mount -o remount,size=24G,noatime /nix/.rw-store
```

Edit the hosts configuration to not include desktop, then build desktop later after boot.

## Acknowledgements
Much thanks to the following people and repos, I've referenced a lot from their setups.
- https://github.com/nat543207/nixos
- https://github.com/bivsk/nix-iv
- https://github.com/GaetanLepage/nix-config
- https://github.com/gvolpe/nix-config
