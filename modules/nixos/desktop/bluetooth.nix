{
  flake.modules.nixos.bluetooth =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.bluetui ];

      hardware.bluetooth = {
        enable = true;
        package = pkgs.bluez-experimental;
        powerOnBoot = true;
        settings.General.Experimental = true;
      };

      # Enable the mpris-proxy service shipped by bluez to bridge
      # Bluetooth AVRCP media controls to D-Bus MPRIS.
      systemd.user.services.mpris-proxy.wantedBy = [ "default.target" ];
    };
}
