{
  flake.modules.nixos."hosts/dreameater" = {
    # vhosts live outside the repo; a glob with no matches is not an error.
    services.caddy = {
      enable = true;
      extraConfig = "import /etc/caddy/sites/*.caddy";
    };
    systemd.tmpfiles.rules = [ "d /etc/caddy/sites 0750 faa caddy -" ];
  };
}
