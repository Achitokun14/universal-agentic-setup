#!/usr/bin/env bash
# Creates IMPROVEMENT_STATE.json in any project folder that has CLAUDE.md but lacks the state file.
# Tracks iterations, changes, metrics per session.
set -euo pipefail

SEARCH_ROOTS=("$HOME/Desktop")
SKIP_GLOBS=("*/node_modules/*" "*/.cache/*" "*/.claude/plugins/*" "*/universal-agentic-setup/*")

should_skip() {
  local path="$1"
  for glob in "${SKIP_GLOBS[@]}"; do
    case "$path" in $glob) return 0 ;; esac
  done
  return 1
}

created=0
skipped=0

for root in "${SEARCH_ROOTS[@]}"; do
  while IFS= read -r claude_md; do
    project_dir="$(dirname "$claude_md")"
    should_skip "$project_dir" && continue

    state="$project_dir/IMPROVEMENT_STATE.json"
    if [[ -f "$state" ]]; then
      ((skipped++)) || true
      continue
    fi

    project_name="$(basename "$project_dir")"
    created_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    cat > "$state" <<JSON
{
  "\$schema": "https://github.com/Achitokun14/universal-agentic-setup/improvement-state.schema.json",
  "project": "$project_name",
  "path": "$project_dir",
  "created_at": "$created_at",
  "current_iteration": 0,
  "last_updated": "$created_at",
  "iterations": [],
  "metrics": {
    "total_files_touched": 0,
    "total_lines_added": 0,
    "total_lines_removed": 0,
    "total_commits": 0,
    "iterations_count": 0
  },
  "pending_todos": [],
  "completed_todos": [],
  "learnings": [],
  "dependencies_added": [],
  "resources_discovered": []
}
JSON
    echo "✓ created: $state"
    ((created++)) || true
  done < <(find "$root" -maxdepth 5 -name "CLAUDE.md" -not -path "*/node_modules/*" -not -path "*/.claude/plugins/*" 2>/dev/null)
done

echo ""
echo "Summary: $created created · $skipped already existed"
