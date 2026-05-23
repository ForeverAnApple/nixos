{
  flake.modules.nixos.human-user =
    { pkgs, ... }:
    let
      fishspeakerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkJnLL3cD38k0Tgfn2NI4QjjBddCfOgPGOMWATl5A3U faa@fishspeaker";
      wallfacerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBFfp88mw/pc5SWlQh56cnOqWDK0B2QZ4rncqLrUXKL daaaa@wallfacer";
      miniwisherKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZfTI5ojaodnhjAqej8LNIsDASZQy36FkUkTAFcYGP0 faa@miniwisher";
      catjailerKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9kOV2Q1F92O4tmO9tOZEstJswoRAcVSoU+K81hTxvZ faa@catjailer";
    in
    {
      users.users.faa = {
        isNormalUser = true;
        description = "ForeverAnApple";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
        ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
          fishspeakerKey
          wallfacerKey
          miniwisherKey
          catjailerKey
        ];
      };

      security.sudo.wheelNeedsPassword = false;
    };
}
