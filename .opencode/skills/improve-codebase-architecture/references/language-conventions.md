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

## General Principles

### The 500-line rule
If a file is over 500 lines, ask: can this be split by concern? Common splits:
- Types / interfaces → `types.*`
- Constants / config → `constants.*` or `config.*`
- Utilities → `utils.*` or `helpers.*`
- A class that's too big → multiple files/classes

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