{
  flake.modules.nixos.openvpn =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        openvpn3
      ];

      systemd.tmpfiles.rules = [
        "d /etc/openvpn 0700 root root -"
      ];
    };
}
