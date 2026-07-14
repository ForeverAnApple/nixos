{
  flake.modules.homeManager.core =
    { lib, pkgs, ... }:
    {
      home.packages =
        lib.attrValues {
          inherit (pkgs)
            bun
            dua
            fd
            file
            htop
            jq
            lsd
            netcat-gnu
            nodejs
            # Apple's bundled rsync is frozen at 2.6.9 (2006) because they
            # stopped tracking the GPLv3 upstream — no -A/-X/--info=progress2.
            # Pull modern rsync into PATH for every host.
            rsync
            tldx
            tokei
            wget
            ;
        }
        ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.mpv ];
      programs = {
        ripgrep = {
          enable = true;
          arguments = [
            "--line-number"
            "--smart-case"
          ];
        };
      };
    };
}
