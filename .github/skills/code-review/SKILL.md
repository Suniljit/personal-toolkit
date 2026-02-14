---
name: code-review
description: Refactor for SRP and logic. Adds intent-based comments without prefixes.
---
# Logic Review & Refactor Workflow

1. **Clean Code Principles:**
   - Descriptive and meaningful names for variables, functions, and classes
   - Single Responsibility Principle: each function/class does one thing well
   - DRY (Don't Repeat Yourself): no code duplication
   - Functions should be small and focused (ideally < 20-30 lines)
   - Avoid deeply nested code (max 3-4 levels)
   - Avoid magic numbers and strings (use constants)
   - Code should be self-documenting; comments only when necessary

2. **Direct Refactoring:**
   - Simplify complex loops and branches using built-in libraries.

3. **Clean Documentation:**
   - Generate Google-style docstrings for all new/refactored functions.

4. **Error Handling:**
   - Proper error handling at appropriate levels
   - Meaningful error messages
   - No silent failures or ignored exceptions
   - Fail fast: validate inputs early
   - Use appropriate error types/exceptions

5. **Security Review:**
   - Sensitive Data: No passwords, API keys, tokens, or PII in code or logs
   - Input Validation: All user inputs are validated and sanitized
   - SQL Injection: Use parameterized queries, never string concatenation
   - Authentication: Proper authentication checks before accessing resources