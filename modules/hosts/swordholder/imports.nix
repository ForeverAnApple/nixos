{ config, ... }:
{
  nixosHosts.swordholder = { };

  flake.modules.nixos."hosts/swordholder".imports = with config.flake.modules.nixos; [
    service

    nvidia

    nix-ld
    caddy
    home-assistant
    audiobookshelf
    immich
  ];
}
