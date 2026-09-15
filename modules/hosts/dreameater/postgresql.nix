{
  flake.modules.nixos."hosts/dreameater" =
    { pkgs, ... }:
    {
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
        extensions = ps: [ ps.pgmq ];
        authentication = ''
          host all all 127.0.0.1/32 scram-sha-256
          host all all ::1/128 scram-sha-256
        '';
      };
    };
}
