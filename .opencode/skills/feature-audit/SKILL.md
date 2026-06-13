---
name: feature-audit
description: >
  Audit a codebase against a feature brief (from the feature-brief skill) to check whether
  implementation has diverged from requirements. Triggers on "audit the codebase against
  the brief", "have we drifted from the spec", "check if the code matches the feature brief",
  "codebase audit", "does the implementation match requirements", or requests to verify
  consistency between a `_feature_briefs/*.md` doc and the actual code. Checks both
  directions: requirements not yet implemented, and code/behavior not covered by the brief
  (scope creep). Produces an inline chat summary, not a saved report. Can run against the
  whole repo or a user-specified subset of files/directories.
---

# Codebase Audit

Compare a feature brief's requirements against the current state of the code, and report
divergence in both directions: missing implementation, and undocumented additions.

This is a read-only investigation. Don't modify code or the brief — just report findings.

---

## Step 1 — Locate the brief

- If the user points to a specific brief, use it.
- Otherwise look in `_feature_briefs/` for a matching file (by name or recent activity).
- If multiple briefs could be relevant, ask which one (or whether to audit against all of
  them — usually one at a time is more useful).
- Read the full brief, paying particular attention to:
  - Section 7 (Functional Requirements) and Section 8 (Non-Functional Requirements) — these
    are the concrete, checkable claims.
  - Section 6 (User Stories) — useful for tracing end-to-end flows.
  - Section 5 (Architecture) — the expected shape of the system.
  - Section 11 (Out of Scope) — anything here that *is* implemented is worth flagging too,
    since it suggests scope drift even if it's not "wrong."
  - Section 10 (Open Questions) — don't penalize the code for not resolving these, but note
    if the code has silently picked an answer.

## Step 2 — Determine scope

- If the user named files/directories, audit those.
- Otherwise, explore the repo to find the code relevant to this brief. Use the brief's title,
  architecture section, and user stories as search terms (grep, file names, directory
  structure) to find the right area — don't read the entire repo indiscriminately.
- If the brief describes multiple components/services, make sure you've found code for each
  one before concluding something is missing.

## Step 3 — Check brief → code (requirements coverage)

For each FR/NFR and user story, determine whether the code addresses it. Classify each as:

- **Implemented** — found code that satisfies this requirement.
- **Partial** — some implementation exists but doesn't fully cover the requirement (e.g.
  happy path only, missing an edge case mentioned in the FR).
- **Missing** — no evidence the requirement has been implemented.
- **Unclear** — couldn't determine from the code alone; worth a note rather than a verdict.

Be concrete: cite file paths and what you found (or didn't find), not just a verdict.

## Step 4 — Check code → brief (scope creep / undocumented behavior)

Look for things the code does that aren't mentioned anywhere in the brief:

- New features, endpoints, flags, or config options not in the FRs/user stories.
- Architectural components present in code but absent from the Section 5 diagram.
- Things explicitly listed in Section 11 (Out of Scope) that are nonetheless implemented.

The goal isn't to flag every small implementation detail — focus on things substantial
enough that a reader of the brief would be surprised to learn they exist. Use judgment:
a helper function isn't scope creep; a whole new API endpoint or user-facing feature is.

## Step 5 — Report inline

Present findings as a chat summary (don't save a file). Structure:

```
## Audit: <brief title> vs. code

### Requirements coverage
- ✅ FR-1: <short description> — <file:line or brief note>
- ⚠️ FR-3: Partial — <what's missing>
- ❌ NFR-2: Missing — <what was expected, what was searched>
- ❓ FR-5: Unclear — <why>

### Possible scope creep
- <thing found in code but not in brief> — <file path> — <why it's notable>

### Notes
- <anything about Open Questions the code has implicitly resolved>
- <overall sense of drift: minor/moderate/significant, and why>
```

Keep it tight — use the minimum formatting needed for clarity, and don't pad with
restatements of the brief. If everything checks out, say so plainly rather than padding
the report to look thorough.

## Step 6 — Offer next steps

Don't take action automatically, but offer relevant follow-ups based on findings, e.g.:
- Updating the brief's Out of Scope / requirements sections to reflect reality
- Drafting tickets (via `ticket-generator`) for missing requirements
- Planning a fix (via `feature-plan`) for partial implementations

---

## Guidelines

- **Read-only.** Never edit code or the brief as part of this skill.
- **Cite specifics.** "Missing" should mean "I looked in X, Y, Z and didn't find it," not a
  guess.
- **Don't over-flag.** Minor naming differences or implementation details that don't change
  behavior aren't divergence.
- **Calibrate to brief age.** A brief marked Draft from yesterday will naturally have more
  gaps than one that's been stable for months — note this if relevant rather than treating
  all gaps as equally concerning.