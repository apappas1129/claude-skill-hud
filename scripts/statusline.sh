#!/bin/bash
# Skill HUD status line — reads active-skills.txt written by scripts/skill-hud.sh.
# Expects $CLAUDE_PLUGIN_DATA to be set in the environment (the setup skill
# inlines this when it writes the statusLine command into settings.json,
# since the main session status line isn't a plugin-substituted context).
cat > /dev/null  # consume stdin from Claude Code

state_file="$CLAUDE_PLUGIN_DATA/active-skills.txt"

# Terminal width in columns; tput reads /dev/tty directly, independent of stdin.
# Falls back to 80 if no tty is attached.
width=$(tput cols 2>/dev/null)
[ -z "$width" ] && width=80

if [ -f "$state_file" ] && [ -s "$state_file" ]; then
    mapfile -t names < <(awk '{print $2}' "$state_file")
    count=${#names[@]}

    oneline="⚡ ${names[*]}"
    margin=4  # leave a small margin so the line doesn't hug the terminal edge

    if [ $((${#oneline} + margin)) -le "$width" ]; then
        echo -e "\033[36m⚡\033[0m \033[1m${names[*]}\033[0m"
    else
        echo -e "\033[36m⚡ $count skills invoked\033[0m"
        for n in "${names[@]}"; do
            echo -e "  \033[1m$n\033[0m"
        done
    fi
else
    echo -e "\033[90m○ no skills invoked\033[0m"
fi
