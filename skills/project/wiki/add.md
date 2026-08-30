# Wiki — add flow

Read [`common/SCHEMA.md`](common/SCHEMA.md) first for the `wiki/raw/`/`wiki/pages/` layout and conventions.

Ad-hoc info still becomes a `wiki/raw/` source, then flows through the normal ingest flow — one code path for every write into the wiki, so the manifest stays the single source of truth for what's been processed.

## Step 1 — Get the content

Use the info given at invocation, after the leading `add`. If nothing was given to add, ask what to file — this is a genuine blocker, not something to guess.

## Step 2 — Write it to wiki/raw/

Save it as a new file: `wiki/raw/adhoc-<YYYY-MM-DD>-<kebab-slug-of-topic>.md`, with a one-line header noting it's ad-hoc input, e.g.:

```markdown
<!-- ad-hoc input, added 2026-07-19 -->

<the content, verbatim or lightly cleaned up>
```

## Step 3 — Ingest it

Run the ingest flow from [`ingest.md`](ingest.md) (Steps 2 onward), scoped to this one new file. The resulting page(s) carry this `adhoc-*.md` file as their `sources` entry like any other raw input. If the user dictated the content and confirms the synthesized page reads correctly, record a `verified: { by: human:<id>, at: <now> }` line on it per SCHEMA.md.

## Completion criterion

The new `wiki/raw/adhoc-*.md` file exists and is marked in the manifest per the ingest flow's completion criterion.
