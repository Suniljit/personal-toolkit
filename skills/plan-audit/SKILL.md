---
name: plan-audit
description: >
  Audit code against a feature plan to find discrepancies. Triggers on "audit against
  the plan", "check if code matches the plan", "did we implement the spec", "verify
  implementation against feature-plan", "plan-audit", or "/plan-audit". Given a
  feature plan Markdown file, reads it and inspects the codebase to surface what was
  implemented correctly, what's missing, and what diverged. Use this skill any time
  the user wants to verify their implementation against a feature plan or spec doc.
---

# Plan Audit

Compare a feature plan doc against the actual codebase and report every discrepancy
clearly: what the issue is, why it matters, and exactly what to fix.

---

## Step 1 — Gather inputs

You need two things:

1. **Feature plan file** — path to the Markdown plan (e.g. `_specs/feat-add-csv-export.md`)
   - If not provided, look for a `_specs/` directory and list candidates for the user to pick
2. **Scope** — which files or directories to audit
   - Default: infer from the plan's **Key Files** table
   - If the table is missing or incomplete, ask the user to confirm scope

Read the plan file in full before doing anything else.

---

## Step 2 — Extract audit targets from the plan

Parse the plan for every checkable claim. Build an internal checklist covering:

| Plan section | What to check |
|---|---|
| **What & Why** | The core capability exists and is reachable |
| **Decisions** | Each Choice/Constraint is reflected in the code |
| **Architecture** | Data flow and component relationships match the diagram |
| **Key Files** | Each listed file exists and the stated change is present |
| **Code Shape** | Interfaces, types, function signatures match the sketches |
| **Validation Rules** | Input constraints are enforced where described |
| **Logging** | Each listed log event exists at the right level with the right fields |
| **Implementation Plan** | Each phase's tasks appear to be done |
| **Out of Scope** | Nothing in scope-exclusions was accidentally implemented |

Skip sections that are absent from the plan — don't invent checks.

---

## Step 3 — Inspect the codebase

Read every file in the audit scope. For each audit target from Step 2:

- Locate the relevant code
- Confirm it matches the plan **or** record a discrepancy
- Note the exact file and line range for every finding

Do this silently — don't narrate the search. Surface only findings.

---

## Step 4 — Report findings

### Summary header

```
Plan Audit: <Feature Title>
Plan file: <path>
Files reviewed: <count>
─────────────────────────────
✅ Matches:     N
⚠️  Discrepancies: N
```

### Per-discrepancy format

For each issue, output a block like this — no prose padding:

---

**[D-N] Short title of the issue**

- **What:** One sentence describing the gap or mismatch.
- **Plan says:** Quote or paraphrase the exact plan requirement.
- **Code does:** What the code actually does (file + line).
- **Why it matters:** Impact — broken behaviour, incorrect output, missing safety check, etc.
- **Fix:** Concrete action. Name the function, field, or block to change and what it should become.

---

Rules:
- Each discrepancy is one `[D-N]` block — no grouping by category
- Severity order: missing required behaviour first, wrong behaviour second, cosmetic/logging last
- If a section from the plan has zero discrepancies, include it in a one-line summary at the end (see below)
- Never report a finding without a file + line reference

### Clean sections (at the end)

```
Sections with no discrepancies: Architecture, Validation Rules, Out of Scope
```

---

## Step 5 — Offer next steps

After the report:

> *"Found N discrepancy(s). Want me to fix any of these, or generate a checklist ticket for the team?"*

Wait for the user's instruction before touching any code.

---

## Guidelines

- **Read before judging.** Always read the full plan and the relevant code before forming any finding. Don't skim.
- **Be precise.** Every finding must name the exact file and line. Vague findings ("logging is incomplete") are not acceptable.
- **Don't gold-plate.** Only flag things the plan actually requires. If the plan doesn't mention something, it's not a discrepancy.
- **Distinguish missing vs wrong.** Missing = the thing isn't there at all. Wrong = it's there but diverges from the spec. Label clearly in the "What" field.
- **One fix per block.** If a single root cause produces multiple symptoms, report the root cause once with all symptoms noted under "Why it matters."
- **Don't fix anything.** This skill produces a report only. Code changes happen only if the user explicitly asks afterward.