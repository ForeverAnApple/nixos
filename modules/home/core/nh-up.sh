#!/usr/bin/env bash
set -euo pipefail
cd "$HOME/nixos"

update=1
inputs=()
nh_args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-update) update=0; shift ;;
    --update | -u) update=1; shift ;;
    --update-input | -U)
      [ "$#" -ge 2 ] && [[ $2 =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || {
        echo "nh-up: --update-input requires an input name" >&2
        exit 1
      }
      update=1
      inputs+=("$2")
      shift 2
      ;;
    --verbose | -v | --quiet | -q | --ask | -a | --no-nom | --show-activation-logs)
      nh_args+=("$1")
      shift
      ;;
    --)
      shift
      [ "$#" -eq 0 ] || {
        echo "nh-up: passthrough arguments are not supported" >&2
        exit 1
      }
      ;;
    *)
      echo "nh-up: unsupported argument $1; use nh directly for other deployment modes" >&2
      exit 1
      ;;
  esac
done

case "${NH_CMD:-nh os}" in
  "nh os") nh_cmd=(nh os) ;;
  "nh darwin") nh_cmd=(nh darwin) ;;
  *) echo "nh-up: unsupported NH_CMD" >&2; exit 1 ;;
esac
host=$(uname -n)
host=${host%%.*}
case " ${nh_cmd[*]} " in
  *" darwin "*) toplevel=".#darwinConfigurations.\"$host\".config.system.build.toplevel" ;;
  *) toplevel=".#nixosConfigurations.\"$host\".config.system.build.toplevel" ;;
