#!/bin/bash
# UserPromptSubmit hook — clears the skill HUD at the start of each new prompt.
set -euo pipefail

mkdir -p "$CLAUDE_PLUGIN_DATA"
> "$CLAUDE_PLUGIN_DATA/active-skills.txt"
