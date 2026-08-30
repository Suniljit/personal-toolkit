---
name: repo-index
description: >
  Root INDEX.md, the repo's navigation map: survey the tree to write it, or check it for drift since the last indexed commit.
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
argument-hint: "build | lint"
---

# Repo Index

`INDEX.md` at the project root is the repo's **map** — what each top-level folder and root file covers, read first by anything navigating an unfamiliar part of the tree ([`AGENTS.md`](../../AGENTS.md), Repo Navigation). A map goes stale the moment the tree moves under it, so this skill has two flows: **survey** the tree to draw the map, and lint it for **drift** against the commits since it was last drawn.

| First word | Flow |
|---|---|
| `build` | Survey the whole tree and write `INDEX.md` from [`template.md`](template.md) |
| `lint` | Diff the tree against the map's `indexed_commit`, fix what drifted |

No first word given: `lint` when `INDEX.md` exists and carries an `indexed_commit`, `build` otherwise.

## What the map covers

Every top-level folder and root file, one line each — enough for an agent to pick where to look. How deep to nest below that, and how each `docs/` subfolder is listed, are the template's business; read [`template.md`](template.md) before writing.

Enumerate with `git ls-files`, so the map inherits `.gitignore` and generated or vendored trees never reach it:

```bash
git ls-files | awk -F/ 'NF>1 {print $1"/"} NF==1 {print $1}' | sort -u
```

A folder's line comes from its contents, not its name: read its README, its `SKILL.md`, or a few representative files before describing it. Where a folder holds many peers (skills, commands, packages), name them in the line — that enumeration is what makes the map answer "which one do I want?" without a second search.

### Known doc homes

These carry fixed meanings across projects; describe them as such when present.

| Path | Holds | Written by |
|---|---|---|
| `docs/design/` | Seven-doc technical suite — PRD, app flow, design brief, TDD, data schema, API contracts, NFR | `/tech-docs` |
| `docs/adr/` | Accepted architecture decision records | `/domain-modeling` |
| `guidelines/` | Scoped coding-standard docs referenced by `AGENTS.md`'s Code Quality table | — |

### Row ownership

`/tech-docs` owns the `## Design` table's rows. Carry existing rows through verbatim; add the empty table (header only) when `docs/design/` exists without one. Every other docs section is yours — enumerate its files and write a row for each, reading enough of each document to describe what it decides or specifies.

## Flow: build

1. **Survey.** Enumerate the tree, then read into each top-level entry until you can say in one line what it covers and what a reader would come here for. Complete when every entry from the `git ls-files` enumeration has a line — or a stated reason it earns none.
2. **Write** `INDEX.md` from [`template.md`](template.md), preserving any existing Design table.
3. **Stamp** the frontmatter: `indexed_commit` = `git rev-parse HEAD`, `last_updated` = today.

## Flow: lint

1. **Read** `INDEX.md`'s `indexed_commit`. Absent, or `git cat-file -e <sha>` fails: say so and run the `build` flow instead.
2. **Diff** — the whole point of the stamp is that this replaces re-reading the tree:

```bash
git diff --name-status <indexed_commit> HEAD
git status --porcelain
```

3. **Reduce to structural drift.** Most changed paths move nothing on the map. A path drifts the map only when it:
   - adds, removes, or renames a top-level folder or root file
   - adds or removes a known doc home, or a file inside one
   - adds, removes, or renames a `docs/` subfolder (known or not — every `docs/` subfolder gets its own section per [`template.md`](template.md)), or a document inside one
   - lands inside a folder whose map line **enumerates** its contents (skills, commands, packages), changing that enumeration
   - repurposes a folder, so its existing line now misdescribes it

4. **Report** the drift as a table — path, what drifted, the fix — before editing. Complete when every path from step 2 is either in the table or dismissed as non-structural.
5. **Fix and re-stamp.** Apply each row to `INDEX.md`, touching only the lines the drift names, and set `indexed_commit` to `HEAD`. Report a clean map as clean and leave the file alone apart from the stamp.

## Completion criterion

`INDEX.md` has a line for every top-level entry `git ls-files` reports, and its `indexed_commit` equals `git rev-parse HEAD`.
