{
  flake.modules.nixos.docker =
    { pkgs, ... }:
    {
      virtualisation.docker = {
        enable = false; # Disable system-wide daemon for rootless

        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };

      # Docker Compose support
      environment.systemPackages = [ pkgs.docker-compose ];

      # Enable lingering for user faa so containers persist after logout
      users.users.faa.linger = true;
    };
}
