# Slide Style Guide

Universal rules for every deck this skill builds. Deck-specific choices (accent color,
imagery, tone) belong in that deck's `context.md`, not here.

## Flow direction

Pick one reading order — left-to-right or top-down — when slide 1 is locked, and hold it
for every subsequent slide. Record the choice in `context.md`. Layouts with an inherent
left/right split (multi-column, chart-narrative) still need to agree on which side (or
which corner, for a grid) reads first.

## Corners

Every box — cards, tables, callouts, image frames — gets rounded corners. No sharp edges.
Use the `--radius` variable in `deck.css` (seeded at `12px`) so the radius stays identical
across every slide; don't hand-pick a radius per slide.

## Tables

Light and minimal:
- No dark fills, anywhere — header rows get a light tint (`--color-table-header-bg`), not
  a dark background.
- Thin, light borders (`--color-border`) or very light zebra striping — never heavy grid
  lines.
- Generous cell padding over dense packing.

## Multi-column layouts

`multi-column.html` supports 2–6 items via the `--cols` grid variable; add more `.card`
items than `--cols` and they wrap onto additional rows automatically. Prefer 3–4 columns
for readability — past that, trim each card to a short heading and a single line, and
consider wrapping into two rows (e.g. `--cols: 3` with 6 cards) instead of cramming 5–6
into one row.

## Diagrams

`diagram-flow.html` and `diagram-converge.html` are built from shared parts —
`.diagram-banner` (title), `.tracks`/`.track` (parallel step chains), `.node`
(a step or decision box), `.connector` (an arrow between steps) — plus the existing
`.card`/`.grid` for callouts. They can fill the whole slide, or the `.tracks`/`.node`
pieces alone can drop into any other template's `.slide-body` for a partial diagram
next to other content.

A connector that crosses between tracks (jumping from the middle of one chain into
another) is a one-off — draw it as a positioned line/SVG once the boxes' final
positions are set, per diagram, rather than trying to generalize it.

## Consistency over novelty

Once a pattern is locked — flow direction, radius, table treatment, type scale — every
later slide reuses it. A deviation is a deliberate, called-out decision recorded in
`context.md`, never silent drift.

## Component reuse

Start from `references/templates/` and whatever's already locked in this deck before
designing anything net-new.
