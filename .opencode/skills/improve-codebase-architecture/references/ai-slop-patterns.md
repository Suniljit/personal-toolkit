# AI Slop Patterns Reference

Common over-engineering patterns introduced by AI-generated code, and how to fix them.

---

## 1. Unnecessary Wrapper Classes

**Slop:**
```python
class StringHelper:
    @staticmethod
    def format_name(name: str) -> str:
        return name.strip().title()
```

**Fix:** Just use a module-level function, or inline it if it's one line.
```python
def format_name(name: str) -> str:
    return name.strip().title()
```

---

## 2. Pointless Type Aliases

**Slop:**
```python
UserId = str
UserName = str
EmailAddress = str
```

**Fix:** Delete them unless they carry semantic weight (e.g., `JSON = dict[str, Any]` is fine).

---

## 3. Over-commented Obvious Lines

**Slop:**
```python
# Initialize the counter to zero
counter = 0

# Loop through each item in the list
for item in items:
    # Append item to results
    results.append(item)
```

**Fix:** Delete comments that just restate the code. Keep comments that explain *why*.

---

## 4. Verbose Boilerplate Configuration

**Slop:**
```python
class Config:
    def __init__(self):
        self.debug = False
        self.verbose = False
        self.timeout = 30
        self.max_retries = 3
        self.base_url = ""
    
    def set_debug(self, value: bool) -> None:
        self.debug = value
    
    def get_debug(self) -> bool:
        return self.debug
    # ... 20 more setters/getters
```

**Fix:** Use a dataclass. Getters/setters for simple values are Java thinking.
```python
from dataclasses import dataclass

@dataclass
class Config:
    debug: bool = False
    verbose: bool = False
    timeout: int = 30
    max_retries: int = 3
    base_url: str = ""
```

---

## 5. Unnecessary Abstraction Layers

**Slop:**
```python
class DataProcessor:
    def __init__(self, fetcher: DataFetcher, transformer: DataTransformer, loader: DataLoader):
        ...

class DataFetcher:
    def fetch(self): ...

class DataTransformer:
    def transform(self, data): ...

class DataLoader:
    def load(self, data): ...
```
When all three classes are only ever used together and have no other implementations.

**Fix:** Collapse into a single function or class unless the abstraction is genuinely needed.

---

## 6. Exception Wrapping That Loses Information

**Slop:**
```python
try:
    result = do_thing()
except Exception as e:
    raise CustomError("Something went wrong") from None  # loses the original error
```

**Fix:** Handle specifically or re-raise with context:
```python
try:
    result = do_thing()
except ValueError as e:
    raise ConfigError(f"Invalid config value: {e}") from e
```

---

## 7. Overuse of `**kwargs` to Avoid Explicit Parameters

**Slop:**
```python
def create_user(**kwargs):
    name = kwargs.get("name")
    email = kwargs.get("email")
    role = kwargs.get("role", "user")
```

**Fix:** Use explicit parameters. Kwargs make code harder to read, type-check, and autocomplete.
```python
def create_user(name: str, email: str, role: str = "user"):
    ...
```

---

## 8. Redundant Utility Modules That Just Wrap Built-ins

**Slop:**
```python
# utils/list_utils.py
def get_first(lst):
    return lst[0] if lst else None

def get_last(lst):
    return lst[-1] if lst else None

def is_empty(lst):
    return len(lst) == 0
```

**Fix:** Delete. Use `lst[0] if lst else None` inline.

---

## 9. Fake Constants (Variables Named Like Constants But Changed)

**Slop:**
```python
MAX_RETRIES = 3
# ... later:
MAX_RETRIES = user_config.get("retries", MAX_RETRIES)
```

**Fix:** If it's configurable, don't name it like a constant. Use a config object.

---

## 10. Overly Defensive None-Checks Everywhere

**Slop:**
```python
if user is not None:
    if user.name is not None:
        if user.name.strip() is not None:
            formatted = user.name.strip().title()
```

**Fix:** Validate at entry points. Use type hints. Trust your own data inside a module.

---

## 11. Long Functions That Could Be Named Sub-steps

When a function is 80+ lines doing sequential steps, each step should be its own function.

**Fix:** Extract each logical step:
```python
def process_order(order):
    validated = validate_order(order)
    enriched = enrich_with_inventory(validated)
    priced = apply_pricing(enriched)
    return submit_order(priced)
```

---

## 12. Star Imports

**Slop:**
```python
from utils import *
from models import *
```

**Fix:** Always import explicitly. Star imports make it impossible to know where names come from.

---

## 13. Duplicated Error Messages / Magic Strings

**Slop:**
```python
# file_a.py
raise ValueError("User not found")
# file_b.py
return {"error": "User not found"}
# file_c.py
log.error("User not found")
```

**Fix:** Define error messages as constants in one place, or use an enum.

---

## 14. Concerns Mixed in One File

**Slop:**
```python
# main.py — 600 lines mixing HTTP handling, business logic, DB queries, and config
def handle_request(req):
    # parse request
    # validate with business rules
    # query the database directly
    # format and return response
```

**Fix:** Split by concern. Each layer gets its own module.
```python
# api/handlers.py    — parse and delegate; no business logic
# services/orders.py — business rules; no HTTP or DB awareness
# db/queries.py      — data access; no business logic
# config.py          — all config; imported by whoever needs it
```