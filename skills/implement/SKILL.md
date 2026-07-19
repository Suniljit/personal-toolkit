---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Run typechecking regularly, single test files regularly, and the full test suite and linter once at the end.

Once done, invoke /code-review with the fixed point set to the merge-base between the current branch and the repo's default branch, and the spec source set to whatever spec/ticket this implementation was based on.
