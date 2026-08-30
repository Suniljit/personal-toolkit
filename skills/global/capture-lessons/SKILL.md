---
name: capture-lessons
description: Scan a rough agent session for friction and propose durable fixes routed to global AGENTS.md, project AGENTS.md, .agent-personal/, or a skill.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
argument-hint: "optional: a specific friction to capture"
---

# Capture Lessons

A session hits **friction** whenever the agent lacks an instruction it needed: it burns tool calls discovering the environment (a CLI missing or at a non-standard path), guesses a convention wrong, gets corrected by the user, or re-derives something that could have been written down once. This skill scans the session for friction and turns each one into a durable rule in the right home.

If the user named a specific friction in the arguments, capture just that; otherwise scan the whole session.

## The four homes

Route each rule by *who* the friction affects and *what shape* the fix is:

| Home | When |
|---|---|
| `.agent-personal/<topic>.md` at the repo root | Specific to this user in this repo — their machine's tool paths, a local setup quirk, a personal preference. Writing it into a shared file would burn tokens for teammates. |
| Project `AGENTS.md` or `guidelines/` | Hits anyone working in this repo — a build step, a naming convention, a repo-specific gotcha. |
| Global `AGENTS.md` / `CLAUDE.md` (home directory) | Would recur in any repo — a cross-project workflow, a standing preference, a correction to how the agent behaves. |
| A skill — new, or an edit to an existing one | The fix is a multi-step procedure tied to a task type, not an always-on rule. |

When two homes fit, prefer the narrowest: `.agent-personal/` over project, project over global.

## Steps

1. **Scan** the session start-to-now for friction. List each: what the agent didn't know, and the cost (tool calls wasted, wrong turn taken, user correction).
2. **Draft** the minimal rule that would have prevented each — the fewest lines that change behaviour. Follow [`writing-for-agents`](../writing-for-agents/SKILL.md): front-load the trigger, cut no-ops, no speculative scope.
3. **Route** each rule to one of the four homes. Name the exact target file.
4. **Present** the full list — friction, rule text, target file — and stop for the user's approval. Don't edit yet.
5. **Apply** each approved rule to its file. Create `.agent-personal/` and the topic file if missing, and add `.agent-personal/` to `.git/info/exclude` (leave the shared `.gitignore` untouched) so it stays local.

## Global edits in this toolkit

If the global `AGENTS.md` is synced from the `personal-toolkit` repo via `bin/toolkit.sh`, edit the copy in that repo rather than the installed one, then tell the user to run `bin/toolkit.sh update`.

## Completion criterion

Every friction from the scan is either written into a target file the user approved, or explicitly dropped at the user's call.
