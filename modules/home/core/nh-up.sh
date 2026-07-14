#!/usr/bin/env bash
set -uo pipefail
cd "$HOME/nixos" || exit 1

read -r -a nh_cmd <<<"${NH_CMD:-nh os}"
max=5
attempt=0
tmpdir=$(mktemp -d) || exit 1
old_lock="$tmpdir/flake.lock"
new_lock=flake.lock
lock_pending=0
fixed_pending=0
fixed_file=
fixed_original=
if ! cp -- flake.lock "$old_lock"; then
  rm -rf -- "$tmpdir"
  exit 1
fi

cleanup() {
  status=$?
  trap - EXIT
  if [ "$lock_pending" -eq 1 ]; then
    if ! cp -- "$old_lock" flake.lock; then
      echo "nh-up: failed to restore the prior flake.lock" >&2
      status=1
    fi
  fi
  if [ "$fixed_pending" -eq 1 ]; then
    if ! cp -- "$fixed_original" "$fixed_file"; then
      echo "nh-up: failed to restore $fixed_file" >&2
      status=1
    fi
  fi
  rm -rf -- "$tmpdir"
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

run_logged() {
  log=$1
  shift
  log_failed=0
  "$@" 2>&1 | tee "$log"
  pipeline_status=("${PIPESTATUS[@]}")
  if [ "${pipeline_status[1]}" -ne 0 ]; then
    log_failed=1
    echo "nh-up: could not capture command output" >&2
    return 1
  fi
  return "${pipeline_status[0]}"
}

confirm_batch() {
  summary=$1
  prompt=$2
  if ! { exec 3<>/dev/tty; } 2>/dev/null; then
    echo "nh-up: no controlling terminal; refusing approval" >&2
    return 1
  fi
  safe_summary="$summary.safe"
  if ! sanitize <"$summary" >"$safe_summary"; then
    exec 3>&-
    echo "nh-up: could not render approval evidence; refusing" >&2
    return 1
  fi
  if [ -t 3 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != dumb ]; then
    bold=$'\033[1m'
    cyan=$'\033[1;36m'
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[1;33m'
    reset=$'\033[0m'
  else
    bold=
    cyan=
    red=
    green=
    yellow=
    reset=
  fi
  while IFS= read -r line || [ -n "$line" ]; do
    case $line in
      "LOCK UPDATE REQUIRES APPROVAL" | "FIXED-OUTPUT BYTES REQUIRE APPROVAL")
        printf '%s%s%s\n' "$yellow" "$line" "$reset" >&3 || return 1
        ;;
      "GitHub source revisions:" | "Raw file, tarball, or native release assets:" | "Other locked source changes:" | "Lock graph metadata changes:" | "Exact locked records:")
        printf '%s%s%s\n' "$bold" "$line" "$reset" >&3 || return 1
        ;;
      "  root input "* | "  transitive node "* | "  "*.nix:[0-9]*)
        printf '%s%s%s\n' "$cyan" "$line" "$reset" >&3 || return 1
        ;;
      "    old:"*)
        printf '%s%s%s\n' "$red" "$line" "$reset" >&3 || return 1
        ;;
      "    new:"*)
        printf '%s%s%s\n' "$green" "$line" "$reset" >&3 || return 1
        ;;
      *) printf '%s\n' "$line" >&3 || return 1 ;;
    esac
  done <"$safe_summary"
  while IFS= read -r -t 0.01 -n 1 _ <&3; do :; done
  if ! printf '\n%s\nApprove all changes above? [y/N] ' "$prompt" >&3; then
    exec 3>&-
    echo "nh-up: could not render approval prompt; refusing" >&2
    return 1
  fi
  if ! IFS= read -r reply <&3; then
    exec 3>&-
    echo "nh-up: could not read approval; refusing" >&2
    return 1
  fi
  exec 3>&-
  case ${reply,,} in
    y | yes) return 0 ;;
    *) return 1 ;;
  esac
}

