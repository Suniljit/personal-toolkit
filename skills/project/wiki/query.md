# Wiki — query flow

Read [`common/SCHEMA.md`](common/SCHEMA.md) first for the `WIKI_INDEX.md`/page conventions.

## Step 1 — Locate the wiki

Find `wiki/WIKI_INDEX.md` at the project root. If it doesn't exist, tell the user there's no wiki yet and suggest `/wiki ingest`.

## Step 2 — Shortlist from the flat index

Read `WIKI_INDEX.md` in full (it's flat and cheap) to shortlist candidate pages by title/type/tags/summary. Don't open any page yet.

## Step 3 — Narrow with each candidate's Contents block

For each shortlisted page, read just its frontmatter + Contents block (the top of the file) to see which of its sections are actually relevant — per SCHEMA.md, that's where the section-level outline lives, not in the index. Drop candidates whose Contents block doesn't point anywhere useful.

## Step 4 — Read only what you need

For the remaining candidates, read the specific sections the Contents block pointed to — not the whole file, unless the question genuinely needs it.

## Step 5 — Synthesize with citations

Answer the question, citing the specific page (and section, where relevant) each claim came from. If pages disagree, say so rather than picking one silently — that's a job for the lint flow, not for this flow to paper over.

## Step 6 — Offer to file the answer

If the synthesis is a genuinely new page-worthy artifact (not just a quick lookup), ask: "File this as a new/updated wiki page?" Never file automatically. If the user says yes, hand the answer to [`add.md`](add.md) as the ad-hoc content to add.

## Completion criterion

The question is answered with citations, and the filing question has been asked (and acted on, or explicitly declined) before the turn ends.
