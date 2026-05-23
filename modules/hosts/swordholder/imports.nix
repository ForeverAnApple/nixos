{ config, ... }:
{
  nixosHosts.swordholder = { };

  flake.modules.nixos."hosts/swordholder".imports = with config.flake.modules.nixos; [
    service

    nix-ld
    caddy
    home-assistant
    audiobookshelf
  ];
}