changed_node_count() {
  jq -nr --slurpfile old "$old_lock" --slurpfile new "$new_lock" '
    [
      ([($old[0].nodes | keys[]), ($new[0].nodes | keys[])] | unique[]) as $id
      | select(($old[0].nodes[$id] // null) != ($new[0].nodes[$id] // null))
    ] | length'
}

lock_top_level_unchanged() {
  jq -ne --slurpfile old "$old_lock" --slurpfile new "$new_lock" \
    '($old[0] | del(.nodes)) == ($new[0] | del(.nodes))' >/dev/null
}

show_lock_summary() {
  jq -nr --slurpfile old "$old_lock" --slurpfile new "$new_lock" '
    def rootnames($lock; $id):
      [$lock.nodes.root.inputs | to_entries[]
       | select(.value | type == "string")
       | select(.value == $id)
       | .key];
    def node_label($change):
      ((rootnames($new[0]; $change.id) + rootnames($old[0]; $change.id)) | unique) as $names
      | if ($names | length) > 0
        then "root input \($names | join(", ")) [node \($change.id)]"
        else "transitive node \($change.id)"
        end;
    def shortrev($pin):
      ($pin.rev // "<none>") as $rev
      | if ($rev | length) > 12 then $rev[0:12] else $rev end;
    def repository($pin):
      if ($pin.owner and $pin.repo) then "github.com/\($pin.owner)/\($pin.repo)" else "<unknown>" end;
    def canonical: to_entries | sort_by(.key) | from_entries | tojson;
    def compare($change):
      if ($change.old.owner == $change.new.owner
          and $change.old.repo == $change.new.repo
          and ($change.old.rev | type) == "string"
          and ($change.new.rev | type) == "string")
      then "\n    compare: https://github.com/\($change.new.owner)/\($change.new.repo)/compare/\($change.old.rev)...\($change.new.rev)"
      else ""
      end;
    [
      ([($old[0].nodes | keys[]), ($new[0].nodes | keys[])] | unique[]) as $id
      | {
          id: $id,
          oldnode: ($old[0].nodes[$id] // {}),
          newnode: ($new[0].nodes[$id] // {}),
          old: ($old[0].nodes[$id].locked // {}),
          new: ($new[0].nodes[$id].locked // {})
        }
      | select(.oldnode != .newnode)
    ] as $changes
    | ($changes | map(select(.old != .new))) as $locked
    | ($locked | map(select(.new.type == "file" or .new.type == "tarball"
                              or .old.type == "file" or .old.type == "tarball"))) as $raw
    | (($locked - $raw) | map(select(.new.type == "github" or .old.type == "github"))) as $github
    | ($locked - $github - $raw) as $other
    | ($changes | map(select((.oldnode | del(.locked)) != (.newnode | del(.locked))))) as $metadata
    | "\nLOCK UPDATE REQUIRES APPROVAL",
      (if ($github | length) > 0 then
        "\nGitHub source revisions:",
        ($github[] |
          "  \(node_label(.)):"
          + "\n    old: \(shortrev(.old))"
          + "\n    new: \(shortrev(.new))"
          + "\n    repository: \(repository(if .new.owner then .new else .old end))\(compare(.))")
       else empty end),
      (if ($raw | length) > 0 then
        "\nRaw file, tarball, or native release assets:",
        ($raw[] |
          "  \(node_label(.)):\n    URL: \(.new.url // .old.url // "<none>")"
          + (if .old.url != .new.url then "\n    old URL: \(.old.url // "<none>")" else "" end)
          + "\n    old: \(.old.narHash // "<none>")"
          + "\n    new: \(.new.narHash // "<none>")"),
        "  These are new unauthenticated bytes. The hash gives reproducibility, not publisher identity."
       else empty end),
      (if ($other | length) > 0 then
        "\nOther locked source changes:",
        ($other[] | "  \(node_label(.)):\n    old: \(.old | tojson)\n    new: \(.new | tojson)")
       else empty end),
      (if ($metadata | length) > 0 then
        "\nLock graph metadata changes:",
        ($metadata[] |
          "  \(node_label(.)):\n    old: \(.oldnode | del(.locked) | tojson)\n    new: \(.newnode | del(.locked) | tojson)")
       else empty end),
      (if ($locked | length) > 0 then
        "\nExact locked records:",
        ($locked[] |
          "  \(node_label(.)):\n    old: \(.old | canonical)\n    new: \(.new | canonical)")
       else empty end)'
}

root_name_for_url() {
  url=$1
  jq -r --arg url "$url" '
    . as $lock
    | [.nodes.root.inputs | to_entries[]
       | select(.value | type == "string")
       | select(($lock.nodes[.value].locked.url // "") == $url)
       | .key]
    | if length == 1 then .[0] else empty end' flake.lock
}

lock_pending=1
update_attempt=0
while :; do
  update_attempt=$((update_attempt + 1))
  update_log="$tmpdir/update-$update_attempt.log"
  if run_logged "$update_log" nix flake update; then
    break
  fi
  if [ "$log_failed" -eq 1 ]; then
    exit 1
  fi

  parse_log="$tmpdir/update-$update_attempt.parse"
  if ! sanitize <"$update_log" >"$parse_log"; then
    echo "nh-up: could not parse sanitized update output" >&2
    exit 1
  fi
  mapfile -t rot_urls < <(
    grep -E "mismatch in field '(narHash|lastModified)'" "$parse_log" \
      | grep -oE '"url":"[^"]+"' \
      | cut -d'"' -f4 \
      | sort -u
  )
  if [ "${#rot_urls[@]}" -eq 0 ] || [ "$update_attempt" -ge "$max" ]; then
    echo "nh-up: lock update failed; prior flake.lock will be restored" >&2
    exit 1
  fi

  repaired=0
  for url in "${rot_urls[@]}"; do
    name=$(root_name_for_url "$url")
    if [ -z "$name" ] || ! [[ $name =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
      echo "nh-up: mutable URL mismatch did not identify exactly one root input" >&2
      exit 1
    fi
    repair_log="$tmpdir/repair-$update_attempt-$repaired.log"
    if ! run_logged "$repair_log" nix flake update "$name"; then
      if [ "$log_failed" -eq 1 ]; then
        exit 1
      fi
      echo "nh-up: could not compute a candidate lock update for $name" >&2
      exit 1
    fi
    repaired=$((repaired + 1))
  done
done

if ! cmp -s -- "$old_lock" flake.lock; then
  candidate_lock="$tmpdir/candidate.lock"
  if ! cp -- flake.lock "$candidate_lock"; then
    echo "nh-up: could not preserve the candidate lock update; restoring it" >&2
    exit 1
  fi
  new_lock=$candidate_lock
  if ! lock_top_level_unchanged; then
    echo "nh-up: flake.lock changed outside its node graph; restoring it" >&2
    exit 1
  fi
  if ! count=$(changed_node_count); then
    echo "nh-up: could not inspect the candidate lock update; restoring it" >&2
    exit 1
  fi
  if [ "$count" -eq 0 ]; then
    echo "nh-up: flake.lock changed without an identifiable node change; restoring it" >&2
    exit 1
  fi
  summary="$tmpdir/lock-summary"
  if ! show_lock_summary >"$summary"; then
    echo "nh-up: could not summarize the candidate lock update; restoring it" >&2
    exit 1
  fi
  if ! confirm_batch "$summary" "This approval trusts the listed source revisions and downloaded bytes, then rebuilds and activates the host."; then
    echo "nh-up: lock update rejected; restoring prior flake.lock" >&2
    exit 1
  fi
  if ! cmp -s -- "$candidate_lock" flake.lock; then
    echo "nh-up: flake.lock changed during approval; restoring the prior lock" >&2
    exit 1
  fi
fi
lock_pending=0

while [ "$attempt" -lt "$max" ]; do
  attempt=$((attempt + 1))
  build_log="$tmpdir/build-$attempt.log"
  if run_logged "$build_log" "${nh_cmd[@]}" switch "$@"; then
    exit 0
  else
    status=$?
  fi
  if [ "$log_failed" -eq 1 ]; then
    exit 1
  fi
  if [ "$attempt" -ge "$max" ]; then
    echo "nh-up: giving up after $attempt rebuild attempts" >&2
    exit "$status"
  fi

  parse_log="$tmpdir/build-$attempt.parse"
  if ! sanitize <"$build_log" >"$parse_log"; then
    echo "nh-up: could not parse sanitized rebuild output" >&2
    exit 1
  fi
  mapfile -t spec < <(grep -oE 'specified:[[:space:]]*sha256-[A-Za-z0-9+/=]+' "$parse_log" | grep -oE 'sha256-[A-Za-z0-9+/=]+')
  mapfile -t got < <(grep -oE 'got:[[:space:]]*sha256-[A-Za-z0-9+/=]+' "$parse_log" | grep -oE 'sha256-[A-Za-z0-9+/=]+')

  if [ "${#spec[@]}" -eq 0 ] && [ "${#got[@]}" -eq 0 ]; then
    echo "nh-up: rebuild failed without a fixed-output hash mismatch" >&2
    exit "$status"
  fi
  if [ "${#spec[@]}" -ne 1 ] || [ "${#got[@]}" -ne 1 ]; then
    echo "nh-up: expected exactly one hash mismatch pair; refusing to edit" >&2
    exit "$status"
  fi

  declare -a files=()
  declare -A seen=()
  for i in "${!spec[@]}"; do
    s=${spec[$i]}
    g=${got[$i]}
    if [ "$s" = "$g" ] || [ -n "${seen[$s]:-}" ]; then
      echo "nh-up: ambiguous or duplicate hash mismatch; refusing to edit" >&2
      exit "$status"
    fi
    seen[$s]=1
    mapfile -t matches < <(git grep -lF -e "$s" -- '*.nix')
    mapfile -t occurrences < <(git grep -hoF -e "$s" -- '*.nix')
    if [ "${#matches[@]}" -ne 1 ] || [ "${#occurrences[@]}" -ne 1 ]; then
      echo "nh-up: $s appears ${#occurrences[@]} times in ${#matches[@]} tracked .nix files; refusing to edit" >&2
      exit "$status"
    fi
    files+=("${matches[0]}")
  done

  build_fixed_summary() {
    echo
    echo "FIXED-OUTPUT BYTES REQUIRE APPROVAL"
    for i in "${!spec[@]}"; do
      file=${files[$i]}
      s=${spec[$i]}
      g=${got[$i]}
      line=$(git grep -nF -e "$s" -- "$file" | head -n1 | cut -d: -f2)
      start=$((line > 6 ? line - 6 : 1))
      end=$((line + 2))
      printf '  %s:%s\n    old: %s\n    new: %s\n    source context:\n' "$file" "$line" "$s" "$g" || return
      nl -ba "$file" | sed -n "${start},${end}p" | sed 's/^/      /' || return
    done
    echo "  Accepting trusts the downloaded bytes. A matching hash proves reproducibility, not who published them."
  }
  fixed_summary="$tmpdir/fixed-summary-$attempt"
  if ! build_fixed_summary >"$fixed_summary"; then
    echo "nh-up: could not construct approval evidence" >&2
    exit "$status"
  fi

  if ! confirm_batch "$fixed_summary" "This approval applies the fixed-output hash change above, then retries the rebuild and activation."; then
    echo "nh-up: hash changes rejected; no source files were edited" >&2
    exit "$status"
  fi

  mapfile -t matches < <(git grep -lF -e "${spec[0]}" -- '*.nix')
  mapfile -t occurrences < <(git grep -hoF -e "${spec[0]}" -- '*.nix')
  if [ "${#matches[@]}" -ne 1 ] || [ "${#occurrences[@]}" -ne 1 ] || [ "${matches[0]:-}" != "${files[0]}" ]; then
    echo "nh-up: source changed during approval; refusing to edit" >&2
    exit "$status"
  fi

  fixed_file=${files[0]}
  fixed_original="$tmpdir/fixed-original-$attempt"
  fixed_edited="$tmpdir/fixed-edited-$attempt"
  if ! cp -- "$fixed_file" "$fixed_original" || ! cp -- "$fixed_file" "$fixed_edited"; then
    echo "nh-up: could not prepare the approved source edit" >&2
    exit "$status"
  fi
  if ! sed -i "s|${spec[0]}|${got[0]}|" "$fixed_edited"; then
    echo "nh-up: could not prepare the approved hash replacement" >&2
    exit "$status"
  fi
  if grep -qF -- "${spec[0]}" "$fixed_edited" || [ "$(grep -oF -- "${got[0]}" "$fixed_edited" | wc -l | tr -d ' ')" -lt 1 ]; then
    echo "nh-up: prepared hash replacement failed verification" >&2
    exit "$status"
  fi

  fixed_pending=1
  if ! cp -- "$fixed_edited" "$fixed_file" || ! cmp -s -- "$fixed_edited" "$fixed_file"; then
    echo "nh-up: hash replacement failed; restoring the source" >&2
    exit "$status"
  fi
  fixed_pending=0
  echo "nh-up: approved hashes written; retrying rebuild ($attempt/$max)" >&2
done

echo "nh-up: giving up after $attempt rebuild attempts" >&2
exit 1
