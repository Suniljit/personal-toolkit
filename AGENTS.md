# AGENTS.md

Behavioral guidelines to reduce common LLM coding mistakes.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## Code Quality

Required on every changed file:
- Avoid security issues.
- Keep logic understandable, safely typed, maintainable, covered by tests.

Apply the scoped guidance below only when changed files match its scope:

| Scope | File |
|---|---|
| Every changed file | [agents/security.md](agents/security.md) |
| Every changed file | [agents/correctness-maintainability.md](agents/correctness-maintainability.md) |
| API route handlers | [agents/architecture.md](agents/architecture.md) |
| React components, Next.js routes/layouts/pages/hooks | [agents/react-nextjs.md](agents/react-nextjs.md) |
| API routes, server actions, DB queries, external calls | [agents/backend.md](agents/backend.md) |
| Component styling | [agents/tailwind-styling.md](agents/tailwind-styling.md) |
| Hooks, utilities, API handlers, feature logic | [agents/solid.md](agents/solid.md) |
| Any change | [agents/code-organization.md](agents/code-organization.md) |
| `.ts` / `.tsx` files | [agents/typescript-patterns.md](agents/typescript-patterns.md) |
| `.py` files, or `pyproject.toml`/`requirements.txt` present | [agents/python.md](agents/python.md) |

Also align with any accepted ADRs in [docs/adr](docs/adr/) and domain user stories in [docs/user_stories](docs/user_stories/) when behavior changes.

**How to apply:**
1. Identify change scope from the table above.
2. Read and apply the required guidelines plus every scoped file that matches.
3. Make small, direct changes that satisfy the guidelines without speculative abstraction.
4. Verify with tests or focused checks matching the change.

## Documentation

Project docs live in `docs/`. Refer to `INDEX.md` in the project root to understand the docs folder structure and navigate it. After any code changes, update relevant docs to reflect the new state. For any key architectural decision made, create an ADR in `docs/adr/`.

## LLM API Usage

- Always set a token limit when coding any LLM API calls, using the correct parameter name for that SDK (e.g. `max_tokens` for Anthropic, `max_completion_tokens` for OpenAI)

## Sub-Agents

- Use sub-agents liberally.
