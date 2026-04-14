# AGENTS.md

Guidelines for Python agent development.

## Core Principles

- **Readability over cleverness** — write for a junior engineer, not to impress
- **KISS** — simplest solution that works; avoid over-engineering
- **DRY** — extract repeated logic into functions
- **YAGNI** — don't build what isn't needed yet

## Python Standards

- `snake_case` for variables/functions, `PascalCase` for classes, `UPPER_CASE` for constants
- Type hints on all public functions and classes; always include return types
- Return new objects instead of mutating inputs; avoid mutable default arguments
- Raise meaningful exceptions with context (`raise ... from`)
- Prefer early returns over deep nesting

## Comments & Documentation

Write for a junior engineer who can read code but may not follow non-obvious logic.

- **Comment the why, and the non-obvious how** — skip comments on dead-obvious code, but add them wherever a junior might pause and wonder what's happening
- Docstrings on all functions, classes, and modules
- No banner-style comments (no `# ===`, `# ---`, `# ***` dividers)
- No emojis or meta-commentary in comments
- Keep comments short and inline where possible; avoid walls of text above a function

```python
# Good — explains non-obvious behaviour
timeout = base * (2 ** attempt)  # exponential backoff; each retry waits longer

# Bad — states the obvious
x = x + 1  # increment x by 1
```

## Data & Structure

- Prefer `dataclasses` over raw dicts for structured data
- Avoid magic numbers — assign them to named constants

## Workflow

- Plan before coding unless the task is trivial
- Fix bugs proactively when discovered
- Record lessons in `_lessons/lessons.md` after mistakes

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

## Environment Setup

Default Python: **3.13**. Prefer `uv run` over activating the environment and calling `python` directly.

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

## Non-Negotiables

- Always set a token limit when calling any LLM API, using the correct parameter name for that SDK (e.g. `max_tokens` for Anthropic, `max_completion_tokens` for OpenAI)
- No wildcard imports
- Use f-strings
- Keep functions small and focused
- Follow PEP 8