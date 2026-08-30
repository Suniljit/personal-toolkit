# Wiki — lint flow

Read [`common/SCHEMA.md`](common/SCHEMA.md) first for page frontmatter and `WIKI_INDEX.md`/`log.md` conventions.

## Step 1 — Locate the wiki

Find `wiki/` at the project root. If it's missing or `wiki/pages/` has no pages, report "nothing to lint" and stop.

## Step 2 — Read everything

Read `WIKI_INDEX.md` and every page under `wiki/pages/`.

## Step 3 — Detect issues

- **Orphaned pages**: no other page's body links to it. Its flat `WIKI_INDEX.md` entry doesn't count — every page gets exactly one of those regardless of how connected it is.
- **Contradictions**: two (or more) pages make incompatible factual claims about the same subject.
- **Stale claims**: a claim on one page is superseded by a newer claim elsewhere (compare `generated.at` frontmatter), or a page has passed its own `stale_after` instant.
- **Sourceless pages**: every entry in a page's `sources` names a `wiki/raw/` file that no longer exists. Report only — a removed source doesn't make the page wrong.

## Step 4 — Auto-fix the unambiguous cases

- **Orphan with an obvious topical link**: add a cross-link from the most relevant existing page (and from `WIKI_INDEX.md`'s category listing if it's missing there too).
- **Orphan with no clear relation to anything**: don't invent a link — add a visible `> [!orphan]` note at the top of the page instead, and report it.
- **Stale claim with exactly one unambiguous newer replacement**: update the old page's claim, keep the superseded text as a brief note (don't delete history), set the superseded page's `status: deprecated` with a forward link to its replacement, and bump nothing that isn't actually stale.
- **Page past its `stale_after` with no replacement**: don't guess a fix — add a visible `> [!stale]` note at the top of the page and report it.
- **Contradictions**: never auto-resolve — always report both sides with their sources. Picking which claim is correct is a human judgment call.

Append a `log.md` bullet under today's `## YYYY-MM-DD` heading with leading bold word `**Lint**` for every auto-fix made, and for the run overall.

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
- Sourceless page: <page> — all wiki/raw/ sources removed
```

## Completion criterion

Every page has been scanned for all issue types in Step 3; every auto-fixable issue is fixed and logged; every remaining issue is listed in the report.
