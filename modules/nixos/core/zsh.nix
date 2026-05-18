{
  flake.modules.nixos.zsh =
    { lib, pkgs, ... }:
    {
      programs.zsh.enable = lib.mkDefault true;
      environment.variables.SHELL = lib.mkDefault "${pkgs.zsh}/bin/zsh";
    };
}
