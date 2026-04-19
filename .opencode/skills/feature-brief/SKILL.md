---
name: feature-brief
description: >
  Generate a structured feature brief with design summary and potential architecture for larger
  features, feature sets, or new projects. Use this skill when the user wants to plan a large
  feature, a collection of related features, or an entirely new project — especially when the
  intent is to break it down into issues, epics, or tasks to work on. Trigger on phrases like
  "write a feature brief", "brief this feature", "plan this project", "document this feature set",
  "generate a feature brief", "help me plan X", or whenever the user describes something at a
  scope bigger than a single implementation task. Output is a Markdown file saved to the repo.
---

# Feature Brief Generator

Synthesize a conversation or feature description into a structured Markdown brief — a combined
planning and architecture document. The primary output is **a backlog-ready artifact**: someone
reading it should be able to generate epics and issues directly from it.

---

## Step 1: Determine save location

Save to `_features/<feature-name>/feature-brief.md` in the **current working directory** (the
project root). Use a kebab-case folder name derived from the feature title. Create the directory
if it doesn't exist.

Example: `_features/multi-tenant-workspace-support/feature-brief.md`

---

## Step 2: Generate the document

Use the structure below. Every section must contain **real content from the discussion** — no
placeholder text in the final output.

```markdown
# [Feature / Project Title]

> **Date:** YYYY-MM-DD
> **Status:** Draft

---

## 1. Overview

One paragraph. What is this? Why does it exist? What problem does it solve?

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

## 4. Architecture

High-level architecture using ASCII art to show flow, structure, or relationships.

Example patterns to use as appropriate:

```
[Client] ──► [API Gateway] ──► [Service A]
                                    │
                              [Service B] ──► [DB]
```

```
┌─────────────┐       ┌──────────────┐
│  Component  │──────►│  Component   │
└─────────────┘       └──────────────┘
```

Cover:
- Key components and how they interact
- Data flow through the system
- External dependencies or integrations
- Where state lives

---

## 5. User Stories

| As a         | I want                        | So that                          |
|--------------|-------------------------------|----------------------------------|
| [user type]  | [goal or action]              | [benefit or outcome]             |

---

## 6. Functional Requirements

- FR-1: ...
- FR-2: ...

---

## 7. Non-Functional Requirements

- NFR-1: Performance: ...
- NFR-2: Security: ...
- NFR-3: Scalability: ...

---

## 8. Design Decisions

Key decisions made and the reasoning behind each. Note meaningful alternatives considered.

| Decision | Choice | Rationale |
|----------|--------|-----------|
| ...      | ...    | ...       |

---

## 9. Out of Scope

Things explicitly not part of this brief. Not implied to be future work — just not in scope here.

- ...

---

## 10. References

Links, docs, tickets, prior discussions.
```

---

## Step 3: Save the file

Save to `_features/<feature-name>/feature-brief.md`.

Confirm to the user:

> "Saved to `./_features/multi-tenant-workspace-support/feature-brief.md`."

---

## Guidelines

- **Be concrete.** Replace every `...` with real content. No placeholder text.
- **Architecture diagram is mandatory.** Use ASCII art — boxes, arrows, and labels. Match the
  diagram style to what's being shown: flow diagrams for data pipelines, layered boxes for
  services, tree structures for hierarchies.
- **Backlog-ready.** After reading this doc, an engineer should be able to write epics and
  issues without asking further questions.
- **Decisions over descriptions.** If a tradeoff was discussed, it must appear in section 8.
- **Out of Scope is not Future Work.** It means "not part of this brief" — it may or may not
  be picked up later. Don't frame it as planned future work unless that was explicitly stated.
- **Date.** Use today's actual date.