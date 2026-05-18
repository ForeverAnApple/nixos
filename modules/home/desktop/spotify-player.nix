{
  flake.modules.homeManager.spotifyPlayer =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.spotify-player.override {
          withAudioBackend = "pulseaudio";
        })
      ];

      # Max quality config — requires Spotify Premium
      xdg.configFile."spotify-player/app.toml".text = ''
        enable_streaming = "Always"
        enable_media_control = true
        enable_notify = true
        enable_cover_image_cache = true

        [device]
        name = "spotify-player"
        device_type = "speaker"
        volume = 70
        bitrate = 320
        audio_cache = true
        normalization = false
        autoplay = false
      '';
    };
}
