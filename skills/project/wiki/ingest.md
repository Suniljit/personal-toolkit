# Wiki — ingest flow

Read [`common/SCHEMA.md`](common/SCHEMA.md) first — it defines the `wiki/raw/`/`wiki/pages/` layout, page frontmatter, `WIKI_INDEX.md`/`log.md` formats, and the two shared scripts. This is the only flow that writes wiki pages, `WIKI_INDEX.md`, and `log.md` directly; `add.md` and `query.md` both delegate here.

## Step 1 — Locate and scaffold

Find `wiki/` at the project root, and `wiki/raw/` and `wiki/pages/` inside it. If any of these is missing, create it, along with an empty `WIKI_INDEX.md`, a `log.md` seeded with its `# Wiki Update Log` heading, and `manifest.json` (`{}`). If `wiki/` isn't already in `.gitignore`, add it (or, if the project already tracks `wiki/`, add `wiki/raw/` and `wiki/manifest.json` instead — those two stay ignored regardless).

## Step 2 — Find what's new

```bash
python3 common/scripts/wiki_diff.py check --raw wiki/raw/ --manifest wiki/manifest.json
```

This is a pure hash comparison — no LLM judgment involved in deciding what's new. If `new` and `changed` are both empty, report "wiki is up to date" and stop. Note any `removed` files in the report (files the manifest tracked that no longer exist in `wiki/raw/`) — don't touch pages for them without asking, a source going missing doesn't mean its wiki content is wrong.

## Step 3 — Ingest each new/changed file

For every file in `new` + `changed`:

1. **Get text**: if the extension is already `.md`/`.txt`, read it directly. Otherwise convert it first, through `common/`'s venv:
   ```bash
   uv run --project common python scripts/wiki_convert.py <file>
   ```
   If this fails because the venv doesn't exist yet, tell the user to run the one-time setup in `common/README.md` (`uv venv .venv --python 3.13 && uv sync`) and stop — don't attempt to parse binary formats yourself.
2. **Extract and integrate**: read the converted text, decide which wiki pages it touches — creating new pages or updating existing ones. A single source often touches several pages (entity pages, concept pages, cross-references), not just one.
3. **Write pages** into `wiki/pages/`, using the frontmatter and Contents-block conventions in SCHEMA.md — the per-section outline with one-line gists lives at the top of the page itself, not in `WIKI_INDEX.md`. On any page you create or touch: set/update `generated` (`at` always; `by` = `wiki/<model-id>`), add this source to the page's `sources` list (rooted at `/raw/<file>`, with the raw file's mtime as `last_modified`), key footnote citations to `sources[].id` for specific claims, and refresh the Contents block. Set `status: draft` only if the content is genuinely incomplete or uncertain; otherwise omit `status`.
4. **Check for contradictions**: if new content conflicts with a claim already on an existing page, don't silently overwrite it — keep both, note the conflict in `log.md`, and leave resolution to the lint flow. You may mark a page whose claim is now in doubt `status: draft`, but never pick a winner here.
5. **Update `WIKI_INDEX.md`**: for every page created or updated, refresh its flat entry (title, type, tags, one-line summary) per SCHEMA.md's format — no section-level detail here, that's what keeps the index cheap to read in full as the wiki grows.
6. **Append to `log.md`**: one bullet per source file under today's `## YYYY-MM-DD` heading, leading bold word `**Ingest**`, listing pages created/updated and any contradictions flagged — per SCHEMA.md's log.md format.
7. **Mark it done**:
   ```bash
   python3 common/scripts/wiki_diff.py mark --raw wiki/raw/ --manifest wiki/manifest.json --file <relpath> --pages <comma-separated wiki/pages/ paths>
   ```
   Mark per-file, immediately after that file's pages are written — so a failure partway through the batch doesn't falsely mark unprocessed files as done.

## Completion criterion

Every file in Step 2's `new` + `changed` list is either marked in the manifest, or explicitly reported as skipped with a reason (e.g. missing `markitdown`). Report a summary: files ingested, pages created vs. updated, and any contradictions flagged for the lint flow.
