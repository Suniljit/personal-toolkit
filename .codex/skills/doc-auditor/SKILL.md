---
name: doc-auditor
description: >
  Audit and update project documentation against the current session in Codex.
  Use when the user asks to "update the docs", "audit my docs", "sync the docs",
  "do I need an ADR?", "/doc-auditor", or otherwise reflect recent code changes,
  implementation work, or architectural decisions in project documentation.
---

# Doc Auditor

Audit existing docs against the current conversation, then create or update docs
and ADRs as needed. Preserve the approval gate: present the audit report and
wait for the user's confirmation before writing or editing files.

---

## Step 1: Find Project Root

```bash
dir=$(pwd); while [ "$dir" != "/" ]; do [ -f "$dir/INDEX.md" ] && echo "$dir" && break; dir=$(dirname "$dir"); done
```

The directory containing `INDEX.md` is `PROJECT_ROOT`. If not found, ask before
continuing. Do not infer a project root silently.

---

## Step 2: Read INDEX.md

Read `$PROJECT_ROOT/INDEX.md`. If absent, note it — you'll create it in Step 7.
Parse: doc titles/paths, ADR numbers/titles/statuses.

---

## Step 3: Scan Conversation Context

Extract:
- **Technical changes**: code, APIs, data models, configs, infra introduced or changed
- **Architectural decisions**: choices with trade-offs (library, DB, auth, deployment, API design) — ADR candidates
- **Referenced docs**: anything the user mentioned or pasted — may need updating

---

## Step 4: Present Audit Report and Stop

Before writing anything, present a Codex-friendly Markdown report with short
sections, relative paths in backticks, and `None` for empty sections:

```markdown
**Documentation Audit**

**Docs To Update**
- `path/to/doc.md` - reason

**Docs To Create**
- `path/to/new-doc.md` - suggested title and reason

**ADRs To Create**
- `ADR-NNN-title.md` - decision summary

**INDEX.md**
- Create `INDEX.md`
- Add entries for: `docs/example.md`, `docs/adr/ADR-NNN-title.md`

**No Action Needed**
- `path/to/current.md` - still current
```

Then ask exactly: `Does this look right? Confirm before I start writing.`

Stop here until the user confirms. Do not edit docs, ADRs, or `INDEX.md` before
confirmation.

---

## Step 5: ADR Format

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

## Step 6: Write / Update Files

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
Use plain ASCII characters so diagrams display consistently in Codex, terminals,
GitHub diffs, and text-only review surfaces.

```
+--------+   REST   +--------+   gRPC   +---------+
| Client | --------> | API GW | --------> | Service |
+--------+          +--------+           +----+----+
                                             |
                                             v
                                        +----+----+
                                        |   DB    |
                                        +---------+

User        Auth        API         DB
 |           |           |           |
 |--login()->|           |           |
 |           |--validate>|--query--->|
 |<-token----|<----------|<-result---|

[Input] --> [Validate] --> [Transform] --> [Persist]
                |
                +--> [Reject] --> [Log Error]
```

---

## Step 7: Update INDEX.md

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

After writing, report only what changed in a compact Codex-friendly summary:

```markdown
Updated:
- `docs/architecture.md`
- `INDEX.md`

Created:
- `docs/adr/ADR-003-use-redis-for-caching.md`
```

Mention any docs you intentionally left unchanged and any verification you ran.
