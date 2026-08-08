# bin/toolkit.sh

Syncs this repo's `AGENTS.md`, `guidelines/`, and `skills/` into Claude Code,
opencode, and Codex — globally (`~`) or into a single project — via symlinks,
so this repo stays the single source of truth and edits here are instantly
live everywhere they're installed.

## Commands

```bash
# Guided install (arrow-key prompts for scope + agents)
./bin/toolkit.sh install

# Non-interactive: global install for all three agents
./bin/toolkit.sh install --global --agent claude --agent opencode --agent codex -y

# Non-interactive: project install for Claude only
cd ~/Documents/repos/some-project
/Users/sunil/Documents/repos/personal-toolkit/bin/toolkit.sh install --project --agent claude -y

# Pull latest changes and re-sync every target you've ever installed to
./bin/toolkit.sh update -y
```

Run `./bin/toolkit.sh --help` for the full flag list (`--global`, `--project`,
`--agent NAME` (repeatable), `--skill NAME` (repeatable, defaults to all), `-y`).

### Adding a new project (interactively)

Project scope always targets the current directory (`$PWD`) — there's no flag
to point at a project without being in it. To add a new project via the
guided TUI, `cd` into it first, then run install with no flags:

```bash
cd ~/Documents/repos/some-other-project
/Users/sunil/Documents/repos/personal-toolkit/bin/toolkit.sh install
```

Pick "Project - <that path>" at the scope prompt, then tick the agents you
want. This adds a new entry to `~/.personal-toolkit/installs.json` alongside
your existing global/project installs — it doesn't replace them. You only
need to do this once per project; after that, `update` re-syncs it too.

## What gets linked

For each selected agent, `install` symlinks three things into `<base>`
(`$HOME` for `--global`, the current directory for `--project`):

| Agent | AGENTS file | guidelines | skills |
|---|---|---|---|
| claude | `<base>/.claude/CLAUDE.md` | `<base>/.claude/guidelines` | `<base>/.claude/skills/<name>` |
| opencode | `<base>/.opencode/AGENTS.md` | `<base>/.opencode/guidelines` | `<base>/.opencode/skills/<name>` |
| codex | `<base>/.codex/AGENTS.md` | `<base>/.codex/guidelines` | `<base>/.codex/skills/<name>` |

`AGENTS.md` is always the source file — Claude's copy is just symlinked under
a different name (`CLAUDE.md`), since a symlink's name doesn't have to match
its target's.

Each skill is symlinked individually (`skills/<name>`, not the whole
`skills/` folder), so any host-specific skill that isn't part of this repo —
e.g. something you've dropped straight into `~/.opencode/skills/` — is left
alone.

## Conflicts

If a target path already exists and isn't already the correct symlink, it's
moved (not deleted) to a timestamped backup before linking:

```
~/.personal-toolkit/backups/<UTC-timestamp>/<mirrored-path>
```

For example, an old real copy at `~/.claude/skills/code-review` gets moved to
`~/.personal-toolkit/backups/20260808T120000Z/.claude/skills/code-review`.
Running install/update again when everything's already correctly linked is a
no-op — nothing gets backed up twice.

## Adding a new skill

Drop a new folder with a `SKILL.md` into `skills/` in this repo, commit it,
then run `./bin/toolkit.sh update -y` (or `install` again for a specific
target). `update` remembers every scope+agent combination you've installed to
before (recorded in `~/.personal-toolkit/installs.json`) and re-syncs all of
them, so the new skill gets symlinked everywhere automatically — you don't
need to re-specify `--global`/`--project`/`--agent` each time.

## State files (not tracked in git)

- `~/.personal-toolkit/installs.json` — manifest of every scope+agent install
  ever run, used by `update` to know what to re-sync.
- `~/.personal-toolkit/backups/` — timestamped backups of anything replaced
  by a symlink.
