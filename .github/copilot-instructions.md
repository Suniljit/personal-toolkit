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

## 3. Modern Typing
- **Mandatory Typing:** Use type hints for ALL signatures. 
    - Use lowercase built-in generics: `list[str]`, `dict[str, int]`.
    - Use the pipe operator `|` for Unions/Optional: `str | None` (Avoid `Union`/`Optional` modules).
    - Use `collections.abc` for `Callable` or `Iterable`.
    - **Never use `Any`.**

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
- **Logging:** Use `loguru` for structured logging. Log at appropriate levels (DEBUG, INFO, WARNING, ERROR) with contextual information.

## Workflow

### 1. Plan Mode Default
- Enter plan mode for **ANY non-trivial task** (3+ steps or architectural decisions)
- If something goes sideways, **STOP and re-plan immediately** — don't keep pushing
- Use plan mode for **verification steps**, not just building
- Write **detailed specs upfront** to reduce ambiguity

### 2. Subagent Strategy
- Use **subagents liberally** to keep the main context window clean
- Offload **research, exploration, and parallel analysis** to subagents
- For complex problems, **throw more compute at it via subagents**
- **One task per subagent** for focused execution

### 3. Self-Improvement Loop
- After **ANY correction from the user**, update `tasks/lessons.md` using the pattern
- Write **rules for yourself** that prevent the same mistake
- **Ruthlessly iterate** on these lessons until the mistake rate drops
- **Review lessons at session start** for the relevant project

### 4. Verification Before Done
- **Never mark a task complete** without proving it works
- **Diff behavior** between main and your changes when relevant
- Ask yourself: *"Would a staff engineer approve this?"*
- **Run tests, check logs, demonstrate correctness**

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask **"Is there a more elegant way?"**
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution."
- Skip this for **simple, obvious fixes** — don't over-engineer
- **Challenge your own work** before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: **just fix it**. Don't ask for hand-holding
- Point at **logs, errors, failing tests** — then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. **Plan First:** Write plan to `tasks/todo.md` with checkable items  
2. **Verify Plan:** Check in before starting implementation  
3. **Track Progress:** Mark items complete as you go  
4. **Explain Changes:** High-level summary at each step  
5. **Document Results:** Add review section to `tasks/todo.md`  
6. **Capture Lessons:** Update `tasks/lessons.md` after corrections  

## Core Principles
- **Simplicity First:** Make every change as simple as possible. Impact minimal code.
- **No Laziness:** Find root causes. No temporary fixes. Senior developer standards.