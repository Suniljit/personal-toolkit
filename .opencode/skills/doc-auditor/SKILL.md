---
name: doc-auditor
description: >
  Audit and update project documentation based on current conversation context.
  Trigger this skill when the user says things like "update the docs", "audit
  my documentation", "check what docs need updating", "sync the docs", "do I
  need an ADR for this?", or any variation of wanting documentation to reflect
  recent changes, decisions, or new features discussed in the session.
  Also trigger when the user invokes it directly (e.g. "/doc-auditor").
  The skill reads INDEX.md to understand the doc landscape, then compares it
  against what was discussed in the current session to identify gaps, stale
  docs, and decisions that warrant an ADR.
---

# Doc Auditor Skill

Audit existing documentation against the current conversation context, then
create or update docs and ADRs as needed.

---

## Step 1 — Find the Project Root

Run this to locate `INDEX.md` by walking up from the current directory:

```bash
dir=$(pwd); while [ "$dir" != "/" ]; do [ -f "$dir/INDEX.md" ] && echo "$dir" && break; dir=$(dirname "$dir"); done
```

The directory that contains `INDEX.md` is `PROJECT_ROOT`.

If nothing is found, ask the user where the project root is.

---

## Step 2 — Read INDEX.md

Read `$PROJECT_ROOT/INDEX.md`.

If it **does not exist**, note this and proceed to Step 4 — you will create it
at the end.

If it **exists**, parse it to build a map of:
- Every doc listed (title, relative path, one-line purpose if present)
- Any ADRs listed (number, title, status, path)

---

## Step 3 — Scan the Conversation Context

From the current session, extract:

### A. Technical changes / new features
Any code, architecture, APIs, data models, configs, or infrastructure that was
introduced or significantly changed.

### B. Architectural decisions
Choices made with meaningful trade-offs — library selection, database choice,
auth strategy, deployment approach, API design, data flow changes, etc.
These are ADR candidates.

### C. Existing doc references
Any doc the user mentioned, linked, or pasted. These may need updating.

---

## Step 4 — Assess What Needs Doing

Produce a structured audit report **in the conversation** before writing any
files. Format:

```
## Documentation Audit

### Docs to UPDATE
- [doc title](path) — reason

### Docs to CREATE
- Suggested title (path) — reason

### ADRs to CREATE
- ADR-NNN: <title> — summary of the decision captured

### INDEX.md
- [ ] Needs to be created   OR   [ ] Needs these entries added: ...

### No action needed
- [doc title](path) — still current
```

Ask the user: *"Does this look right? Any changes before I start writing?"*
Wait for confirmation (a simple "yes", "go ahead", or "looks good" is enough).

---

## Step 5 — Determine ADR Format

Check `$PROJECT_ROOT/docs/adr/` for existing ADRs.

**If ADRs exist:** Read one to extract the template structure. Mirror it exactly
(same headings, same metadata fields, same filename convention).

**If no ADRs exist:** Use the default template below and tell the user you're
introducing it:

```markdown
# ADR-NNN: <Title>

**Date:** YYYY-MM-DD  
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNN  
**Deciders:** <who made or approved this decision>

---

## Context

<What is the situation forcing a decision? What constraints exist?>

## Decision

<What was decided, stated clearly and directly.>

## Consequences

### Positive
- <benefit>

### Negative / Trade-offs
- <cost or risk>

### Neutral
- <things that change but aren't clearly good or bad>

---

## ASCII Diagram (if applicable)

<Use ASCII art to illustrate the architecture, data flow, or component
 relationship this decision affects. See diagram guidance below.>
```

---

## Step 6 — Write / Update Files

Execute the confirmed plan. For each file:

### Updating an existing doc
1. Read the current file fully
2. Identify the stale sections
3. Rewrite only those sections — preserve the rest verbatim
4. Add or update any ASCII diagrams that illustrate the changed area

### Creating a new doc
Use this structure as the default, adapting to the doc type:

```markdown
# <Title>

> One-sentence description of what this document covers.

---

## Overview

<High-level summary — what, why, who this is for>

## <Main Section(s)>

<Content>

## ASCII Diagram

<Diagram illustrating the key concept, component, or flow>

## Related
- [Link to related doc](path)
- ADR-NNN: <relevant decision>
```

### Creating an ADR
- Number sequentially: find the highest existing ADR number and increment by 1
- Filename: `ADR-NNN-kebab-case-title.md` (or match existing convention)
- Path: `$PROJECT_ROOT/docs/adr/`
- Status: `Accepted` (since the decision was already made in the session)

---

## Step 7 — Update INDEX.md

After all files are written, update (or create) `$PROJECT_ROOT/INDEX.md`.

### If creating INDEX.md from scratch, use this structure:

```markdown
# Project Documentation Index

> Auto-maintained index of all technical documentation for this project.
> Run the `doc-auditor` skill to keep this up to date.

---

## Architecture & Design
| Document | Description |
|----------|-------------|
| [Title](path) | one-line description |

## Architecture Decision Records (ADRs)
| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](docs/adr/ADR-001-*.md) | Title | Accepted | YYYY-MM-DD |

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

### If updating an existing INDEX.md:
- Add new rows to the correct table sections
- Do not reformat sections that were not touched
- If a new section category is needed, add it

---

## ASCII Diagram Guidance

Use ASCII diagrams liberally — they render everywhere, never break, and are
version-controllable. Prefer them over vague prose for:

- Component relationships
- Data flows
- Request/response lifecycles
- Deployment topology
- State machines
- Sequence of operations

### Box-and-arrow style (components / architecture)
```
  ┌─────────────┐     REST      ┌─────────────┐
  │   Client    │ ────────────► │   API GW    │
  └─────────────┘               └──────┬──────┘
                                        │ gRPC
                                        ▼
                                ┌─────────────┐
                                │   Service   │
                                └──────┬──────┘
                                        │
                                        ▼
                                ┌─────────────┐
                                │    DB       │
                                └─────────────┘
```

### Sequence style (flows / lifecycles)
```
  User          Auth          API           DB
   │             │             │             │
   │──login()───►│             │             │
   │             │──validate──►│             │
   │             │             │──query─────►│
   │             │             │◄────result──│
   │◄──token─────│◄────────────│             │
```

### Simple flow (pipelines / state machines)
```
  [Input] ──► [Validate] ──► [Transform] ──► [Persist] ──► [Notify]
                  │
                  └──► [Reject] ──► [Log Error]
```

Use `─`, `│`, `┌`, `┐`, `└`, `┘`, `├`, `┤`, `┬`, `┴`, `┼` for clean boxes.
Use `►`, `◄`, `▲`, `▼` for directional arrows. Align columns for readability.

---

## Output Summary

After all writes, report to the user:

```
## Done ✓

Files written:
- Updated: docs/architecture.md
- Created: docs/adr/ADR-003-use-redis-for-caching.md
- Updated: INDEX.md

Next time: just invoke /doc-auditor after any significant change or decision.
```