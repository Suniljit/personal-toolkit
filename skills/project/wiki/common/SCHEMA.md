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

## Page frontmatter (OKF v0.2 subset)

Every wiki page starts with YAML frontmatter:

```yaml
---
type: concept        # concept | entity | decision | reference | summary
title: Authentication Flow
description: One-sentence description of what this page covers.
tags: [auth, security]
generated: { by: wiki/<model-id>, at: 2026-07-19T10:00:00Z }   # who wrote this content, when it last meaningfully changed
sources:                                          # the wiki/raw/ files this page was synthesized from
  - id: auth-notes
    resource: /raw/adhoc-2026-07-19-auth-notes.md
    title: Auth design notes
    last_modified: 2026-07-18T00:00:00Z           # the raw file's mtime
status: stable                                    # draft | stable | deprecated — omit ⇒ stable
verified: { by: human:sunil, at: 2026-07-20T09:00:00Z }   # present only once a human has reviewed the page
stale_after: 2027-01-01T00:00:00Z                 # optional: page is stale on/after this instant
---
```

`type` is the only required key; everything else is recommended or optional. Every timestamp is ISO 8601 with an explicit UTC offset (`...Z`).

Controlled vocabulary for `type`:

- **concept** — an idea, mechanism, or process
- **entity** — a specific person, system, service, or component
- **decision** — a choice made and its rationale (distinct from an ADR — this is knowledge-base synthesis, not a project governance record)
- **reference** — durable facts, specs, API shapes
- **summary** — a digest of a source or a filed query answer

### `generated` (OKF §5.2)

`generated: { by, at }` records how the current content was produced.

- `by` — the actor, per OKF's convention: `wiki/<model-id>` for the ingest agent (e.g. `wiki/claude-sonnet-5`), `human:<id>` for a hand-written page.
- `at` — the content's last meaningful change. This is what the lint flow compares to decide which of two conflicting claims is newer. (Replaces the v0.1 `timestamp` field.)

### `sources` (OKF §5.1)

The `wiki/raw/` files a page was synthesized from — the page→source backlink that makes citations traceable and lets lint spot a page whose sources have all been removed. Each entry:

- `resource` — required. A path to the raw file, rooted at `wiki/` (`/raw/<file>`).
- `id` — a stable key. Required when the body cites the source (see below).
- `title` — human-readable label.
- `last_modified` — the raw file's mtime, ISO 8601. A recency signal, distinct from `generated.at`.

Per-claim attribution uses a markdown footnote whose label is a `sources[].id`:

```markdown
Login uses OAuth with PKCE for the SPA client.[^auth-notes]

[^auth-notes]: Auth design notes
```

The label is the join key into `sources` — keep it stable when the list is reordered.

### `status` (OKF §5.4)

`draft` (content the ingest agent judged incomplete or uncertain), `stable` (default — omit the key), or `deprecated` (superseded; kept for links and history, with a forward link to its replacement). Review state is *not* carried here — an unreviewed page is simply one with no `verified` key.

### `verified` and trust tiers (OKF §5.2–5.3)

A `{ by, at }` event (or a list of them) recording that a human or process has confirmed the page against its sources. Absent until that happens. Consumers derive a trust tier: no `verified` ⇒ **unverified**; `verified` by `process:`/agent actors only ⇒ **machine-confirmed**; `verified` by a `human:<id>` ⇒ **human-reviewed**. The query flow surfaces this tier; it is advisory, never a filter.

### `stale_after` (OKF §5.5)

Optional absolute instant. A page is stale when `now >= stale_after`. Use it on pages whose facts are inherently time-bound.

Not adopted from OKF v0.2: `Attested Computation` and its `runtime`/`executor`/`attester` fields (§10), and the usage-based credibility signals `author`/`usage_count`/`usage_window` (§5.1) — neither fits a prose project wiki built from local files.

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

Flat catalog: one entry per page, page-level only. Cheap to read in full on every run, however large the wiki gets — the section-level detail lives in each page's own Contents block, not here. Lives in `wiki/` itself (not `wiki/pages/`) — it's an index over the pages, not one of them, same tier as `log.md` and `manifest.json`. Named `WIKI_INDEX.md`, not `index.md`, to avoid colliding with a project's own root `INDEX.md`. OKF (§8) reserves `index.md` for a per-directory listing; this is the skill's equivalent, and an OKF consumer that wants a conformant `wiki/pages/index.md` can synthesize one from this file.

```markdown
# Wiki Index
> Run /wiki ingest to keep this current. Run /wiki query to ask questions against the wiki.

## <Category>

- [Page Title](pages/topic-file.md) — type: concept · tags: auth, security — one-line page summary
```

Categories are loose groupings the agent maintains (e.g. by `type` or by subject area) — not a fixed enum.

## Cross-linking

Page-to-page links in a body use a path rooted at `wiki/` — `[customers](/pages/customers.md)` — which stays valid if a page is renamed within `wiki/pages/`. Footnote citations to sources are keyed to `sources[].id`, not written as inline links (see `sources` above). A link to a page that doesn't exist yet is not an error — it marks not-yet-written knowledge, and the lint flow reads it as a hint, not a fault.

## log.md format

Append-only, newest first, following OKF's `log.md` shape (§9): `## YYYY-MM-DD` date headings, one bullet per change, a leading bold word for the kind.

```markdown
# Wiki Update Log

## 2026-07-19
* **Ingest** (Source Title): created [topic-a](/pages/topic-a.md); updated [topic-b](/pages/topic-b.md) — added section on X.
* **Flag**: [topic-a](/pages/topic-a.md) contradicts [topic-c](/pages/topic-c.md) on Y — left for /wiki lint.
```

Use the flow name (`Ingest`, `Add`, `Query`, `Lint`) as the leading bold word so entries stay greppable by kind.

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
