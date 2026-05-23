{
  flake.modules.nixos."hosts/swordholder" =
    { pkgs, ... }:
    {
      programs.nix-ld.libraries = with pkgs; [
        zlib
        openssl
        libxcrypt-legacy
        glib
        libGL
        xz
        bzip2
        libffi
        expat
        sqlite
        ncurses
        util-linux
        libuuid
        icu
        libtasn1
        nspr
        nss
        pulseaudio
        alsa-lib
      ];
    };
}
