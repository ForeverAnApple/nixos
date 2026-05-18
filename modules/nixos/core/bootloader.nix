{
  flake.modules.nixos.bootloader =
    { ... }:
    {
      boot.loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
        efi.canTouchEfiVariables = true;
      };

      # systemd-based initrd: clean LUKS prompt that hides typed characters,
      # silences kernel chatter during password entry, and reuses the same
      # passphrase across multiple LUKS volumes so you only type it once.
      boot.initrd.systemd.enable = true;
    };
}
