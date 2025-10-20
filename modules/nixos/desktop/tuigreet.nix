{
  flake.modules.nixos.tuigreet = { pkgs, lib, ... }: {
    services = {
      greetd = {
        enable = true;
	settings = rec {
	  tuigreet_session =
	    let
	      session = "${pkgs.niri-unstable}/bin/niri-session";
	      tuigreet = "${lib.getExe pkgs.tuigreet}";
	    in
	    {
	      command = "${tuigreet} --time --remember --cmd ${session}";
	      user = "greeter";
	    };
	  default_session = tuigreet_session;
	};
      };
    };

    # no documentation about this anywhere
    # this prevents spam on screen from kernel messages
    # good luck to whoever is looking for this issue
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors spam on screen
      # Without these bootlogs spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVDisallocate = true;
    };
  };
}
