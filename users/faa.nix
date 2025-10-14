{ lib, config, pkgs, ... }:

{
  config = {

    # Password will need to be set with 'passwd'
    users.users.faa = {
      isNormalUser = true;
      description = "ForeverAnApple";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };
  };
}
