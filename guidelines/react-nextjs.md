# React and Next.js

Scope: React components, Next.js routes/layouts/pages/hooks, server/client boundaries.

Avoid:

- Incorrect hook dependency arrays or stale closures.
- State updates during render.
- Unstable list keys where items can reorder.
- Client and server component boundary mistakes.
- Missing loading, empty, or error states for async data flows.
- Avoidable rerender churn for expensive computations or large trees.
- Repeated async work in shared render paths that can be resolved once per request.
- Components or hooks that have grown beyond a single axis of responsibility. Separate by axis of change: extract a **component** when complexity is visual (UI regions, layout, JSX branching); extract a **hook** when complexity is behavioural (state orchestration, side effects, async flows, business logic). A file that needs both treatments should receive both.
  - Strong signals for component extraction: banner-style JSX comments (`{/* Filters */}`, `{/* Table card */}`), UI sections that could render independently, or JSX that is "chapterised" into visually distinct regions.
  - Strong signals for hook extraction: clusters of related `useState`/`useEffect`, large handler sections, async orchestration, or logic that would survive if the JSX were deleted.
  - Line count is a smell detector, not a design rule. Rough guide: <250 lines is normal; 250–400 warrants a cohesion check; 400+ is a split candidate; 700+ is almost certainly overloaded. Dense forms, charts, and SVG components are common exceptions.
  - Un-exported in-file helpers (stateless, no meaningful props, no logic) are acceptable. Extract them to their own file once they exceed ~30 lines of JSX or acquire state.
  - Hooks also need cohesion — avoid dumping unrelated concerns into one hook. A good hook represents one behavioural domain (e.g. `usePagination`, `useAutosave`, `useCustomerSearch`).
