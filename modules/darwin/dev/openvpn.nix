{
  flake.modules.darwin.openvpn =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        openvpn
      ];
    };
}
