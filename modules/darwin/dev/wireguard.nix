{
  flake.modules.darwin.wireguard =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wireguard-tools
        wireguard-go
      ];
    };
}
