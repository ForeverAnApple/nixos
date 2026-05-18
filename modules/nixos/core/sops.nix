{ inputs, ... }:
{
  flake.modules.nixos.sops =
    { config, ... }:
    let
      isEd25519 = k: k.type == "ed25519";
      ed25519Keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops.age.sshKeyPaths = map (k: k.path) ed25519Keys;
    };
}
