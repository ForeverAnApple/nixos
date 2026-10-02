{
  flake.modules.homeManager.unit-alert =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      say = pkgs.writeShellScript "unit-alert-say" ''
        voice=${config.home.homeDirectory}/.local/bin/voice
        [ -x "$voice" ] && ${pkgs.coreutils}/bin/timeout 60 "$voice" "$1"
        exit 0
      '';

      alert = pkgs.writeShellApplication {
        name = "unit-alert";
        runtimeInputs = with pkgs; [
          coreutils
          gawk
          gnugrep
          libnotify
          systemd
        ];
        runtimeEnv = {
          SAY = say;
          WATCHED = lib.concatLines osConfig.services.unit-alert.watched;
        };
        text = builtins.readFile ./alert.sh;
      };

      triage = pkgs.writeShellApplication {
        name = "unit-triage";
        runtimeInputs = [
          config.programs.claude-code.finalPackage
        ]
        ++ (with pkgs; [
          coreutils
          gnugrep
          gnused
          iproute2
          jq
          libnotify
          pipewire
          procps
          systemd
          util-linux
          wireplumber
        ]);
        runtimeEnv.PROMPT = ./prompt.md;
        text = builtins.readFile ./triage.sh;
      };

      # A drop-in with the same filename as the global one replaces it for this unit.
      noOnFailure = ''
        [Unit]
        OnFailure=
      '';
    in
    {
      xdg.configFile = {
        "systemd/user/service.d/10-unit-alert.conf".text = ''
          [Unit]
          OnFailure=unit-alert@%n.service
        '';
        "systemd/user/unit-alert@.service.d/10-unit-alert.conf".text = noOnFailure;
        "systemd/user/unit-triage@.service.d/10-unit-alert.conf".text = noOnFailure;
      };

      systemd.user.services."unit-alert@" = {
        Unit.Description = "Alert on failure of %i";
        Service = {
          Type = "oneshot";
          ExecStart = "-${alert}/bin/unit-alert %i";
        };
      };

      systemd.user.services."unit-triage@" = {
        Unit.Description = "Diagnose failure of %i";
        Service = {
          Type = "oneshot";
          ExecStart = "-${triage}/bin/unit-triage %i";
          WorkingDirectory = "${config.home.homeDirectory}/nixos";
          TimeoutStartSec = 900;
          Nice = 10;
          Environment = [
            "ENABLE_CLAUDEAI_MCP_SERVERS=false"
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1"
          ];
        };
      };
    };
}
