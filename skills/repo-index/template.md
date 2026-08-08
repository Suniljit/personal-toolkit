# INDEX.md template

Fill and write to the project root as `INDEX.md`. Drop any section the repo has nothing for.

## Depth

`## Folders` is a nested bullet list, indentation mirroring the tree — a child folder nests under its parent bullet, named by its own segment (not the full path; the nesting already supplies that). Give a folder its own bullet when it's entered on its own terms: separately owned, or holding a distinct kind of thing. Keep descending while that stays true. A monorepo's `packages/<pkg>/src/` earns three nested bullets (`packages/`, then `<pkg>/`, then `src/`); a flat `utils/` earns one. Stop at the depth where the reader can pick a destination; below that they can read the tree themselves.

## Docs sections

Every subfolder of `docs/` gets its **own `##` section** listing its documents one row each, the same way `## Design` does — a reader looking for a decision or a spec finds the document from `INDEX.md`, not from a directory listing. Use the column shapes below where they're defined; otherwise `| Document | Description |`.

## Template

```markdown
---
indexed_commit: <full sha of HEAD when this map was drawn>
last_updated: YYYY-MM-DD
---

# INDEX.md

High-level map of this repo — what each top-level folder and root file covers. Read this first when navigating; update it when a change adds, removes, or repurposes a folder or file.

## Folders

- `<folder>/` — <what lives here, and what a reader comes here for. Where the folder holds many peers, name them.>
- `<folder>/` — <one line>
  - `<child>/` — <one line>
    - `<grandchild>/` — <one line>

## Root files

| File | Description |
|---|---|
| `<file>` | <one line> |

## Design

<!-- docs/design/ — rows written by /tech-docs -->

| Document | Status | Depends on | Description |
|---|---|---|---|
| [PRD](docs/design/prd.md) | draft | — | Problem, scope, success metrics |

## ADRs

<!-- docs/adr/ — records written by /domain-modeling -->

| ADR | Status | Description |
|---|---|---|
| [ADR-0001](docs/adr/0001-<slug>.md) | accepted | <the decision, in one line> |

## <Other docs subfolder>

| Document | Description |
|---|---|
| [<title>](docs/<folder>/<file>.md) | <one line> |
```
