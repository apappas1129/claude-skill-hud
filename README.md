# Claude Skill HUD

A minimalist status-line HUD for [Claude Code](https://claude.com/claude-code) that shows which skills Claude invoked while working on your prompt.

```
⚡ testing-for-json-web-token-vulnerabilities
```

When more than one skill fires — or the names are too long to fit your terminal width — it wraps automatically:

```
⚡ 3 skills invoked
  implementing-zero-trust-network-access-with-zscaler
  performing-active-directory-vulnerability-assessment
  implementing-continuous-security-validation-with-bas
```

When no skill has been invoked for the current turn:

```
○ no skills invoked
```

## Why

Claude Code's [Skill](https://code.claude.com/docs/en/skills) system loads full skill content on demand, and Claude decides when a skill is relevant. That's great for context efficiency, but it also means skill activation is otherwise invisible — you don't know whether Claude used a skill, or which one, unless you go dig through the transcript. This plugin surfaces that at a glance, always visible at the bottom of your terminal.

It works with **any** installed skill, not a specific pack — if you have skills installed at all (personal, project, or plugin-provided), this HUD will report on them.

## How it works

- A `PostToolUse` hook (matching the `Skill` tool) logs the invoked skill's name and a timestamp to a small state file each time a skill runs.
- A `UserPromptSubmit` hook clears that state file at the start of every new prompt, so the HUD always reflects only the current turn.
- A status line script reads the state file and renders it, switching between a single-line and a multi-line layout depending on your terminal's actual column width (via `tput cols`) so long skill names don't get cut off or wrap awkwardly.

Timing note: the HUD updates **after** a skill's tool call completes, not the instant Claude decides to invoke it. If that's fine for your use case (it usually is — the lag is under a second), read on.

## Install

```
/plugin marketplace add apappas1129/claude-skill-hud
/plugin install claude-skill-hud@claude-skill-hud
```

This installs the hooks, which start logging skill invocations to a persistent per-plugin data directory immediately. It does **not** yet show anything on screen — one more step is needed.

### Finish setup (one time)

Plugins can register hooks automatically, but the main session status line is a plain, user-level `settings.json` field that plugins can't wire up on their own. Run this once, right after installing:

```
/skill-hud-setup
```

This adds a `statusLine` entry to your `~/.claude/settings.json` pointing at this plugin's rendering script. It's idempotent (safe to run again) and won't clobber a status line you've already configured — it'll ask first if one exists.

Start a new session (or restart Claude Code) for the status line to take effect.

## Uninstall / revert

```
/plugin uninstall claude-skill-hud
```

Then remove the `statusLine` key from `~/.claude/settings.json` (or ask Claude to do it for you) if you don't want a custom status line configured anymore.

## Limitations

- **Auto-invocation isn't guaranteed.** Claude decides whether a prompt matches a skill's description closely enough to invoke it automatically. A relevant skill existing doesn't mean it will always fire — this HUD reports what actually happened, not what could have.
- **Post-hoc timing.** The HUD lights up after the skill's tool call resolves, not the moment Claude begins "thinking about" using it. There's no hook event in Claude Code for skill-selection-in-progress at this time.
- **Typed `/skill-name` invocations don't register.** When you type a skill name directly as your prompt (e.g. `/skill-hud-setup`, `/code-review`), Claude Code expands it as a command rather than routing it through an actual `Skill` tool call, so the `PostToolUse` hook this HUD relies on never fires. The HUD only lights up for skills Claude invokes itself mid-conversation — automatically, or because you asked in natural language ("use the X skill to..."). This was confirmed by testing, not assumed.
- **No hard cap besides display width.** The underlying log keeps the 5 most recent invocations per turn; more than that in a single turn is uncommon but will only show the latest 5.
- **Requires a real terminal.** Width detection (`tput cols`) needs an attached tty. In non-interactive contexts it falls back to an 80-column assumption.

## License

MIT — see [LICENSE](./LICENSE).
