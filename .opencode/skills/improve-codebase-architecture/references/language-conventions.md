# Python Conventions Reference

Quick reference for Python conventions to apply during refactoring.

---

## Python

### Import ordering (PEP 8 / isort standard)
```python
# 1. Standard library
import os
import sys
from pathlib import Path

# 2. Third-party packages
import requests
from pydantic import BaseModel

# 3. Local application modules
from myapp.config import settings
from myapp.utils import format_date
```

### Naming
- Variables and functions: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private (module-internal): `_leading_underscore`
- "Dunder" (special): `__double_underscore__`

### File/module structure (top to bottom)
1. Module docstring
2. Imports (ordered as above)
3. Constants / module-level config
4. Custom exceptions (if any)
5. Classes
6. Functions
7. `if __name__ == "__main__":` block (scripts only)

### Function length
- Aim for under 40 lines. Over 60 is a strong smell.
- Each function should do one thing.

### Docstrings
- Module: always, one-line or multi-line
- Public functions: always if non-obvious
- Private functions: only if logic is complex
- Use Google style or NumPy style consistently within a project

### Type hints
- Use them for all function signatures in modern Python (3.9+)
- Use `from __future__ import annotations` for forward references
- Use `X | None` instead of `Optional[X]` in Python 3.10+

---

## Clean Architecture Patterns

### Layering

A well-structured project has clear layers with dependencies flowing in one direction
(outer layers depend on inner layers, never the reverse):

```
CLI / API / UI        ← outer: I/O, formatting, framework glue
    ↓
Services / Use Cases  ← middle: business logic, pure functions where possible
    ↓
Data / Storage        ← inner: DB queries, file access, external APIs
    ↓
Domain / Models       ← core: types, entities, validation — no dependencies
    ↓
Config / Constants    ← foundation: read at startup, injected downward
```

### Folder structures by project type

**Small script or CLI tool:**
```
project/
├── main.py           # entry point only
├── config.py         # all config and constants
├── models.py         # data types
├── services.py       # business logic
└── utils.py          # shared pure utilities
```

**Medium application:**
```
project/
├── main.py           # entry point
├── config/
│   └── settings.py   # config, env vars, constants
├── models/           # data types, validation
├── services/         # business logic (one file per domain concept)
├── api/ or cli/      # I/O layer — handlers, formatters
├── db/ or storage/   # data access
└── utils/            # shared pure utilities
```

**Larger application:**
```
project/
├── main.py
├── config/
├── domain/           # pure models and business rules; no external dependencies
├── application/      # use cases / services; orchestrates domain + infrastructure
├── infrastructure/   # DB, external APIs, file system
├── api/ or cli/      # entry points
└── tests/
    ├── unit/
    └── integration/
```

### Separation of concerns checklist

Before finalizing a structure, verify:
- [ ] Business logic has no direct I/O (no `requests`, `open()`, DB calls)
- [ ] I/O layer (API/CLI) has no business logic — it delegates immediately
- [ ] Config is read once at startup and injected; not scattered across modules
- [ ] Models/types have no business logic or I/O — just structure and validation
- [ ] Utilities are pure functions with no side effects
- [ ] Each file has a single clear responsibility you can state in one sentence

---

## General Principles

### The 500-line rule
If a file is over 500 lines, ask: can this be split by concern? Common splits:
- Types / interfaces → `types.*` or `models.*`
- Constants / config → `constants.*` or `config.*`
- Utilities → `utils.*` or `helpers.*`
- A class that's too big → multiple files/classes by responsibility

### Magic numbers and strings
Any literal value that has meaning should be a named constant:
```python
# Bad
if retries > 3:
# Good
MAX_RETRIES = 3
if retries > MAX_RETRIES:
```

### Comment philosophy
Comment the **why** and the **non-obvious what**. Never the obvious.

| Worth commenting | Not worth commenting |
|---|---|
| Why a timeout is 30s specifically | `# set timeout to 30` |
| A workaround for a known API bug | `# call the API` |
| The business rule behind a condition | `# check if user exists` |
| Why a seemingly wrong approach is correct | `# return True` |

### DRY threshold
If code is copy-pasted 2+ times, it probably wants to be a function.
If a function is copy-pasted across files, it probably wants to be a shared module.

### Dependency injection over global state
Prefer passing config and dependencies explicitly rather than importing globals:
```python
# Bad — hidden dependency on global state
def process():
    db = get_global_db()
    cfg = GLOBAL_CONFIG

# Good — dependencies are visible and testable
def process(db: Database, cfg: Config):
    ...
```