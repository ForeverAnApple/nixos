{
  flake.modules.nixos.pipewire = {
    # 44.1 kHz in allowed-rates keeps lossless streams bit-perfect instead of resampled to 48 k.
    services.pipewire.extraConfig.pipewire."10-clock-rates"."context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.allowed-rates" = [
        44100
        48000
      ];
    };
  };
}
