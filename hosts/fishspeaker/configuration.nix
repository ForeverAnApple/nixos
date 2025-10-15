# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ".${flake}/users/faa.nix"
      inputs.home-manager.nixosModules.default
    ] ++ (builtins.attrValues flake.nixosModules);

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-71c7df5a-2fe5-4a2d-8de0-5b251cefedde".device = "/dev/disk/by-uuid/71c7df5a-2fe5-4a2d-8de0-5b251cefedde";
  networking.hostName = "fishspeaker"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # please go into core already
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     tmux
  ];

  # Basics for managing a minimal system
  programs = {
    git.enable = lib.mkDefault true;
    neovim.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
  };

  # Use GUI keyboard config in terminal
  console.useXkbConfig = true;

  # Enable kmscon and utilize keyboard configs
  # I literally cannot use a text editor without escape swap lmao
  services = {
    xserver.xkb = {
      options = "caps:swapescape";
      layout = "us";
      variant = "";
    };
    kmscon = {
      enable = true;
      useXkbConfig = true;
      hwRender = true;
      fonts = [{
        name = "Hack Nerd Font";
	package = pkgs.nerd-fonts.hack;
      }];
    };
  };

  # God bless home-manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "faa" = import ./home.nix;
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
