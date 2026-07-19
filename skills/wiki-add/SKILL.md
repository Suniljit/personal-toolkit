---
name: wiki-add
description: >
  Add ad-hoc information to a project's LLM wiki, outside the raw/ ingestion
  pipeline. Trigger on "/wiki-add", "add this to the wiki", "note this in the
  wiki", "update the wiki with...".
---

# Wiki Add

Read [`../wiki-common/SCHEMA.md`](../wiki-common/SCHEMA.md) first for the `raw/`/`wiki/` layout and conventions.

Ad-hoc info still becomes a `raw/` source, then flows through the normal ingest pipeline — one code path for every write into the wiki, so the manifest stays the single source of truth for what's been processed.

## Step 1 — Get the content

Use the info given at invocation. If the skill was invoked with nothing to add, ask what to file — this is a genuine blocker, not something to guess.

## Step 2 — Write it to raw/

Save it as a new file: `raw/adhoc-<YYYY-MM-DD>-<kebab-slug-of-topic>.md`, with a one-line header noting it's ad-hoc input, e.g.:

```markdown
<!-- ad-hoc input, added 2026-07-19 -->

<the content, verbatim or lightly cleaned up>
```

## Step 3 — Ingest it

Run the ingest steps from [`../wiki-ingest/SKILL.md`](../wiki-ingest/SKILL.md) (Steps 2 onward), scoped to this one new file.

## Completion criterion

The new `raw/adhoc-*.md` file exists and is marked in the manifest per wiki-ingest's completion criterion.
