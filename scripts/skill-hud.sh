#!/bin/bash
# PostToolUse hook (matcher: Skill) — logs each skill invocation to a
# persistent state file that scripts/statusline.sh reads from.
set -euo pipefail

mkdir -p "$CLAUDE_PLUGIN_DATA"
state_file="$CLAUDE_PLUGIN_DATA/active-skills.txt"

input=$(cat)
skill=$(echo "$input" | python3 -c "
import json, sys
d = json.load(sys.stdin)
ti = d.get('tool_input', {})
name = ti.get('skill') or ti.get('name') or ti.get('skill_name') or ''
print(name)
" 2>/dev/null || true)

if [ -n "$skill" ] && [ "$skill" != "None" ]; then
    timestamp=$(date +%H:%M)
    tmpfile=$(mktemp)
    { echo "$timestamp  $skill"; cat "$state_file" 2>/dev/null || true; } | head -5 > "$tmpfile"
    mv "$tmpfile" "$state_file"
fi
