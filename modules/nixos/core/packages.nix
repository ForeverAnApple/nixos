{
  flake.modules.nixos.core = { lib, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      tmux
      killall
      wget
      fd

      # Networking
      dig

      # System monitoring
      btop
      htop

      # lmao
      fastfetch
      cowsay
    ];

    programs = {
      git.enable = lib.mkDefault true;
      zsh.enable = lib.mkDefault true;
      neovim = {
        enable = lib.mkDefault true;
	defaultEditor = true;
	viAlias = true;
	vimAlias = true;
      };
    };
  };
}
