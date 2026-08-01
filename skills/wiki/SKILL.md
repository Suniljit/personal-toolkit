---
name: wiki
description: >
  ingest | add | query | lint — first word picks the flow. Project LLM
  wiki: ingest source files, add ad-hoc notes, query with citations, or
  lint for contradictions.
disable-model-invocation: true
---

# Wiki

One skill, four flows, dispatched by the first word of what follows `/wiki`. All four share the layout and conventions in [`common/SCHEMA.md`](common/SCHEMA.md) — read it first, every run, regardless of flow.

## Step 1 — Pick the flow from the first word

| First word | Flow |
|---|---|
| `ingest` | [`ingest.md`](ingest.md) — process `wiki/raw/` into wiki pages |
| `add` | [`add.md`](add.md) — file ad-hoc info, then ingest it |
| `query` | [`query.md`](query.md) — answer a question with citations |
| `lint` | [`lint.md`](lint.md) — health-check for contradictions, orphans, stale claims |

No first word given, or it doesn't match any of the four: ask which flow, don't guess.

## Completion criterion

The matched flow's own completion criterion is met.
