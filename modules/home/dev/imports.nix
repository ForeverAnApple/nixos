{ config, ... }:
{
  flake.modules.homeManager.dev.imports = with config.flake.modules.homeManager; [
    agents
    git
    lazygit
    neovim
    pi
  ];
}
