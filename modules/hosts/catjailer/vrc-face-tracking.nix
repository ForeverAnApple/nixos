{
  flake.modules.nixos."hosts/catjailer" =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.writeShellApplication {
          name = "vrc-face-tracking";
          runtimeInputs = with pkgs; [
            droidcam
            direnv
          ];
          text = ''
            LIVE_LINK_DIR="''${LIVE_LINK_DIR:-$HOME/Projects/VR/LiveLinkVRCFaceTracking}"
            LIVE_LINK_BIN="''${LIVE_LINK_BIN:-$HOME/.cache/cargo-target/release/litelink}"
            DROIDCAM_IP="''${DROIDCAM_IP:-100.64.0.6}"
            DROIDCAM_PORT="''${DROIDCAM_PORT:-4747}"
            OSC_TARGET="''${OSC_TARGET:-127.0.0.1:9000}"
            LISTEN_PORT="''${LISTEN_PORT:-11111}"
            PREFIX="''${PREFIX:-/avatar/parameters/FT/v2}"

            cleanup() {
              trap - EXIT
              if [[ -n "''${LIVELINK_PID:-}" ]]; then kill "$LIVELINK_PID" 2>/dev/null || true; fi
              if [[ -n "''${DROIDCAM_PID:-}" ]]; then kill "$DROIDCAM_PID" 2>/dev/null || true; fi
              wait 2>/dev/null || true
            }
            trap cleanup EXIT INT TERM

            cd "$LIVE_LINK_DIR"
            if [[ -x "$LIVE_LINK_BIN" ]]; then
              "$LIVE_LINK_BIN" --headless --listen-port "$LISTEN_PORT" --osc-target "$OSC_TARGET" --prefix "$PREFIX" &
            else
              direnv exec . cargo run --release -- --headless --listen-port "$LISTEN_PORT" --osc-target "$OSC_TARGET" --prefix "$PREFIX" &
            fi
            LIVELINK_PID=$!

            droidcam-cli -v "$DROIDCAM_IP" "$DROIDCAM_PORT" &
            DROIDCAM_PID=$!

            wait -n
          '';
        })
      ];
    };
}
