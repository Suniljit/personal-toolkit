---
name: doc-auditor
description: >
  Audit and update project documentation against the current session.
  Trigger on: "update the docs", "audit my docs", "sync the docs",
  "do I need an ADR?", or any request to reflect recent changes/decisions
  in documentation. Also triggers on "/doc-auditor".
---

# Doc Auditor Skill

Audit existing docs against the current conversation, then create or update
docs and ADRs as needed.

---

## Step 1 — Find Project Root

```bash
dir=$(pwd); while [ "$dir" != "/" ]; do [ -f "$dir/INDEX.md" ] && echo "$dir" && break; dir=$(dirname "$dir"); done
```

The directory containing `INDEX.md` is `PROJECT_ROOT`. If not found, ask.

---

## Step 2 — Read INDEX.md

Read `$PROJECT_ROOT/INDEX.md`. If absent, note it — you'll create it in Step 7.
Parse: doc titles/paths, ADR numbers/titles/statuses.

---

## Step 3 — Scan Conversation Context

Extract:
- **Technical changes**: code, APIs, data models, configs, infra introduced or changed
- **Architectural decisions**: choices with trade-offs (library, DB, auth, deployment, API design) — ADR candidates
- **Referenced docs**: anything the user mentioned or pasted — may need updating

---

## Step 4 — Audit Report

Present this in-conversation before writing anything:

```
## Documentation Audit

### Docs to UPDATE
- [title](path) — reason

### Docs to CREATE
- Suggested title (path) — reason

### ADRs to CREATE
- ADR-NNN: <title> — decision summary

### INDEX.md
- [ ] Needs to be created  /  [ ] Needs entries: ...

### No action needed
- [title](path) — still current
```

Does this look right? Confirm before I start writing.

---

## Step 5 — ADR Format

Check `$PROJECT_ROOT/docs/adr/` for existing ADRs.
- **ADRs exist**: read one, mirror its structure and filename convention exactly.
- **No ADRs**: use the template below; tell the user you're introducing it.

```markdown
# ADR-NNN: <Title>

**Date:** YYYY-MM-DD  
**Status:** Accepted  
**Deciders:** <who>

## Context
<Situation and constraints forcing a decision>

## Decision
<What was decided>

## Consequences
### Positive
- <benefit>
### Negative / Trade-offs
- <cost or risk>

## ASCII Diagram (if applicable)
<Architecture or flow diagram for this decision>
```

Number sequentially (highest existing + 1). Filename: `ADR-NNN-kebab-title.md`.

---

## Step 6 — Write / Update Files

**Updating**: Read the file, rewrite only stale sections, preserve the rest verbatim.

**Creating a doc**:
```markdown
# <Title>
> One-sentence description.

## Overview
## <Main Sections>
## ASCII Diagram
## Related
```

**Creating an ADR**: use template from Step 5, status `Accepted`, path `$PROJECT_ROOT/docs/adr/`.

---

## ASCII Diagrams

Use liberally for component relationships, data flows, request lifecycles,
deployment topology, state machines. They render everywhere and diff cleanly.

```
┌──────────┐   REST   ┌──────────┐   gRPC   ┌──────────┐
│  Client  │ ────────►│  API GW  │ ────────►│ Service  │
└──────────┘          └──────────┘          └────┬─────┘
                                                  ▼
                                           ┌──────────┐
                                           │    DB    │
                                           └──────────┘

User        Auth        API         DB
 │           │           │           │
 │─login()──►│           │           │
 │           │─validate─►│─query────►│
 │◄─token────│◄──────────│◄─result───│

[Input] ──► [Validate] ──► [Transform] ──► [Persist]
                │
                └──► [Reject] ──► [Log Error]
```

---

## Step 7 — Update INDEX.md

Add new entries to the correct sections. If creating from scratch:

```markdown
# Project Documentation Index
> Run `/doc-auditor` to keep this current.

## Architecture & Design
| Document | Description |
|----------|-------------|

## Architecture Decision Records (ADRs)
| ADR | Title | Status | Date |
|-----|-------|--------|------|

## API & Interfaces
| Document | Description |
|----------|-------------|

## Operations & Runbooks
| Document | Description |
|----------|-------------|

## Onboarding & Guides
| Document | Description |
|----------|-------------|
```

---

## Done

Report files written:
```
Updated: docs/architecture.md
Created: docs/adr/ADR-003-use-redis-for-caching.md
Updated: INDEX.md
```