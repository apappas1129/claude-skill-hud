---
name: skill-hud-setup
description: One-time setup that wires the Claude Skill HUD status line into the user's global settings.json. Run this once, right after installing the claude-skill-hud plugin, to finish activating the HUD.
disable-model-invocation: true
---

# Skill HUD setup

The `claude-skill-hud` plugin's hooks (which log skill invocations) are
already active now that the plugin is installed. The one piece a plugin
cannot wire up automatically is the main session **status line** — that's a
plain user-level `settings.json` field, not a plugin-managed component, so it
needs to be written once, explicitly.

This skill's job: add that one `statusLine` entry, without touching anything
else already in the user's settings.

## Resolved paths for this install

These paths were substituted into this skill's content when it loaded, so
they're already correct for wherever this plugin is installed on this
machine:

- Plugin root: `${CLAUDE_PLUGIN_ROOT}`
- Persistent data directory: `${CLAUDE_PLUGIN_DATA}`
- Status line script: `${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh`

## Steps

1. Read `~/.claude/settings.json`. If it doesn't exist, treat it as `{}`.

2. Check the existing `statusLine` key, if any:
   - If it's already set to a command containing `scripts/statusline.sh` from
     this plugin's root, the HUD is already configured — tell the user this
     and stop, no changes needed.
   - If a *different* `statusLine` is already configured (the user has their
     own custom one), stop and ask the user how they want to proceed. Do not
     silently overwrite it. Options: replace it, or skip HUD setup and let
     the user merge it manually.
   - If no `statusLine` key exists, proceed to step 3.

3. Add this exact block to the settings JSON, merging it in alongside any
   other existing top-level keys (do not remove or reorder unrelated keys):

   ```json
   "statusLine": {
     "type": "command",
     "command": "CLAUDE_PLUGIN_DATA=\"${CLAUDE_PLUGIN_DATA}\" \"${CLAUDE_PLUGIN_ROOT}/scripts/statusline.sh\""
   }
   ```

   The `CLAUDE_PLUGIN_DATA=...` prefix is required: the main status line
   runs outside the plugin hook/MCP substitution system, so this is the one
   place that env var has to be set explicitly rather than relying on
   automatic injection.

4. Write the updated settings file back, preserving existing formatting and
   keys as much as possible.

5. Confirm to the user in one or two sentences that the HUD is active, and
   mention that a new session (or `/statusline` reload if supported) is
   needed for the change to take effect. Also mention how to undo: remove
   the `statusLine` key from `~/.claude/settings.json`, or run
   `/plugin uninstall claude-skill-hud`.
