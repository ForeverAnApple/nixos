#!/usr/bin/env bash
# Rebuild the current host, auto-repinning any fixed-output hash that rotted.
# Nix prints the correct hash on a mismatch; we write it back and retry.
set -uo pipefail
cd "$HOME/nixos" || exit 1

nh_cmd=${NH_CMD:-nh os}
max=5
attempt=0

strip_ansi() { sed -r 's/\x1b\[[0-9;?]*[A-Za-z]//g'; }

while :; do
  attempt=$((attempt + 1))
  log=$(mktemp)

  # -u (flake update) only on the first pass; retries must not move inputs again.
  if [ "$attempt" -eq 1 ]; then
    # shellcheck disable=SC2086
    $nh_cmd switch -u "$@" 2>&1 | tee "$log"
  else
    # shellcheck disable=SC2086
    $nh_cmd switch "$@" 2>&1 | tee "$log"
  fi
  status=${PIPESTATUS[0]}

  if [ "$status" -eq 0 ]; then
    rm -f "$log"
    exit 0
  fi

  if [ "$attempt" -ge "$max" ]; then
    echo "nh-up: giving up after $attempt attempts" >&2
    rm -f "$log"
    exit "$status"
  fi

  clean=$(strip_ansi <"$log")
  rm -f "$log"

  mapfile -t spec < <(printf '%s\n' "$clean" | grep -oE 'specified:[[:space:]]*sha256-[A-Za-z0-9+/=]+' | grep -oE 'sha256-[A-Za-z0-9+/=]+')
  mapfile -t got < <(printf '%s\n' "$clean" | grep -oE 'got:[[:space:]]*sha256-[A-Za-z0-9+/=]+' | grep -oE 'sha256-[A-Za-z0-9+/=]+')

  if [ "${#spec[@]}" -eq 0 ] || [ "${#spec[@]}" -ne "${#got[@]}" ]; then
    echo "nh-up: build failed with no auto-fixable hash mismatch" >&2
    exit "$status"
  fi

  fixed=0
  for i in "${!spec[@]}"; do
    s=${spec[$i]}
    g=${got[$i]}
    [ "$s" = "$g" ] && continue
    file=$(grep -rlF --include='*.nix' -- "$s" . | head -n1)
    if [ -z "$file" ]; then
      echo "nh-up: cannot find $s in any .nix file, skipping" >&2
      continue
    fi
    sed -i "s|$s|$g|" "$file"
    echo "nh-up: repinned hash in $file" >&2
    echo "       $s -> $g" >&2
    fixed=$((fixed + 1))
  done

  if [ "$fixed" -eq 0 ]; then
    echo "nh-up: mismatches found but nothing patched, aborting" >&2
    exit "$status"
  fi

  echo "nh-up: rebuilding (attempt $attempt/$max)" >&2
done