esac
tmpdir=$(mktemp -d)
targets=()
committed=0
remember() {
  local file=$1 i
  for i in "${!targets[@]}"; do
    [ "${targets[$i]}" != "$file" ] || return 0
  done
  i=${#targets[@]}
  cp -- "$file" "$tmpdir/original-$i"
  cp -- "$file" "$tmpdir/written-$i"
  targets+=("$file")
}
written() {
  local i
  for i in "${!targets[@]}"; do
    if [ "${targets[$i]}" = "$1" ]; then
      cp -- "$1" "$tmpdir/written-$i"
      return
    fi
  done
  return 1
}
cleanup() {
  local status=$? i keep=0
  trap - EXIT
  if [ "$committed" -eq 0 ]; then
    for i in "${!targets[@]}"; do
      if cmp -s -- "${targets[$i]}" "$tmpdir/written-$i"; then
        cp -- "$tmpdir/original-$i" "${targets[$i]}" || { keep=1; status=1; echo "nh-up: restore failed; original retained at $tmpdir/original-$i" >&2; }
      elif ! cmp -s -- "${targets[$i]}" "$tmpdir/original-$i"; then
        printf 'nh-up: concurrent change preserved in %s; original saved at %s\n' "${targets[$i]}" "$tmpdir/original-$i" >&2
        keep=1
      fi
    done
  fi
  [ "$keep" -eq 1 ] || rm -rf -- "$tmpdir"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP

sanitize() {
  LC_ALL=C perl -pe '
    s/\e\][^\a]*(?:\a|\e\\)//g;
    s/\e\[[0-?]*[ -\/]*[\@-\~]//g;
    s/\xc2[\x80-\x9f]//g;
    s{
      (?:
        [\xc2-\xdf][\x80-\xbf]
        | \xe0[\xa0-\xbf][\x80-\xbf]
        | [\xe1-\xec\xee-\xef][\x80-\xbf]{2}
        | \xed[\x80-\x9f][\x80-\xbf]
        | \xf0[\x90-\xbf][\x80-\xbf]{2}
        | [\xf1-\xf3][\x80-\xbf]{3}
        | \xf4[\x80-\x8f][\x80-\xbf]{2}
      )(*SKIP)(*F)
      | [\x80-\x9f]
    }{}gx;
    s/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]//g;
    s/\r//g;
    s/\e//g;
  '
}

approve() {
  [ -t 0 ] || { echo "nh-up: changes require interactive review" >&2; return 1; }
  printf 'Trust these exact changes, then rebuild and activate? Type approve: '
  local answer
  IFS= read -r answer
  [ "$answer" = approve ]
}
remember flake.lock
if [ "$update" -eq 1 ]; then
  for attempt in 1 2 3 4 5; do
    status=0
    exec {log_fd}> >(tee "$tmpdir/update.log" | sanitize)
    log_pid=$!
    nix flake update "${inputs[@]}" --refresh >&"$log_fd" 2>&1 || status=$?
    exec {log_fd}>&-
    written flake.lock
    wait "$log_pid" || exit 1
    [ "$status" -ne 0 ] || break
    [ "$attempt" -lt 5 ] || exit "$status"
    sanitize <"$tmpdir/update.log" >"$tmpdir/update.parse"
    mapfile -t urls < <(grep -E "^error:.*mismatch in field '(narHash|lastModified)'" "$tmpdir/update.parse" | grep -oE '"url":"[^"]+"' | cut -d'"' -f4 | sort -u)
    [ "${#urls[@]}" -gt 0 ] || exit "$status"
    for url in "${urls[@]}"; do
      name=$(jq -r --arg url "$url" '[.nodes.root.inputs | to_entries[] | select(.value | type == "string") | select(.value as $node | $root.nodes[$node].locked.url == $url) | .key] | if length == 1 then .[0] else empty end' --argjson root "$(cat flake.lock)" flake.lock)
      [[ $name =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || exit 1
      if [ "${#inputs[@]}" -gt 0 ]; then
        selected=0
        for input in "${inputs[@]}"; do [ "$input" != "$name" ] || selected=1; done
        [ "$selected" -eq 1 ] || { echo "nh-up: mismatch outside selected inputs; refusing" >&2; exit 1; }
      fi
      status=0
      nix flake update "$name" --refresh || status=$?
      written flake.lock
      [ "$status" -eq 0 ] || exit "$status"
    done
  done
  if ! cmp -s -- "$tmpdir/original-0" flake.lock; then
    cp -- flake.lock "$tmpdir/candidate.lock"
    diff -u -- "$tmpdir/original-0" "$tmpdir/candidate.lock" >"$tmpdir/lock.diff" || [ "$?" -eq 1 ]
    sanitize <"$tmpdir/lock.diff"
    approve || exit 1
    cmp -s -- "$tmpdir/candidate.lock" flake.lock || exit 1
  fi
fi

for attempt in 1 2 3 4 5; do
  status=0
  exec {log_fd}> >(tee "$tmpdir/build.err" | sanitize >&2)
  log_pid=$!
  nix build "$toplevel" --no-link --print-out-paths --no-update-lock-file >"$tmpdir/build.out" 2>&"$log_fd" || status=$?
  exec {log_fd}>&-
  wait "$log_pid" || exit 1
  [ "$status" -ne 0 ] || break
  [ "$attempt" -lt 5 ] || exit "$status"
  sanitize <"$tmpdir/build.err" >"$tmpdir/build.parse"
  mapfile -t pairs < <(perl -0777 -ne 'while (/^error: hash mismatch in fixed-output derivation \x27([^\x27\n]+\.drv)\x27:\n[ \t]+specified:[ \t]*(sha256-[A-Za-z0-9+\/]{43}=)\n[ \t]+got:[ \t]*(sha256-[A-Za-z0-9+\/]{43}=)/mg) { print "$2 $3\n" }' "$tmpdir/build.parse" | sort -u)
  [ "${#pairs[@]}" -eq 1 ] || { echo "nh-up: no unambiguous Nix fixed-output mismatch; refusing to edit" >&2; exit "$status"; }
  read -r old_hash new_hash <<<"${pairs[0]}"
  [ "$old_hash" != "$new_hash" ] || exit 1
  mapfile -t files < <(git grep -lF -e "$old_hash" -- '*.nix')
  mapfile -t hits < <(git grep -hoF -e "$old_hash" -- '*.nix')
  [ "${#files[@]}" -eq 1 ] && [ "${#hits[@]}" -eq 1 ] || { echo "nh-up: hash does not identify one source occurrence; refusing" >&2; exit 1; }
  file=${files[0]}
  cp -- "$file" "$tmpdir/review-source"
  line=$(git grep -nF -e "$old_hash" -- "$file" | cut -d: -f2)
  start=$((line > 8 ? line - 8 : 1))
  printf 'Source: %s:%s\nOld hash: %s\nDownloaded hash: %s\n' "$file" "$line" "$old_hash" "$new_hash"
  nl -ba "$file" | sed -n "${start},$((line + 8))p" | sanitize
  echo 'Approval trusts downloaded bytes; it does not prove who published them.'
  approve || exit 1
  cmp -s -- "$tmpdir/review-source" "$file" || exit 1
  mapfile -t hits < <(git grep -hoF -e "$old_hash" -- '*.nix')
  [ "${#hits[@]}" -eq 1 ] || exit 1
  remember "$file"
  OLD_HASH=$old_hash NEW_HASH=$new_hash perl -pe 's/\Q$ENV{OLD_HASH}\E/$ENV{NEW_HASH}/g' "$file" >"$tmpdir/edited-source"
  cp -- "$tmpdir/edited-source" "$file"
  written "$file"
done
cat "$tmpdir/build.out"
mapfile -t closures < "$tmpdir/build.out"
if [ "${#closures[@]}" -ne 1 ] || ! [[ "${closures[0]}" =~ ^/nix/store/[a-z0-9]{32}-[^/[:space:]]+$ ]]; then
  echo "nh-up: build did not return exactly one store closure" >&2
  exit 1
fi
built=${closures[0]}
unset NH_FILE NH_ATTRP NH_NO_VALIDATE
"${nh_cmd[@]}" switch "${nh_args[@]}" "$built"
profile=$(readlink -f /nix/var/nix/profiles/system)
[ "$profile" = "$built" ] || { echo "nh-up: system profile did not advance to built closure" >&2; exit 1; }
committed=1
