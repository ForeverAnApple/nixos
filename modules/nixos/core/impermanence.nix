{ inputs, ... }:
{
  flake.modules.nixos.impermanence =
    { pkgs, ... }:
    {
      imports = [ inputs.impermanence.nixosModules.impermanence ];

      environment.persistence."/persist" = {
        enable = true;
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
      fileSystems."/persist".neededForBoot = true;
    };
}
