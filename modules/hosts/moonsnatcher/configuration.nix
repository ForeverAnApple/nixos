{
  flake.modules.nixos."hosts/moonsnatcher" =
    { lib, modulesPath, ... }:
    {
      imports = [ (modulesPath + "/virtualisation/amazon-image.nix") ];

      networking.hostName = "moonsnatcher";
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "26.05";

      services.kmscon.enable = lib.mkForce false;
      hardware.graphics.enable = lib.mkForce false;

      virtualisation.amazon-init.enable = false;
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
      boot.loader.grub.enable = true;

      networking.networkmanager.enable = lib.mkForce false;
      networking.useNetworkd = true;
      networking.useDHCP = true;
      services.tailscale.openFirewall = true;
      services.resolved.settings.Resolve = {
        LLMNR = false;
        MulticastDNS = false;
      };

      services.openssh.ports = lib.mkForce [ 22022 ];
      services.openssh.settings = {
        PermitRootLogin = lib.mkForce "no";
        MaxSessions = lib.mkForce 64;
      };
      services.openssh.extraConfig = ''
        Match User faa
            AllowTcpForwarding local
            PermitOpen localhost:* 127.0.0.1:* [::1]:*
        Match All
      '';

      nix.settings = {
        max-jobs = 8;
        cores = 6;
      };
    };
}
