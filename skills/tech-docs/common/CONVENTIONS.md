# Tech Docs Conventions

Shared conventions for all seven `tech-docs` flows. Every flow reads this file before touching a project's docs — it's the single source of truth for layout, format, and interview mechanics. Don't restate these conventions inside the individual flow files; link back here.

Each flow's own document template lives in `templates/<flow>.md`, read at Step 3 (Generate the doc) — not before, since it's only needed once the interview is done.

## File layout

All seven docs live together in `docs/design/`, flat:

```
docs/
  design/
    prd.md
    app-flow.md
    design-brief.md
    tdd.md
    data-schema.md
    api-contracts.md
    nfr.md
    <doc-slug>/            <- overflow files, see Progressive disclosure
  adr/                     <- owned by domain-modeling, linked from tdd.md
INDEX.md                   <- project root — NOT docs/. Tracks every doc, design included.
```

Naming it `design/` groups the suite as one unit distinct from any other material already under `docs/` (runbooks, guides, etc.), while keeping `INDEX.md` at the project root as the single place anything — human or agent — looks first.

## Frontmatter

Every generated doc opens with:

```yaml
---
doc_type: prd
status: draft
depends_on: []
last_updated: YYYY-MM-DD
---
```

`doc_type` is one of `prd`, `app-flow`, `design-brief`, `tdd`, `data-schema`, `api-contracts`, `nfr`. `depends_on` lists the `docs/design/*.md` paths this doc was written against, so it's clear what to reread if an upstream doc changes. `status` is `draft` until the user says it's final.

This is what makes the suite searchable without reading every file end to end: `grep doc_type docs/design/*.md` alone answers "which doc is which" and "what feeds what" — an agent orients from the frontmatter, not by opening seven files.

## Traceability IDs

Requirements carry **stable IDs**, so downstream docs cite a requirement rather than a whole document. Two docs mint IDs; the rest reference them.

| Prefix | Minted in | Covers |
|---|---|---|
| `FR-01` | `prd.md` | A must-have feature |
| `US-01` | `prd.md` | A user story under a feature |
| `NFR-01` | `nfr.md` | A non-functional requirement |

Every downstream item — screen, table, endpoint, component, layout — carries an **Implements** field naming the IDs it serves (comma-separated, or `—` for genuinely cross-cutting infrastructure). That chain is what answers "what breaks if `FR-03` changes?" with a `grep FR-03 docs/design/` instead of a full read of seven files.

IDs are permanent: assign the next unused number, never renumber, and never reuse a retired one. When a requirement is dropped, keep its row and mark it `withdrawn` rather than deleting it — downstream docs and commits may already cite it.

## Diagrams

Every diagram is a **Mermaid** fenced block (` ```mermaid `) — it renders in GitHub, GitLab, and most editors, and diffs line by line in review. Pick the type by what's being shown:

| Showing | Type |
|---|---|
| Architecture, journeys, pipelines | `flowchart` (`TD` or `LR`) |
| Entities and cardinality | `erDiagram` |
| Cross-service or multi-actor exchanges | `sequenceDiagram` |
| A screen's or record's states | `stateDiagram-v2` |

Keep node labels short and the direction consistent within a doc.

## Progressive disclosure — the overflow rule

A doc stays a **router**: a summary table or list of every item (screen, table, endpoint, component), one line each, plus whatever cross-cutting material — diagrams, flows, principles — every reader needs regardless of which item they care about.

Split an item out to `docs/design/<doc-slug>/<item-slug>.md` the moment either is true:
- the doc would pass **~400 lines** with the item inlined
- there are more than **~8 items** carrying non-trivial detail

The summary row keeps a one-line gist and links to the file. A reader skimming the router never opens a file it doesn't need; one that does jumps straight there instead of scanning the whole doc.

Example (`api-contracts.md` past 8 endpoints):

| Endpoint | Method | Summary |
|---|---|---|
| [`/orders`](api-contracts/orders.md) | POST | Create an order |

Below the threshold, keep everything inline — don't split preemptively.

## INDEX.md

Root **`INDEX.md`** (project root, not `docs/`) tracks every doc in a **Design** table:

```markdown
## Design
| Document | Status | Depends on | Description |
|---|---|---|---|
| [PRD](docs/design/prd.md) | draft | — | Problem, scope, success metrics |
```

Create the table if it doesn't exist yet. Add or update only the row for the doc you just wrote — never touch other rows.

## Grilling

Every flow's interview step is a `/grilling` session, run with `/domain-modeling` alongside it — not just to keep terminology precise, but to record any ADR-worthy decision the moment it surfaces, in whichever flow it comes up in.

Each flow's Step 2 pairs its interview topics with a Considerations list — concrete checklists, frameworks, and common blind spots for that document type. Draw each recommended answer from that list before asking, not from a generic default; it's what turns "lead with your recommendation" into a specific, defensible one instead of a guess.

## Staying on scope

Each doc records only its own interview topics — never write in material that belongs to a different doc, even when the user volunteers it unprompted. When the user drifts (e.g. naming a database engine or a caching layer while grilling for the PRD), don't record it: name the doc it belongs to, park it there for later ("that's TDD territory — I'll bring it up when we get to `/tech-docs tdd`"), and re-ask the current question. Same treatment for detail that's on-topic but too granular for the doc's altitude (e.g. a specific SQL column type in the PRD's feature scope) — push back, and re-ask at the altitude the doc actually needs.

## Beyond the template

`templates/<flow>.md` is a floor, not a ceiling — the minimum sections a doc of that type carries, not the maximum. When Step 2's grilling surfaces a topic squarely in scope for this doc (per Staying on scope above) but with nowhere to go in the template, add a new section for it rather than forcing it into a section that doesn't fit, or dropping it. Match the template's altitude, heading style, and table-vs-prose conventions for whatever section you add.

## Related section

Every generated doc ends with:

```markdown
## Related
- [PRD](prd.md) — problem, scope, and personas this doc builds on
```

Docs live together in `docs/design/`, so links are bare filenames. Link only docs actually read (its `depends_on`) plus, once they exist, docs that depend on this one.
