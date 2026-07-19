# Correctness and Maintainability

Scope: every changed file.

Avoid maintainability problems:

- Large functions or files that obscure logic enough to hide defects.
- Deep nesting where early returns or extraction would improve clarity.
- Missing or ineffective error handling, including swallowed exceptions.
- Mutable state updates that can leak across callers or renders.
- Debug logging left in production-facing paths.
- Dead code, unreachable branches, or unused imports that hide intent.
- Code duplicated >2x without shared function/module.
- Private class methods that do not use instance state. Prefer module-level functions unless the helper needs `this`, polymorphism, or class invariants.
- Inefficient algorithms or sync blocking in hot paths.
- Large bundle imports or missing caching where impact is meaningful.
- TODO/FIXME markers without tracking context.
- `||` fallback where falsy values (`0`, `''`, `false`) should be preserved. Prefer `??`.

Avoid weak naming, unexplained magic numbers, inconsistent formatting, missing tests for new/changed code.
