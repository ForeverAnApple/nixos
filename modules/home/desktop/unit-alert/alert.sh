instance=$1
if [[ $instance == system:* ]]; then
  scope=system
  unit=${instance#system:}
  ctl=(systemctl)
else
  scope=user
  unit=$instance
  ctl=(systemctl --user)
fi

declare -A prop
while IFS='=' read -r key value; do
  prop[$key]=$value
done < <("${ctl[@]}" show "$unit" --property=ActiveState,SubState,NRestarts,Result)
active=${prop[ActiveState]:-unknown}
sub=${prop[SubState]:-unknown}
restarts=${prop[NRestarts]:-0}
result=${prop[Result]:-unknown}

state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/unit-alert
mkdir -p "$state_dir"
now=$(date +%s)
history=$state_dir/$instance.failures
spoken=${unit%.service}
spoken=${spoken//[-_@.:]/ }

# Voice only if the unit is still failed after restarts had time to work, or every
# restart keeps dying (6 failures in 30min is the backoff's pace when nothing survives).
# A deliberate stop leaves it inactive, not failed, and stays silent.
if [[ ${2:-} == recheck ]]; then
  recent=0
  [[ -f $history ]] && recent=$(awk -v cutoff=$((now - 1800)) '$1 >= cutoff' "$history" | wc -l)
  if [[ $active == failed ]] || ((recent >= 6)); then
    echo "still down: $scope unit $unit: $active/$sub, $recent failures in 30min"
    notify-send -u critical -a unit-alert "$unit still down" "$active/$sub, $recent failures in 30min. Needs you." || true
    "$SAY" "$spoken is still down and needs you"
  else
    echo "recovered: $scope unit $unit: $active/$sub, $recent failures in 30min"
  fi
  exit 0
fi

# NRestarts never resets for units that restart on their own, so flapping is
# counted per window instead.
{
  [[ -f $history ]] && awk -v cutoff=$((now - 1800)) '$1 >= cutoff' "$history"
  echo "$now"
} > "$history.tmp"
mv "$history.tmp" "$history"
recent=$(wc -l < "$history")

case $sub in auto-restart*) recovering=1 ;; *) recovering=0 ;; esac
case $active in active | activating | reloading | refreshing) recovering=1 ;; esac

summary="$scope unit $unit: $active/$sub, result=$result, NRestarts=$restarts, $recent failures in 30min"

if ((recovering && recent < 3)); then
  echo "transient: $summary"
  exit 0
fi

stamp=$state_dir/$instance.alerted
if [[ -f $stamp ]] && ((now - $(stat -c %Y "$stamp") < 3600)); then
  echo "rate-limited: $summary"
  exit 0
fi
touch "$stamp"

echo "alert: $summary"
body="$result, $restarts restarts, $recent in 30min ($scope)"

if ! grep -Fxq "$scope:$unit" <<< "$WATCHED"; then
  notify-send -a unit-alert "$unit failed" "$body" || true
  exit 0
fi

notify-send -u critical -a unit-alert "$unit failed" "$body" || true
systemd-run --user --quiet --collect --no-block --on-active=3min -- "$0" "$instance" recheck || true
