---
applyTo: "**"
---
# Project Coding Standards & Professionalism

## 1. The Golden Rule: Zero Slop
- **No Meta-Commentary:** Do not use emojis or phrases like "Here is the change" or "As requested."
- **Code Speaks for Itself:** Never explain *what* a line does if it is obvious. Delete all redundant comments (e.g., `# Updated logic`, `# Fixes: [hash]`).
- **Why, Not What:** Comments must only explain complex business logic, regex patterns, or non-obvious "API Gotchas." 
- **No Dead Wood:** Zero commented-out code, author tags, or visual dividers (e.g., `// ***********`).

## 2. Structural Standards & Clean Code
- **Functional Discipline:** Follow the Single Responsibility Principle. Keep functions < 30 lines and nesting < 4 levels deep.
- **Naming:** PascalCase for Classes/Types; snake_case for variables/functions. Use `_prefix` for private members and `ALL_CAPS` for constants.
- **PEP 8 & Layout:** Strict 4-space indentation. Limit lines to 79–100 characters. Use blank lines to separate logical blocks.
- **Pythonic Flow:** Use f-strings and prefer early returns over nested `if/else` blocks. Use constants instead of magic numbers/strings.

## 3. Modern Typing & Documentation
- **Mandatory Typing:** Use type hints for ALL signatures. 
    - Use lowercase built-in generics: `list[str]`, `dict[str, int]`.
    - Use the pipe operator `|` for Unions/Optional: `str | None` (Avoid `Union`/`Optional` modules).
    - Use `collections.abc` for `Callable` or `Iterable`.
    - **Never use `Any`.**
- **Docstring Placement (Hard Anchor):** - Must use Google-style docstrings immediately following the colon (`:`).
    - **Forbidden:** Never insert anything between the opening `(` and closing `)` of a signature. 
    - For multiline signatures, the docstring starts below the final `-> ReturnType:`.

## 4. Explaining Logic to the User
- **Contextual Summary:** Provide a one-sentence summary of a code block's role before explaining internal logic.
- **Block-by-Block:** Provide concise, simple breakdowns outside of the code.
- **Example-Driven Logic:** For transformations, use this exact format:
    - **Input:** [Raw state]
    - **Transformation:** [Specific operation]
    - **Output:** [Resulting state]
- **Constraint:** Never use em dashes (—) in any explanation.

## 5. Error Handling & Testing
- **Resilience:** Use specific `try/except` blocks for I/O and APIs. Log errors with context; never swallow exceptions.
- **Validation:** Account for empty inputs and invalid types.
- **Testing:** Core logic requires `pytest` with mocked external dependencies. Write unit tests for all functions.