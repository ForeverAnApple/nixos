{
  flake.modules.homeManager.core =
    { lib, pkgs, ... }:
    {
      programs.fastfetch = {
        enable = true;

        # nixpkgs builds fastfetch without libzfs by default, so its Zpool
        # module errors out. Re-enable on Linux; Darwin has no pkgs.zfs.
        package =
          if pkgs.stdenv.isLinux then
            pkgs.fastfetch.override { zfsSupport = true; }
          else
            pkgs.fastfetch;

        settings.modules =
          [
            "title"
            "separator"
            "os"
            "host"
            "kernel"
            "uptime"
            "packages"
            "shell"
            "display"
            "de"
            "wm"
            "wmtheme"
            "theme"
            "icons"
            "font"
            "cursor"
            "terminal"
            "terminalfont"
            "cpu"
            "gpu"
            "memory"
            "swap"
            # Limit to root: ZFS dataset mountpoints report REFER (often
            # bytes, e.g. 256K) instead of pool capacity. The zpool module
            # below shows the real numbers.
            {
              type = "disk";
              folders = "/";
            }
          ]
          # zpool module silently skips when no pools exist; only include
          # it on Linux because Darwin's fastfetch build lacks libzfs.
          ++ lib.optional pkgs.stdenv.isLinux "zpool"
          ++ [
            "localip"
            "battery"
            "poweradapter"
            "locale"
            "break"
            "colors"
          ];
      };
    };
}
