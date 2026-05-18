{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      config = {

        # Password will need to be set with 'passwd'
        users.users.faa = {
          isNormalUser = true;
          description = "ForeverAnApple";
          extraGroups = [
            "networkmanager"
            "wheel"
            "docker"
          ];
          shell = pkgs.zsh;
        };
      };
    };
}
