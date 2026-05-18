{
  flake.modules.nixos.wireguard =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wireguard-tools
        wireguard-go
      ];

      systemd.tmpfiles.rules = [
        "d /etc/wireguard 0700 root root -"
      ];
    };
}
