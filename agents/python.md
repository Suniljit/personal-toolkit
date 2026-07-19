# Python

Scope: changed files are `.py`, or the project has `pyproject.toml` / `requirements.txt`.

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
