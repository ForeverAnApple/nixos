{ config, ... }:
{
  flake.modules.homeManager.dev.imports = with config.flake.modules.homeManager; [
    git
    lazygit
    neovim
    pi
  ];
}
