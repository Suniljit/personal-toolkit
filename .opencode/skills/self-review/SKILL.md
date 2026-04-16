---
name: self-review
description: >
  Review your own code against a feature plan before creating a PR. Triggers on phrases like
  "self-review", "review my code before PR", "check my implementation", "pre-PR review",
  "review against the plan", "did I implement everything", or "check if I missed anything".
  Resolves the feature plan doc (and optionally a ticket + feature brief), diffs the current
  branch, cross-checks implementation against the plan, and flags gaps or low-confidence areas
  for the user to manually verify before opening a PR.
---

# Self-Review Skill

Pre-PR sanity check: verify your implementation against the plan before anyone else sees it.

---

## Step 1 — Resolve inputs

You need three things. Collect any that are missing in a single message — don't proceed until you have all of them.

**1. Plan doc** (required)  
Ask: *"Where's the feature plan doc? (e.g. `_features/my-feature/plans/feat-my-feature.md`)"*

**2. Ticket + feature brief** (optional)  
If the user has them, ask for their paths. If not, proceed without — the plan doc is the source of truth.


---

## Step 2 — Read the plan

Read the plan doc in full. Extract and hold in memory:

- **Summary** — what the feature is supposed to do
- **Design decisions** — key choices and their rationale
- **Key files** — files the plan says should be touched or created
- **Implementation phases** — every checklist item across all phases
- **Edge cases & error handling** — cases that should be handled
- **Out of scope** — so you don't flag missing things that were intentionally excluded
- **Testing requirements** — what tests are expected

If a ticket or feature brief was provided, read those too. Note any requirements stated there that aren't reflected in the plan — these are additional acceptance criteria.

---

## Step 3 — Explore the relevant code

Don't use git diff. Read the actual files — diffs miss context, and files that should exist but were never created won't appear in a diff at all.

**Start from the Key Files list in the plan.** For each file listed:
- If it's supposed to be new, check whether it exists
- If it's supposed to be modified, read its full current content

**Then follow the code.** As you read, trace imports, function calls, and references to discover adjacent files that are relevant to the feature — even if the plan didn't list them explicitly. Read those too.

**Check the project structure** to catch anything the plan expected that's missing:
```bash
# Get an overview of relevant directories
ls -R <relevant_dirs>
```

Read as many files as needed to build a complete picture of what's been implemented. Don't stop at the plan's file list if the code leads you elsewhere.

---

## Step 4 — Cross-check and deliver the review

Work through the plan systematically. For each section of the plan, check what the diff does or doesn't do.

Structure your response as follows:

---

### ✅ Implementation Checklist

Go through every phase and task from the plan's implementation checklist. Mark each item:

- ✅ **Done** — clearly implemented in the diff
- ⚠️ **Partial** — something is there but it looks incomplete or inconsistent with the plan
- ❌ **Missing** — no evidence of this in the diff
- 🔍 **Needs manual check** — code exists but correctness can't be verified from the diff alone (e.g. business logic, config values, subtle behavior)

If the plan didn't have a detailed checklist, derive expected tasks from the summary + architecture section and check against those.

---

### 📁 File Coverage

Cross-check the **Key Files** table from the plan against what actually exists on disk.

| File | Expected | Status |
|---|---|---|
| `path/to/file.ts` | Add new handler | ✅ Exists, implemented |
| `path/to/other.ts` | New file | ❌ Does not exist |

Flag:
- Files the plan expected to exist or be changed that are missing or untouched
- Files you found while exploring that the plan didn't mention — note these, they may be fine or may indicate scope creep

---

### 🔍 Design Decision Compliance

For each decision in the plan's **Design Decisions** table, check whether the implementation follows it.

Flag deviations with their severity:
- 🔴 **Deviated** — implementation clearly contradicts the decision
- 🟡 **Unclear** — can't tell from the diff whether this was followed
- ✅ **Followed** — implementation matches the decision

---

### ⚠️ Edge Cases & Error Handling

For each edge case listed in the plan, look for evidence it's handled.

- ✅ Handled — visible in diff
- ❌ Not handled — no evidence
- 🔍 Can't tell — logic exists but correctness is unclear

---

### 🧪 Test Coverage

Compare expected tests (from the plan's Testing section) against what's actually in the diff.

- Are happy-path tests present?
- Are edge case tests present (one per case)?
- Are bad-input tests present?
- Are integration boundaries tested?

Flag gaps explicitly.

---

### 🚩 Manual Review Required

Consolidate everything flagged as ⚠️, ❌, or 🔍 into a single prioritised list the user needs to act on before opening the PR:

**High priority (should fix before PR):**
1. [specific item] — [why it matters]

**Worth checking (low confidence):**
1. [specific item] — [what to verify]

**Minor / optional:**
1. [specific item]

If nothing needs attention: say "Everything in the plan looks accounted for — looks ready for PR." Don't invent problems.

---

### ❓ Questions Before You Open the PR

1–3 questions worth confirming — things that look ambiguous, underdocumented, or potentially risky from the diff.

---

## Tone & style

- Be direct. Quote filenames and line numbers when calling out issues.
- Don't pad. If a section is clean, say so briefly and move on.
- The goal is to find real gaps — not to nitpick style or invent concerns.
- If something can't be verified from the diff alone, say so explicitly — don't guess.