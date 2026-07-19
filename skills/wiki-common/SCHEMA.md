# LLM Wiki Schema

Shared conventions for `wiki-ingest`, `wiki-add`, `wiki-query`, and `wiki-lint`. Every one of those skills reads this file before touching a project's wiki — it's the single source of truth for layout and format. Don't restate these conventions inside the individual skills; link back here.

## Layout

At the target project's root:

```
raw/                        immutable source files — never edited by any skill
wiki/
  index.md                  flat catalog of every wiki page (see below)
  log.md                    append-only ingest history
  manifest.json             {relpath: {hash, ingested_at, pages_touched}} for every raw/ file processed
  <topic>.md                wiki pages, flat, kebab-case filenames
```

`raw/`, `wiki/manifest.json`, and `wiki/` itself are local working state, not source — add them to the project's `.gitignore` if not already present. `wiki/index.md`, `wiki/log.md`, and the pages under `wiki/` are the artifact worth keeping; whether those are committed is the user's call per project.

No vector DB, no embeddings, no Obsidian, no graph viewer. Navigation is `index.md` plus grep.

## Page frontmatter (OKF subset)

Every wiki page starts with YAML frontmatter:

```yaml
---
type: concept        # concept | entity | decision | reference | summary
title: Authentication Flow
description: One-sentence description of what this page covers.
tags: [auth, security]
timestamp: 2026-07-19T10:00:00Z   # last-updated, ISO 8601
---
```

`type` is required; the rest are recommended. Controlled vocabulary for `type`:

- **concept** — an idea, mechanism, or process
- **entity** — a specific person, system, service, or component
- **decision** — a choice made and its rationale (distinct from an ADR — this is knowledge-base synthesis, not a project governance record)
- **reference** — durable facts, specs, API shapes
- **summary** — a digest of a source or a filed query answer

`timestamp` is what `wiki-lint` uses to decide which of two conflicting claims is newer.

## Page Contents block

Right after the frontmatter, every page carries a short outline of its own sections — PageIndex-inspired, but disclosed progressively: it lives on the page it describes, not duplicated in `index.md`.

```markdown
---
type: concept
title: Authentication Flow
...
---

## Contents
- **Login flow** — password + OAuth paths, redirect handling
- **Token refresh** — rotation policy, edge cases on expiry
- **Known issues** — open contradictions or gaps

<page content follows, one `##` per Contents entry>
```

This is what lets `/wiki-query` reason down to the right *section* of a shortlisted page by reading just this block — not the whole file, and not a duplicate copy in the index.

## index.md format

Flat catalog: one entry per page, page-level only. Cheap to read in full on every run, however large the wiki gets — the section-level detail lives in each page's own Contents block, not here.

```markdown
# Wiki Index
> Run /wiki-ingest to keep this current. Run /wiki-query to ask questions against the wiki.

## <Category>

- [Page Title](topic-file.md) — type: concept · tags: auth, security — one-line page summary
```

Categories are loose groupings the agent maintains (e.g. by `type` or by subject area) — not a fixed enum.

## log.md format

Append-only, one entry per skill run:

```markdown
## [2026-07-19] ingest | Source Title
- created: topic-a.md
- updated: topic-b.md (added section on X)
- flagged: contradicts topic-c.md on Y — left for /wiki-lint
```

Use `ingest`, `add`, `query`, or `lint` as the operation tag so entries are greppable by kind.

## manifest.json format

```json
{
  "raw/some-doc.pdf": {
    "hash": "sha256:...",
    "ingested_at": "2026-07-19T10:00:00Z",
    "pages_touched": ["wiki/authentication-flow.md"]
  }
}
```

Managed via `scripts/wiki_diff.py` — never hand-edit.

## Scripts

- `scripts/wiki_diff.py check --raw <dir> --manifest <path>` — prints JSON `{"new": [...], "changed": [...], "removed": [...]}` for files in `raw/` not yet reflected in the manifest (new file, or hash changed since last ingest). Pure hash comparison — no LLM judgment involved in "what's new". Stdlib-only — run directly with `python3`, no venv needed.
- `scripts/wiki_diff.py mark --raw <dir> --manifest <path> --file <relpath> --pages <page1,page2>` — call once a source file has actually been synthesized into pages, to update its manifest entry. Marking per-file (not per-batch) means a mid-run failure doesn't falsely mark unprocessed files as done. Also stdlib-only.
- `scripts/wiki_convert.py <file> [--out <path>]` — converts a non-text source (PDF, DOCX, PPTX, XLSX, etc.) to Markdown via MarkItDown. Only needed for extensions that aren't already `.md`/`.txt`. This one has a real dependency, so it runs through `wiki-common`'s own `.venv` via `uv run --project <path-to-wiki-common> python scripts/wiki_convert.py <file>` — see the README's setup section for creating that venv once. If the venv or MarkItDown is missing, the command fails with an explicit setup instruction; don't attempt to parse binary formats without it.

`wiki-common` carries its own `pyproject.toml` + `.venv`, isolated from any target project's own Python environment — the wiki-ingest pipeline never touches or assumes anything about the project it's ingesting into.
