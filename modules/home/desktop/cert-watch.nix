# Daily TLS probe from the desktop — the path clients actually take.
# One endpoint per issued cert; caddy renews at 30 days out, so a stuck
# renewal yields ~9 days of warnings before anything breaks (docs/acme.md).
{
  flake.modules.homeManager.cert-watch =
    { pkgs, ... }:
    let
      endpoints = [
        "ha.jura.moe"
        "anki.jura.moe"
      ];
      script = pkgs.writeShellScript "cert-watch" ''
        warn() { ${pkgs.libnotify}/bin/notify-send -u critical "cert-watch" "$1"; }
        for e in ${toString endpoints}; do
          if ! ${pkgs.curl}/bin/curl -sS -m 15 -o /dev/null "https://$e/"; then
            warn "$e: unreachable or TLS failure"
            continue
          fi
          end=$(echo | ${pkgs.openssl}/bin/openssl s_client -connect "$e:443" -servername "$e" 2>/dev/null \
            | ${pkgs.openssl}/bin/openssl x509 -noout -enddate | cut -d= -f2)
          days=$(( ($(date -d "$end" +%s) - $(date +%s)) / 86400 ))
          if [ "$days" -lt 21 ]; then
            warn "$e: certificate expires in $days days"
          fi
        done
      '';
    in
    {
      systemd.user.services.cert-watch = {
        Unit.Description = "TLS expiry watchdog for fleet endpoints";
        Service = {
          Type = "oneshot";
          ExecStart = "${script}";
        };
      };
      systemd.user.timers.cert-watch = {
        Timer = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
