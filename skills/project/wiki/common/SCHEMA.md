# LLM Wiki Schema

Shared conventions for the `wiki` skill's ingest, add, query, and lint flows. Every one of those flows reads this file before touching a project's wiki — it's the single source of truth for layout and format. Don't restate these conventions inside the individual flow files; link back here.

## Layout

At the target project's root:

```
wiki/
  raw/                      immutable source files — never edited by any skill
  pages/                    wiki pages, flat, kebab-case filenames
    <topic>.md
  WIKI_INDEX.md             flat catalog of every wiki page (see below)
  log.md                    append-only ingest history
  manifest.json             {relpath: {hash, ingested_at, pages_touched}} for every wiki/raw/ file processed
```

`wiki/raw/` and `wiki/manifest.json` are local working state, not source — add them to the project's `.gitignore` if not already present, even if `wiki/` itself ends up tracked. `wiki/WIKI_INDEX.md`, `wiki/log.md`, and the pages under `wiki/pages/` are the artifact worth keeping; whether those are committed is the user's call per project (default: the whole `wiki/` directory is gitignored until the user opts in).

Querying and linting operate over `wiki/pages/` only — `wiki/raw/` is ingestion input, never a page, and lives outside that folder for exactly this reason.

No vector DB, no embeddings, no Obsidian, no graph viewer. Navigation is `WIKI_INDEX.md` plus grep.

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

`timestamp` is what the lint flow uses to decide which of two conflicting claims is newer.

## Page Contents block

Right after the frontmatter, every page carries a short outline of its own sections — PageIndex-inspired, but disclosed progressively: it lives on the page it describes, not duplicated in `WIKI_INDEX.md`.

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

This is what lets the query flow reason down to the right *section* of a shortlisted page by reading just this block — not the whole file, and not a duplicate copy in the index.

## WIKI_INDEX.md format

Flat catalog: one entry per page, page-level only. Cheap to read in full on every run, however large the wiki gets — the section-level detail lives in each page's own Contents block, not here. Lives in `wiki/` itself (not `wiki/pages/`) — it's an index over the pages, not one of them, same tier as `log.md` and `manifest.json`. Named `WIKI_INDEX.md`, not `index.md`, to avoid colliding with a project's own root `INDEX.md`.

```markdown
# Wiki Index
> Run /wiki ingest to keep this current. Run /wiki query to ask questions against the wiki.

## <Category>

- [Page Title](pages/topic-file.md) — type: concept · tags: auth, security — one-line page summary
```

Categories are loose groupings the agent maintains (e.g. by `type` or by subject area) — not a fixed enum.

## log.md format

Append-only, one entry per skill run:

```markdown
## [2026-07-19] ingest | Source Title
- created: topic-a.md
- updated: topic-b.md (added section on X)
- flagged: contradicts topic-c.md on Y — left for /wiki lint
```

Use `ingest`, `add`, `query`, or `lint` as the operation tag so entries are greppable by kind.

## manifest.json format

```json
{
  "raw/some-doc.pdf": {
    "hash": "sha256:...",
    "ingested_at": "2026-07-19T10:00:00Z",
    "pages_touched": ["wiki/pages/authentication-flow.md"]
  }
}
```

Managed via `scripts/wiki_diff.py` — never hand-edit.

## Scripts

- `scripts/wiki_diff.py check --raw wiki/raw/ --manifest wiki/manifest.json` — prints JSON `{"new": [...], "changed": [...], "removed": [...]}` for files in `wiki/raw/` not yet reflected in the manifest (new file, or hash changed since last ingest). Pure hash comparison — no LLM judgment involved in "what's new". Stdlib-only — run directly with `python3`, no venv needed.
- `scripts/wiki_diff.py mark --raw wiki/raw/ --manifest wiki/manifest.json --file <relpath> --pages <page1,page2>` — call once a source file has actually been synthesized into pages, to update its manifest entry. Marking per-file (not per-batch) means a mid-run failure doesn't falsely mark unprocessed files as done. Also stdlib-only.
- `scripts/wiki_convert.py <file> [--out <path>]` — converts a non-text source (PDF, DOCX, PPTX, XLSX, etc.) to Markdown via MarkItDown. Only needed for extensions that aren't already `.md`/`.txt`. This one has a real dependency, so it runs through `common/`'s own `.venv` via `uv run --project common python scripts/wiki_convert.py <file>` — see the README's setup section for creating that venv once. If the venv or MarkItDown is missing, the command fails with an explicit setup instruction; don't attempt to parse binary formats without it.

`common/` carries its own `pyproject.toml` + `.venv`, isolated from any target project's own Python environment — the ingest flow never touches or assumes anything about the project it's ingesting into.
