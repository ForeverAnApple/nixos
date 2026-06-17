{
  flake.modules.nixos.core =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        tmux
        killall
        wget
        fd

        # Networking
        dig
      ];

      programs = {
        git.enable = lib.mkDefault true;
        neovim = {
          enable = lib.mkDefault true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
        };
      };
    };
}
