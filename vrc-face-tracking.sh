#!/usr/bin/env bash
set -euo pipefail

LIVE_LINK_DIR="${LIVE_LINK_DIR:-$HOME/Projects/VR/LiveLinkVRCFaceTracking}"
LIVE_LINK_BIN="${LIVE_LINK_BIN:-$HOME/.cache/cargo-target/release/litelink}"
DROIDCAM_IP="${DROIDCAM_IP:-100.64.0.6}"
DROIDCAM_PORT="${DROIDCAM_PORT:-4747}"
OSC_TARGET="${OSC_TARGET:-127.0.0.1:9000}"
LISTEN_PORT="${LISTEN_PORT:-11111}"
PREFIX="${PREFIX:-/avatar/parameters/FT/v2}"

if ! command -v droidcam-cli >/dev/null 2>&1; then
  echo "droidcam-cli is required but not installed." >&2
  exit 1
fi

if [[ ! -d "$LIVE_LINK_DIR" ]]; then
  echo "LiveLink project directory not found: $LIVE_LINK_DIR" >&2
  exit 1
fi

if [[ ! -x "$LIVE_LINK_BIN" ]] && ! command -v direnv >/dev/null 2>&1; then
  echo "Neither release binary nor direnv fallback is available." >&2
  exit 1
fi

cleanup() {
  local exit_code=$?

  trap - EXIT INT TERM

  if [[ -n "${LIVELINK_PID:-}" ]] && kill -0 "$LIVELINK_PID" 2>/dev/null; then
    kill "$LIVELINK_PID" 2>/dev/null || true
  fi

  if [[ -n "${DROIDCAM_PID:-}" ]] && kill -0 "$DROIDCAM_PID" 2>/dev/null; then
    kill "$DROIDCAM_PID" 2>/dev/null || true
  fi

  wait "${LIVELINK_PID:-}" 2>/dev/null || true
  wait "${DROIDCAM_PID:-}" 2>/dev/null || true

  exit "$exit_code"
}

trap cleanup EXIT INT TERM

echo "Starting LiveLink bridge from $LIVE_LINK_DIR"
if [[ -x "$LIVE_LINK_BIN" ]]; then
  (
    cd "$LIVE_LINK_DIR"
    exec "$LIVE_LINK_BIN" \
      --headless \
      --listen-port "$LISTEN_PORT" \
      --osc-target "$OSC_TARGET" \
      --prefix "$PREFIX"
  ) &
else
  (
    cd "$LIVE_LINK_DIR"
    exec direnv exec "$LIVE_LINK_DIR" cargo run --release -- \
      --headless \
      --listen-port "$LISTEN_PORT" \
      --osc-target "$OSC_TARGET" \
      --prefix "$PREFIX"
  ) &
fi
LIVELINK_PID=$!

echo "Starting DroidCam on ${DROIDCAM_IP}:${DROIDCAM_PORT}"
droidcam-cli -v "$DROIDCAM_IP" "$DROIDCAM_PORT" &
DROIDCAM_PID=$!

wait -n "$LIVELINK_PID" "$DROIDCAM_PID"
