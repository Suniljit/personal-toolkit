---
name: feature-brief
description: >
  Write a high-level requirements brief (PRD-style) for a feature, feature set, or new project.
  Triggers on "feature-brief", "write a feature brief", "brief this", "plan this project",
  "help me plan X", "what are we building", or any description of scope larger than a single
  implementation task. Always interviews the user first, then saves a Markdown brief to the
  repo. The brief captures *what* and *why* at a high level (problem, goals, requirements,
  user stories) — it does NOT contain implementation details, file-level changes, or phased
  task breakdowns.
---

# Feature Brief

Interview the user thoroughly, then save a tight **backlog-ready Markdown brief** to the repo.

This is a requirements document, not an implementation plan: capture *what* and *why* at a
high level (problem, goals, requirements, user stories, high-level architecture). No file-level
changes, phase breakdowns, or code shapes.

---

## Step 1 — Gather inputs

You need one thing before starting:

**Feature/project description** — what are we building, at a high level?
- If a ticket/doc path was given, read it
- If no description exists, ask: *"What are you trying to build, and what problem does it solve?"*

Don't ask about save location yet — that's resolved in Step 5.

---

## Step 2 — Grill the user

Interview the user relentlessly about every aspect of the brief until we reach a shared
understanding. Walk down each branch of the requirements tree, resolving open questions
one-by-one. For each question, provide your recommended answer.

Rules:
- Use the question tool for every question. One question (or tight cluster) at a time.
- Lead with your **recommended answer** with brief rationale — don't just ask open questions.
- If the codebase or existing docs can answer a question, **explore them** instead of asking.
- Stay at the requirements level — don't drift into implementation details (file names,
  function signatures, phasing).
- **Track every decision**, especially scope cuts and deferred items (needed for Out of Scope).

Areas to cover (adapt depth to project size):
- Problem statement and motivation
- Target users / personas
- Goals and success metrics
- Core user stories / use cases
- Functional requirements
- Non-functional requirements (performance, security, scalability, compliance)
- Key architectural components and data flow (high-level only)
- Major design decisions and tradeoffs
- Dependencies, constraints, prior art
- Scope boundaries — what's explicitly out

When you feel the brief is fully resolved, resolve the save location before confirming:
- Look for an existing `_feature_briefs/` directory
- If found, use it
- If not found, propose `_feature_briefs/`

Then confirm with the user:
> *"I think we have enough to write the brief. I'll save it to `<path>` — ready to go?"*

Wait for explicit confirmation.

---

## Step 3 — Generate the brief

Synthesize the conversation (and any source docs) into the template below.

**Brevity principle:** Every section should be as short as possible while still being useful.
Prefer bullet points over prose. This is a brief, not a spec — depth comes later in
`feature-plan` documents for each sub-feature.

```markdown
# [Feature / Project Title]

> **Date:** YYYY-MM-DD
> **Status:** Draft

---

## 1. Overview

One paragraph. What is this, why does it exist, what problem does it solve?

---

## 2. Goals & Non-Goals

**Goals:**
- ...

**Non-Goals:**
- ...

---

## 3. Background & Context

What led to this? Relevant constraints, prior art, dependencies, stakeholders.

---

## 4. Success Metrics

How will we know this worked? Concrete, measurable where possible.

- Metric: ... — Target: ... — How measured: ...

---

## 5. Architecture

ASCII diagram showing key components, data flow, and where state lives. High-level only —
not file-level detail.

```
[Client] ──► [API Gateway] ──► [Service A]
                                    │
                              [Service B] ──► [DB]
```

---

## 6. User Stories

| As a        | I want               | So that                 |
|-------------|----------------------|-------------------------|
| [user type] | [goal or action]     | [benefit or outcome]    |

---

## 7. Functional Requirements

- FR-1: ...

---

## 8. Non-Functional Requirements

- NFR-1: Performance: ...
- NFR-2: Security: ...
- NFR-3: Scalability: ...

---

## 9. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| ...      | ...    | ...       |

---

## 10. Open Questions

Unresolved items that need a decision before (or during) implementation planning.

- ...

---

## 11. Out of Scope

Things explicitly not part of this brief.

- ...

---

## 12. References

Links, docs, tickets, prior discussions.
```

---

## Step 4 — Save the file

Derive a kebab-case name from the project/feature title (max ~50 chars).

Save to the directory confirmed in Step 2 — typically `_feature_briefs/<kebab-case-name>.md`.
Create the directory if needed.

Confirm:
> *"Saved to `_feature_briefs/<name>.md`."*

---

## Guidelines

- **Requirements-level only.** No file-level changes, phase breakdowns, or code shapes.
- **Replace every `...` with real content** — no placeholders.
- **Architecture diagram is mandatory**; keep it high-level (components/services, not files).
- **Success Metrics must be concrete** — vague goals like "improve UX" need a measurable proxy.
- **Design decisions must capture tradeoffs discussed**, not just choices made.
- **Out of Scope ≠ Future Work** — it means "not in this brief", full stop.
- **Open Questions ≠ Out of Scope** — open questions are things we *do* need to resolve, just
  not yet.
- Use today's date.
- **Don't write code.** Output is a brief doc only.