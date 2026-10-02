{
  flake.modules.nixos.unit-alert =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      user = "faa";

      relay = pkgs.writeShellScript "unit-alert-relay" ''
        ${pkgs.systemd}/bin/systemctl --user --machine=${user}@ start --no-block "unit-alert@system:$1.service" \
          || echo "user manager for ${user} unreachable; $1 failure not relayed"
      '';

      dropIn = path: text: pkgs.writeTextDir "lib/systemd/${path}" text;

      restartBackoff =
        entry:
        let
          scope = lib.head (lib.splitString ":" entry);
          unit = lib.removePrefix "${scope}:" entry;
        in
        dropIn "${scope}/${unit}.d/20-restart-backoff.conf" ''
          [Unit]
          StartLimitIntervalSec=0

          [Service]
          RestartSteps=6
          RestartMaxDelaySec=5min
        '';
    in
    {
      options.services.unit-alert.watched = lib.mkOption {
        type = lib.types.listOf (lib.types.strMatching "(user|system):[^/]+\\.service");
        default = [ ];
        example = [ "user:example.service" ];
        description = "Units, prefixed with their manager scope, that get restart backoff and agent triage on failure.";
      };

      config = {
        systemd.packages = [
          (dropIn "system/service.d/10-unit-alert.conf" ''
            [Unit]
            OnFailure=unit-alert-relay@%n.service
          '')
          # Same filename as the global drop-in, so it replaces it for the relay itself.
          (dropIn "system/unit-alert-relay@.service.d/10-unit-alert.conf" ''
            [Unit]
            OnFailure=
          '')
        ]
        ++ map restartBackoff config.services.unit-alert.watched;

        systemd.services."unit-alert-relay@" = {
          description = "Relay failure of %i to the user alert";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "-${relay} %i";
          };
        };
      };
    };
}
