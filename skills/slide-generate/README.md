# Slide Generate — Company Template Handoff

After `deck.html` is locked, one step remains that this skill can't do: turning it into an
actual, editable `.pptx` that carries your company's brand. That happens in Microsoft
Copilot inside PowerPoint, not here — this file is the reference for that handoff.

## Why hand off HTML instead of outline.md

By the time `deck.html` exists, it's the fully finalized artifact — every slide's wording,
structure, and diagrams were already reviewed and locked slide-by-slide. Copilot's job at
this point is narrower than generating a deck from scratch: reskin locked content into your
company template's colors, fonts, and layouts — not invent or rewrite it. Handing over the
HTML, rather than the earlier `outline.md`, means Copilot works from what you actually
approved, not an earlier draft.

## Inputs

1. **Your company PowerPoint template** — open it in PowerPoint first, so Copilot has your
   brand's colors, fonts, and master slides as the active template.
2. **`deck.html`** — the structure and content source. Attach it in the Copilot chat pane
   if your version supports file attachments; otherwise paste its contents directly.
3. **`context.md`** — background only (audience, goal, tone). Tell Copilot explicitly that
   this is context, not content, so it doesn't turn "Audience & Goal" into a slide.

## Prompt template

```
Using this template, create a presentation based on the attached deck.html.

- Follow deck.html for slide structure, order, and exact content (titles, body text,
  tables, diagrams). Don't add, remove, or rewrite content beyond what's there.
- Apply this template's color scheme, fonts, and styling. deck.html's own CSS is a layout
  reference only — match this template's visual identity, not the HTML's colors.
- context.md is background on the purpose and audience of this deck — use it to inform
  tone, not as slide content.
```

## After Copilot generates the deck

Check before treating it as final:
- **Slide count and order** match `deck.html`.
- **Tables and diagrams** survived the conversion — Copilot tends to simplify multi-track
  flow diagrams (connectors, parallel chains) into plainer shapes. Re-check those slides
  by hand against `deck.html`.
- **Colors and fonts** come from the company template, not leftover PowerPoint defaults —
  flag any slide that looks unstyled.
