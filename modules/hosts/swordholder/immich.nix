{
  flake.modules.nixos."hosts/swordholder" = {
    services.immich = {
      mediaLocation = "/THICC/Immich";
      # NVENC for video transcode. UVM devices added separately when
      # the CUDA machine-learning variant lands.
      accelerationDevices = [
        "/dev/nvidia0"
        "/dev/nvidiactl"
        "/dev/nvidia-modeset"
      ];
    };

    systemd.tmpfiles.rules = [
      "d /THICC/Immich 0700 immich immich -"
    ];
  };
}
