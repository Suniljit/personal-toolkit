# AI Slop Patterns

Common over-engineering patterns in AI-generated code and how to fix them.

---

## 1. Unnecessary Wrapper Classes
Static methods or classes that just wrap a function. **Fix:** Use a module-level function.

## 2. Pointless Type Aliases
`UserId = str`, `EmailAddress = str`. **Fix:** Delete unless they carry real semantic weight.

## 3. Over-commented Obvious Lines
`# increment counter` above `i += 1`. **Fix:** Delete. Keep only *why* comments.

## 4. Verbose Config Boilerplate
Classes with getter/setter for every field. **Fix:** Use a `@dataclass`.

```python
@dataclass
class Config:
    debug: bool = False
    timeout: int = 30
```

## 5. Unnecessary Abstraction Layers
`DataFetcher`, `DataTransformer`, `DataLoader` classes used only together and never
swapped. **Fix:** Collapse into a single function or class.

## 6. Exception Wrapping That Loses Context
`raise CustomError("Something went wrong") from None`. **Fix:** `raise X from e`.

## 7. `**kwargs` to Avoid Explicit Parameters
`def create_user(**kwargs)` with manual `.get()` calls inside.
**Fix:** Use explicit typed parameters.

## 8. Redundant Utility Wrappers Around Built-ins
`get_first(lst)`, `is_empty(lst)`. **Fix:** Delete. Use inline idioms.

## 9. Fake Constants That Get Reassigned
`MAX_RETRIES = 3` then `MAX_RETRIES = user_config.get(...)`. **Fix:** Use a config object.

## 10. Defensive None-Checks Everywhere
Nested `if x is not None` chains. **Fix:** Validate at entry points. Trust your own data.

## 11. Long Functions Doing Sequential Steps
80+ line functions. **Fix:** Extract each step into a named function.

```python
def process_order(order):
    validated = validate_order(order)
    enriched = enrich_with_inventory(validated)
    return submit_order(apply_pricing(enriched))
```

## 12. Star Imports
`from utils import *`. **Fix:** Always import explicitly.

## 13. Duplicated Magic Strings
Same error message string in 3 files. **Fix:** One named constant or enum.

## 14. Concerns Mixed in One File
HTTP handling + business logic + DB queries + config in `main.py`.
**Fix:** One file per layer — handler, service, repository, config.