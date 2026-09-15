{
  flake.modules.nixos."hosts/dreameater" = {
    services.openssh.extraConfig = ''
      Match User faa Address 100.64.0.7
          AllowTcpForwarding remote
          PermitListen 127.0.0.1:19433
      Match All
    '';
  };
}
