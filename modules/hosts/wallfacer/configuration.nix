{
  flake.modules.darwin."hosts/wallfacer" = {
    networking.hostName = "wallfacer";
    networking.computerName = "wallfacer";
    system.primaryUser = "daaaa";
    system.stateVersion = 6;

    # home-manager's nixos integration reads users.users.<name>.home to seed
    # home.homeDirectory; nix-darwin doesn't auto-derive it from the username,
    # so we set it explicitly.
    users.users.daaaa.home = "/Users/daaaa";
  };
}
