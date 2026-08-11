---
name: slide-generate
description: >
  Generate a deck's slides as HTML, one slide at a time, iterating with the user until
  each is approved before moving to the next.
disable-model-invocation: true
---

# Slide Generate

Turns `outline.md` + `context.md` into a reviewed HTML deck, one slide **locked** at a
time. A locked slide is approved and final — it isn't touched again except by explicit
request. Never draft or preview a slide ahead of the current one.

---

## Step 1 — Load state

Read `outline.md`, `context.md`, `references/style-guide.md`, and the seed files in
`references/templates/`. Find or create the working `slides/` directory and `deck.css`
(seeded from `references/templates/deck.css` on first run).

Find the first slide without a locked `slides/NN/slide.html`. Check whether its **Type**
(from outline.md) has already been locked by an earlier slide in this deck.

Completion criterion: you know exactly one slide to work on next, and whether its type is
new or established.

---

## Step 2 — Draft: options for new types, one draft for established types

- **New type in this deck** (including slide 1, which also sets the deck's shared visual
  language): draft 2–3 meaningfully different layouts into
  `slides/NN/options/{a,b,c}.html`. Vary structure/emphasis, not just color swaps. Start
  from the matching `references/templates/` file and the rules already locked in
  `context.md` / `style-guide.md` — don't re-decide flow direction, corner radius, or
  table treatment per slide.
- **Established type**: draft directly to `slides/NN/slide.html` in the already-locked
  pattern. Generating fresh options for an already-solved layout decision is wasted work.
- Only stop to ask before drafting if the outline content genuinely doesn't fit any
  established or template pattern. Otherwise draft first — the render is the question.

---

## Step 3 — Review

Share the file path(s). The user may pick an option, ask for a combination of elements
from several, ask for different options, or request edits. Iterate only on this slide;
leave every other slide's files untouched.

---

## Step 4 — Lock

On explicit approval:
1. Save the final markup to `slides/NN/slide.html`. Leave the `options/` subfolder in
   place as history — it isn't read again.
2. If this slide established a new type, fold the chosen layout's reusable rules into
   `deck.css` and note the decision in `context.md`'s "Design decisions locked so far".
3. If the approved wording diverged from `outline.md`, update `outline.md` to match — it
   must stay the accurate source of truth for content.
4. Return to Step 1 for the next un-locked slide.

Completion criterion for the whole skill: every slide in `outline.md` has a corresponding
`slides/NN/slide.html`, and `outline.md`/`context.md` reflect the final approved state.

---

## Step 5 — Assemble

Once every slide is locked, inline `deck.css` and concatenate all `slides/NN/slide.html`
files in order into a single standalone `deck.html`.

Completion criterion: `deck.html` opens and renders every slide in order with no external
file dependencies.

---

## Guidelines

- One slide at a time, gated on approval — never generate ahead.
- Reuse over reinvention: `references/templates/` and already-locked slide types are the
  default starting point; design net-new only when outline content doesn't fit anything
  established.
- Keep `outline.md` and `context.md` in sync with what actually got approved — they're
  the memory a future session (possibly a different agent) will amend from.
