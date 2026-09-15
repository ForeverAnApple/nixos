{
  flake.modules.nixos."hosts/dreameater" =
    { config, pkgs, ... }:
    {
      networking.hostName = "dreameater";
      networking.hostId = "d3276245";
      system.stateVersion = "25.11";

      services.qemuGuest.enable = true;

      sops.defaultSopsFile = ./secrets.yaml;

      # Only unlocks the provider's VNC console; sshd is key-only.
      sops.secrets."faa/hashed_password".neededForUsers = true;
      users.users.faa.hashedPasswordFile = config.sops.secrets."faa/hashed_password".path;

      environment.systemPackages = [ pkgs.logrotate ];
    };
}
