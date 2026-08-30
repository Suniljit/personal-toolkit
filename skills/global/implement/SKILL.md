---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
metadata:
  opencode/autoinvoke: "false"
argument-hint: "Specify a spec to implement and a base branch to perform code review against."
---

Implement the work described by the user in the spec.

Run typechecking and single test files regularly.

If the spec is organized into phases, checkpoint each one: implement it, then typecheck and run any tests that already exist for it (a phase with no tests yet just needs a clean typecheck) → verify: both pass, then commit → verify: `git status` clean before starting the next phase.

Once all phases are done (or immediately, if the spec has no phases), run the full test suite and linter once.

Once done, invoke /code-review with the fixed point set to the merge-base between the current branch and the repo's default branch, and the spec source set to whatever spec/ticket this implementation was based on.
