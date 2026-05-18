# Home Manager module for screen recording
# Provides region-based screen recording with gif/mp4 output
# Uses wf-recorder for capture and ffmpeg for gif conversion
# Toggle: press keybind once to start, again to stop
{
  flake.modules.homeManager.screencast =
    { pkgs, ... }:
    let
      signalWaybar = "pkill -RTMIN+8 waybar || true";
    in
    {
      home.packages = [
        pkgs.wf-recorder
        pkgs.slurp
        pkgs.ffmpeg
        pkgs.wl-clipboard
        pkgs.libnotify
        (pkgs.writeShellApplication {
          name = "record-region";
          runtimeInputs = [
            pkgs.wf-recorder
            pkgs.slurp
            pkgs.ffmpeg
            pkgs.wl-clipboard
            pkgs.libnotify
            pkgs.coreutils
            pkgs.procps
          ];
          text = ''
            # If already recording, stop it and let the original instance handle conversion
            if pgrep -x wf-recorder > /dev/null; then
                pkill -SIGINT -x wf-recorder
                exit 0
            fi

            OUTPUT_DIR="$HOME/Videos/recordings"
            mkdir -p "$OUTPUT_DIR"
            TIMESTAMP=$(date +%Y%m%d-%H%M%S)
            FORMAT="''${1:-gif}"

            REGION=$(slurp) || exit 1

            TEMP_VIDEO="/tmp/recording-$TIMESTAMP.mp4"

            notify-send -t 2000 "Recording started" "Press the same key to stop"
            ${signalWaybar}

            wf-recorder -g "$REGION" -f "$TEMP_VIDEO"

            # wf-recorder exited (killed by toggle or finished)
            ${signalWaybar}

            if [ ! -f "$TEMP_VIDEO" ]; then
                notify-send "Recording failed" "No video file produced"
                exit 1
            fi

            if [ "$FORMAT" = "gif" ]; then
                notify-send -t 3000 "Converting to GIF..." "This may take a moment"
                OUTPUT="$OUTPUT_DIR/recording-$TIMESTAMP.gif"
                ffmpeg -i "$TEMP_VIDEO" -vf \
                  "fps=15,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
                  -loop 0 "$OUTPUT"
                rm "$TEMP_VIDEO"
            else
                OUTPUT="$OUTPUT_DIR/recording-$TIMESTAMP.mp4"
                mv "$TEMP_VIDEO" "$OUTPUT"
            fi

            notify-send "Recording saved" "$OUTPUT"
            wl-copy "$OUTPUT"
          '';
        })
      ];
    };
}
