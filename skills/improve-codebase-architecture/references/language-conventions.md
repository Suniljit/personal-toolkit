# Python Conventions

## Import Ordering (PEP 8 / isort)
```python
# 1. Standard library
import os
from pathlib import Path

# 2. Third-party
import requests
from pydantic import BaseModel

# 3. Local
from myapp.config import settings
```

## Naming
- `snake_case` — variables, functions
- `PascalCase` — classes
- `UPPER_SNAKE_CASE` — constants
- `_leading_underscore` — module-private

## File Structure (top to bottom)
1. Module docstring
2. Imports (ordered above)
3. Constants / module-level config
4. Custom exceptions
5. Classes
6. Functions
7. `if __name__ == "__main__":` (scripts only)

## Function Length
- Aim under 40 lines. Over 60 is a strong smell. One function = one thing.

## Type Hints
- All function signatures. Use `X | None` (Python 3.10+) over `Optional[X]`.

## Docstrings
- Module: always. Public functions: if non-obvious. Private: only if complex.

---

## Clean Architecture Layering

Dependencies flow inward only:

```
CLI / API / UI         ← I/O, formatting, framework glue
    ↓
Services / Use Cases   ← business logic; pure functions where possible
    ↓
Data / Storage         ← DB, files, external APIs
    ↓
Domain / Models        ← types, entities, validation — no external dependencies
    ↓
Config / Constants     ← read at startup, injected downward
```

## Folder Structures

**Small script / CLI:**
```
project/
├── main.py       # entry point only
├── config.py     # all config and constants
├── models.py     # data types
├── services.py   # business logic
└── utils.py      # shared pure utilities
```

**Medium app:**
```
project/
├── main.py
├── config/       # env vars, constants
├── models/       # data types, validation
├── services/     # business logic (one file per domain concept)
├── api/ or cli/  # handlers, formatters — no business logic
├── db/           # data access — no business logic
└── utils/        # shared pure utilities
```

## Separation of Concerns Checklist
- [ ] Business logic: no direct I/O (`requests`, `open()`, DB calls)
- [ ] API/CLI layer: no business logic — delegates immediately
- [ ] Config: read once at startup and injected; not scattered
- [ ] Models: no business logic or I/O — just structure and validation
- [ ] Utils: pure functions, no side effects
- [ ] Each file has one responsibility you can state in one sentence

## Comment Philosophy
Comment the **why** and the **non-obvious what**. Never the obvious.

| Worth commenting | Skip |
|---|---|
| Why timeout is 30s specifically | `# set timeout to 30` |
| Workaround for known API bug | `# call the API` |
| The business rule behind a condition | `# check if user exists` |

## DRY
Copy-pasted 2+ times → extract to a function. Across files → shared module.

## Dependency Injection over Global State
```python
# Bad
def process():
    db = get_global_db()

# Good
def process(db: Database, cfg: Config):
    ...
```