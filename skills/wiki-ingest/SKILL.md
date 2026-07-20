---
name: wiki-ingest
description: >
  Ingest new or changed files from a project's wiki/raw/ folder into its LLM wiki,
  synthesizing markdown pages and updating the index and log. Trigger on
  "/wiki-ingest", "ingest raw sources", "update the wiki from raw", "process
  new wiki sources".
---

# Wiki Ingest

Read [`../wiki-common/SCHEMA.md`](../wiki-common/SCHEMA.md) first — it defines the `wiki/raw/`/`wiki/` layout, page frontmatter, `index.md`/`log.md` formats, and the two shared scripts. This skill is the only one that writes wiki pages, `index.md`, and `log.md` directly; `wiki-add` and `wiki-query` both delegate here.

## Step 1 — Locate and scaffold

Find `wiki/` at the project root, and `wiki/raw/` inside it. If `wiki/` or `wiki/raw/` is missing, create it, along with an empty `index.md`, `log.md`, and `manifest.json` (`{}`). If `wiki/` isn't already in `.gitignore`, add it (or, if the project already tracks `wiki/`, add `wiki/raw/` and `wiki/manifest.json` instead — those two stay ignored regardless).

## Step 2 — Find what's new

```bash
python3 <path-to-wiki-common>/scripts/wiki_diff.py check --raw wiki/raw/ --manifest wiki/manifest.json
```

This is a pure hash comparison — no LLM judgment involved in deciding what's new. If `new` and `changed` are both empty, report "wiki is up to date" and stop. Note any `removed` files in the report (files the manifest tracked that no longer exist in `wiki/raw/`) — don't touch pages for them without asking, a source going missing doesn't mean its wiki content is wrong.

## Step 3 — Ingest each new/changed file

For every file in `new` + `changed`:

1. **Get text**: if the extension is already `.md`/`.txt`, read it directly. Otherwise convert it first, through `wiki-common`'s own venv:
   ```bash
   uv run --project <path-to-wiki-common> python scripts/wiki_convert.py <file>
   ```
   If this fails because the venv doesn't exist yet, tell the user to run the one-time setup in `wiki-common/README.md` (`uv venv .venv --python 3.13 && uv sync`) and stop — don't attempt to parse binary formats yourself.
2. **Extract and integrate**: read the converted text, decide which wiki pages it touches — creating new pages or updating existing ones. A single source often touches several pages (entity pages, concept pages, cross-references), not just one.
3. **Write pages** using the frontmatter and Contents-block conventions in SCHEMA.md — the per-section outline with one-line gists lives at the top of the page itself, not in `index.md`. Update `timestamp` and the Contents block on any page you touch.
4. **Check for contradictions**: if new content conflicts with a claim already on an existing page, don't silently overwrite it — keep both, note the conflict in `log.md`, and leave resolution to `/wiki-lint`.
5. **Update `index.md`**: for every page created or updated, refresh its flat entry (title, type, tags, one-line summary) per SCHEMA.md's format — no section-level detail here, that's what keeps the index cheap to read in full as the wiki grows.
6. **Append to `log.md`**: one entry per source file, tagged `ingest`, listing pages created/updated and any contradictions flagged.
7. **Mark it done**:
   ```bash
   python3 <path-to-wiki-common>/scripts/wiki_diff.py mark --raw wiki/raw/ --manifest wiki/manifest.json --file <relpath> --pages <comma-separated wiki page paths>
   ```
   Mark per-file, immediately after that file's pages are written — so a failure partway through the batch doesn't falsely mark unprocessed files as done.

## Completion criterion

Every file in Step 2's `new` + `changed` list is either marked in the manifest, or explicitly reported as skipped with a reason (e.g. missing `markitdown`). Report a summary: files ingested, pages created vs. updated, and any contradictions flagged for `/wiki-lint`.
