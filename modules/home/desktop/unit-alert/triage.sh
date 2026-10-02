instance=$1
if [[ $instance == system:* ]]; then
  scope=system
  unit=${instance#system:}
else
  scope=user
  unit=$instance
fi

exec 9> "$XDG_RUNTIME_DIR/unit-triage.lock"
if ! flock -n 9; then
  echo "another triage is running; skipping $unit"
  exit 0
fi

report_dir=${XDG_STATE_HOME:-$HOME/.local/state}/unit-triage
mkdir -p "$report_dir"
report=$report_dir/$(date -u +%Y%m%dT%H%M%SZ)-$instance.md

allowed=(
  Read Grep Glob
  "Bash(journalctl)" "Bash(journalctl *)"
  "Bash(pw-dump)" "Bash(pw-dump *)"
  "Bash(wpctl status)" "Bash(wpctl status *)"
  "Bash(pw-cli info *)"
  "Bash(busctl --user get-property *)" "Bash(busctl get-property *)"
  "Bash(ps)" "Bash(ps *)" "Bash(pgrep *)"
  "Bash(cat /proc/*)"
  "Bash(ls)" "Bash(ls *)" "Bash(grep *)" "Bash(head *)" "Bash(tail *)"
  "Bash(jq *)" "Bash(wc *)"
  "Bash(uptime)" "Bash(free)" "Bash(free *)" "Bash(df)" "Bash(df *)"
  "Bash(ss *)" "Bash(id)" "Bash(id *)" "Bash(date)" "Bash(date *)"
  "Bash(nix-store -q *)"
)
for verb in status show cat list-units list-timers is-active is-failed; do
  allowed+=("Bash(systemctl $verb)" "Bash(systemctl $verb *)")
  allowed+=("Bash(systemctl --user $verb)" "Bash(systemctl --user $verb *)")
done

denied=(
  Edit Write NotebookEdit WebFetch WebSearch Agent Task ToolSearch
  "Read(~/.ssh/**)" "Read(//run/secrets/**)" "Read(//run/secrets.d/**)"
  "Read(~/.config/sops/**)" "Read(**/*.age)" "Read(**/secrets.yaml)"
)

echo "triaging $scope unit $unit -> $report"
status=0
printf 'Investigate the failed %s unit %s.\n' "$scope" "$unit" |
  timeout 840 claude -p \
    --model opus \
    --permission-mode dontAsk \
    --setting-sources project \
    --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
    --no-session-persistence \
    --output-format text \
    --append-system-prompt "$(cat "$PROMPT")" \
    --allowedTools "${allowed[@]}" \
    --disallowedTools "${denied[@]}" \
    > "$report" || status=$?

if ((status != 0)) || [[ ! -s $report ]]; then
  echo "triage failed for $unit (exit $status)"
  notify-send -a unit-triage "$unit triage failed" "exit $status; journalctl --user -u 'unit-triage@$instance.service'" || true
  exit 0
fi

cat "$report"
summary=$(sed -n '/^#* *Summary/,/^#/{/^#/d;/^[[:space:]]*$/d;p;q}' "$report")
notify-send -a unit-triage "$unit triage ready" "${summary:-no summary}
$report" || true
