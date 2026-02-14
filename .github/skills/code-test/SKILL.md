---
name: code-test
description: Analyzes Python source code to generate high-coverage pytest suites with modern typing and clear documentation.
---

# Agent Guidelines & Workflow

### 1. Hard Constraints (Non-Negotiable)
- **Modern Typing:** Use Python 3.9+ built-in collection types (e.g., `list[str]`, `dict[str, int]`).
- **Strictly No `Any`:** Every variable and return type must be explicitly typed.
- **No Legacy Imports:** Do not import `List`, `Dict`, or `Optional` from the `typing` module.
- **Clean Code:** Use `pytest` idioms only; avoid mixing `unittest.TestCase` patterns.

### 2. Analysis & Dependency Mapping
- **Introspection:** Identify all logic branches (if/else, try/except).
- **Mocking Strategy:** Use `pytest-mock` (mocker fixture) for external API calls, database connections, or filesystem operations.
- **Environment:** Check for required environment variables or config files needed for initialization.

### 3. The Test Manifest (Internal Documentation)
Every `test_*.py` file must start with a docstring using this exact structure:
```python
"""
### TEST MANIFEST ###
- WHAT: [Target class/module name]
- WHY:  [Business logic or safety reason for testing this module]
- HOW:  [Briefly describe setup: e.g., 'Using mocks for DB', 'Parametrized boundary tests']
"""
```

### 4. Implementation Logic
- **Parametrization:** mandatory for functions with multiple logical inputs.
- **Exception Testing:** Every `raise` statement in the source must have a corresponding `pytest.raises` test case.
- **Naming Convention:** `test_[function]_[scenario]_[expected_result]` (e.g., `test_login_invalid_password_raises_error`).

### 5. Final Delivery & Explanation
- **File Output:** Provide the full code for the `test_*.py` file.
- **External Summary:** Immediately following the code block, provide a concise explanation of the test strategy. **Do not** put this explanation inside the Python file as comments.