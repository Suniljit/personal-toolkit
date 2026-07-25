---
name: slide-outline
description: >
  Turn a finished slide-planning discussion into a slide-by-slide outline and a
  context file for later amendment sessions. Trigger on: "turn this into a slide
  outline", "write up the deck outline", "generate the outline and context files",
  or once a /grilling or /grill-with-docs session about slide content has settled.
---

# Slide Outline

Two-file output from a finished planning discussion: `outline.md` is the slide-by-slide
source of truth for *content* (near-final wording, not layout). `context.md` is the *why*
— enough for a fresh agent to resume an amendment conversation without re-asking settled
questions.

---

## Step 1 — Confirm readiness and save location

This runs after the content discussion has converged, not during it. If the conversation
hasn't settled the deck's content yet, say so and suggest `/grilling` or `/grill-with-docs`
first.

Resolve where to save: look for an existing `_slides/` directory; if none exists, propose
`_slides/<kebab-case-deck-title>/`. Confirm with the user before writing.

---

## Step 2 — Write outline.md

One section per slide, numbered in presentation order. For each slide, capture:
- **Type** — `title`, `section-divider`, `content-bullets`, `multi-column`, `table`,
  `chart-narrative`, `quote`, `agenda`, `closing`, `diagram-flow`, or `diagram-converge`
  (these match the templates `slide-generate` draws from). Use `custom` if nothing fits.
  For `multi-column`, note the item count in **Content** so `slide-generate` can pick a
  sensible column/row split. For a diagram, note whether it should fill the slide or sit
  alongside other content (partial) — both are supported.
- **Content** — near-final title and body text/bullets. Note any table/chart data inline.

```markdown
# <Deck Title> — Outline

## Slide 1 — <Working Title>
**Type:** title
**Content:**
- ...

## Slide 2 — <Working Title>
**Type:** content-bullets
**Content:**
- ...
```

Completion criterion: every topic from the discussion maps to exactly one slide, and the
wording is close enough to final that `slide-generate` only has to format it, not rewrite
it.

---

## Step 3 — Write context.md

```markdown
# <Deck Title> — Context

## Audience & Goal
...

## Tone / Voice
...

## Design decisions locked so far
...

## Other decisions & rationale
...

## Open questions
...
```

Completion criterion: a new agent reading only this file could resume an amendment
conversation without re-asking anything already settled.

---

## Step 4 — Confirm

Present both files. Ask the user to confirm or request edits before finishing.

---

## Guidelines

- Outline is content, not layout — leave HTML/visual decisions to `slide-generate`.
- Don't invent content the discussion didn't cover — capture gaps as open questions
  instead of filling them in.
- `context.md` is a living document: `slide-generate` will append design decisions to it
  as slides get locked. Leave "Design decisions locked so far" empty if nothing's been
  decided yet.
