# Wiki — lint flow

Read [`common/SCHEMA.md`](common/SCHEMA.md) first for page frontmatter and `index.md`/`log.md` conventions.

## Step 1 — Locate the wiki

Find `wiki/` at the project root. If it's missing or has no pages, report "nothing to lint" and stop.

## Step 2 — Read everything

Read `index.md` and every page under `wiki/`, excluding `wiki/raw/` (ingestion input, not a wiki page) and `wiki/manifest.json`.

## Step 3 — Detect issues

- **Orphaned pages**: no other page's body links to it. Its flat `index.md` entry doesn't count — every page gets exactly one of those regardless of how connected it is.
- **Contradictions**: two (or more) pages make incompatible factual claims about the same subject.
- **Stale claims**: a claim on one page is superseded by a newer claim elsewhere (compare `timestamp` frontmatter).

## Step 4 — Auto-fix the unambiguous cases

- **Orphan with an obvious topical link**: add a cross-link from the most relevant existing page (and from `index.md`'s category listing if it's missing there too).
- **Orphan with no clear relation to anything**: don't invent a link — add a visible `> [!orphan]` note at the top of the page instead, and report it.
- **Stale claim with exactly one unambiguous newer replacement**: update the old page's claim, keep the superseded text as a brief "superseded" note (don't delete history), and bump nothing that isn't actually stale.
- **Contradictions**: never auto-resolve — always report both sides with their sources. Picking which claim is correct is a human judgment call.

Append a `log.md` entry tagged `lint` for every auto-fix made, and for the run overall.

## Step 5 — Report

Present, in conversation:

```
## Wiki Lint

### Auto-fixed
- <page> — <what changed>

### Needs your call
- Contradiction: <page A> vs <page B> on <subject>
- Orphan, no clear relation: <page>
- Ambiguous stale claim: <page> — multiple candidate replacements
```

## Completion criterion

Every page has been scanned for all three issue types; every auto-fixable issue is fixed and logged; every remaining issue is listed in the report.
