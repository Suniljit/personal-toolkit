# Tech Docs — Design Brief flow

Read [`common/CONVENTIONS.md`](common/CONVENTIONS.md) first for the `docs/design/` layout and shared conventions.

Write the Design Brief & UI System document to `docs/design/design-brief.md`.

---

## Step 1 — Read the PRD and App Flow

Read `docs/design/prd.md` and `docs/design/app-flow.md`. If either is missing, stop and say so — component and layout choices are driven by the persona (PRD) and the screen map (App Flow); run those flows first.

---

## Step 2 — Grill the user

Run a `/grilling` session, with `/domain-modeling` alongside it (see Grilling in CONVENTIONS.md), covering:

- **Look & feel / brand identity** — tone, visual direction, mood, references
- **Design tokens** — color palette (primary, secondary, neutral, semantic: success/warning/error), typography (families, scale, weights, line heights), spacing & grid (base unit, e.g. 4px/8px, breakpoints)
- **UI component library** — buttons, form inputs, cards, navigation bars, modals, toasts, dropdowns — states each needs (default/hover/disabled/error)
- **Screen layout templates** — grids for the screen types found in `app-flow.md` (dashboards, forms, detail views, empty states)

**Considerations** — ground recommendations in these rather than guessing:
- **Brand:** with no references yet, don't invent a palette from nothing — propose 2-3 named directions (e.g. "minimal/neutral", "bold/saturated") and let the user pick before generating tokens.
- **Design tokens:** beyond success/warning/error, check for `info` and `disabled` semantic colors, and ask whether dark mode is in scope before finalizing the palette.
- **Component library:** sanity-check against the common set — buttons, inputs, cards, nav, modals, toasts, dropdowns, tables, pagination, avatars, badges — and flag any the screen map implies but the user didn't mention.
- **Layout templates:** confirm at least one responsive breakpoint (mobile vs. desktop) and the loading/empty/error variant per template, not just the happy-path layout.

Lead each question with your recommended answer. If the user has existing brand references (screenshots, a style guide, a competitor's look), ask for them before guessing.

When the system feels complete, confirm:
> *"I think we have the design system. Saving to `docs/design/design-brief.md` — ready?"*

---

## Step 3 — Generate the doc

Read [`templates/design-brief.md`](templates/design-brief.md) and fill in every section.

Apply the overflow rule from CONVENTIONS.md once the component library passes ~8 components with real state/variant detail — split each into `docs/design/design-brief/<component-slug>.md`.

---

## Step 4 — Save

Save to `docs/design/design-brief.md`. Add or update its row in the root `INDEX.md`'s **Design** table per CONVENTIONS.md.

## Completion criterion

`docs/design/design-brief.md` exists with every section filled (no placeholders) and `INDEX.md` has a current row for it.

Confirm:
> *"Saved to `docs/design/design-brief.md`."*
