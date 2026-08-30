# bin/toolkit.sh

Syncs this repo's `AGENTS.md`, `guidelines/`, and `skills/` into Claude Code,
opencode, and Codex — globally (`~`) or into a single project — via symlinks,
so this repo stays the single source of truth and edits here are instantly
live everywhere they're installed.

`skills/` is split into `skills/global/` and `skills/project/`. Which one is
used follows the install scope: `--global` only discovers and links
`skills/global/*`, `--project` only discovers and links `skills/project/*`.
`--skill NAME` filters within whichever set the scope selected.

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

For each selected agent, `install` symlinks these into `<base>`
(`$HOME` for `--global`, the current directory for `--project`):

| Agent | AGENTS file | guidelines | skills | agents |
|---|---|---|---|---|
| claude | `<base>/.claude/CLAUDE.md` | `<base>/.claude/guidelines` | `<base>/.claude/skills/<name>` | `<base>/.claude/agents` → `agents/claude` |
| opencode | `<base>/.opencode/AGENTS.md` | `<base>/.opencode/guidelines` | `<base>/.opencode/skills/<name>` | `<base>/.opencode/agent` → `agents/opencode` |
| codex | `<base>/.codex/AGENTS.md` | `<base>/.codex/guidelines` | `<base>/.codex/skills/<name>` | — |

`AGENTS.md` is always the source file — Claude's copy is just symlinked under
a different name (`CLAUDE.md`), since a symlink's name doesn't have to match
its target's.

The `agents` column is subagent definitions (`--global` only), symlinked as a
whole folder like `guidelines`. It's host-specific — Claude and opencode use
different frontmatter and different `model` slugs — so the repo keeps one
subdir per host (`agents/claude`, `agents/opencode`) and each host links its
own. Codex has no subagent primitive and gets nothing. Today this is just
`code-reviewer`, spawned by the `code-review` skill so that review runs on a
cheap model instead of the implementing one.

The `skills` source depends on scope: `--global` links from
`skills/global/<name>`, `--project` links from `skills/project/<name>`. Either
way the link target in the agent's directory is flat (`skills/<name>`, no
`global`/`project` segment). Each skill is symlinked individually, not the
whole folder, so any host-specific skill that isn't part of this repo — e.g.
something you've dropped straight into `~/.opencode/skills/` — is left alone.

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

Skills `update` prunes because they were deleted from this repo are backed
up the same way, not hard-deleted, so nothing is unrecoverable.

## Adding or removing a skill

Drop a new folder with a `SKILL.md` into `skills/global/<name>/` (installed
with `--global`) or `skills/project/<name>/` (installed with `--project`) in
this repo, commit it, then run `./bin/toolkit.sh update -y` (or `install`
again for a specific target). `update` remembers every scope+agent
combination you've installed to before (recorded in
`~/.personal-toolkit/installs.json`) and re-syncs all of them, so the new
skill gets symlinked everywhere automatically — you don't need to re-specify
`--global`/`--project`/`--agent` each time.

`update` also prunes deletions: if you delete a skill's folder from this repo
and commit it, the next `update` removes its stale symlink from every
installed target too (moved to a timestamped backup, same as any other
replaced path — see Conflicts below). Pruning is scoped: a project-scope
`update` only prunes symlinks pointing back into `skills/project/`, a
global-scope `update` only prunes symlinks pointing back into
`skills/global/` — each scope leaves the other's skills, and anything you've
dropped straight into an agent's `skills/` folder outside this toolkit,
alone. This pruning only happens on `update`; a scoped `install --skill NAME`
never removes other skills.

## State files (not tracked in git)

- `~/.personal-toolkit/installs.json` — manifest of every scope+agent install
  ever run, used by `update` to know what to re-sync.
- `~/.personal-toolkit/backups/` — timestamped backups of anything replaced
  by a symlink.
