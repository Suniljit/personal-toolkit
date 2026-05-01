# CLAUDE.md

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

## Logging

- Use `loguru` for structured logging; no `print` statements
- Never log sensitive data

## Testing

- Use `pytest` with Arrange-Act-Assert pattern
- Descriptive test names; keep tests isolated and deterministic

## Tooling

| Tool | Purpose |
|------|---------|
| `uv` | Dependency and environment management |
| `ruff` | Linting and formatting |
| `ty` | Type checking |
| `pyproject.toml` | Single source of truth |

## Python Environment Usage Setup

Prefer `uv run` over activating the environment and calling `python` directly.

**pyproject.toml present:**
```bash
uv venv .venv --python 3.13 && uv sync
uv run python script.py   # preferred over activating + python
```

**requirements.txt present:**
```bash
uv venv .venv --python 3.13 && uv pip install -r requirements.txt
uv run python script.py
```

**No dependency files:**
```bash
source ~/personal/bin/activate  # fallback only
```

Reuse an existing `.venv` if present. Never mix environments or assume system Python.

## LLM API Usage

- Always set a token limit when coding any LLM API calls, using the correct parameter name for that SDK (e.g. `max_tokens` for Anthropic, `max_completion_tokens` for OpenAI)
