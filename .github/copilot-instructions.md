---
applyTo: "**"
---
# Copilot Instructions

## Coding Standards & Best Practices

Universal coding standards applicable across Python projects.

## Code Quality Principles

### 1. Readability First
- Code is read more than written
- Clear variable and function names
- Self-documenting code preferred over comments
- Consistent formatting
- Explicit code preferred over clever shortcuts

### 2. KISS (Keep It Simple, Stupid)
- Simplest solution that works
- Avoid over-engineering
- No premature optimization
- Easy to understand beats clever code

### 3. DRY (Don't Repeat Yourself)
- Extract common logic into functions
- Reuse helpers and utilities
- Avoid copy-paste programming
- Consolidate duplicated business rules

### 4. YAGNI (You Aren't Gonna Need It)
- Do not build features before they are needed
- Avoid speculative abstractions
- Add complexity only when requirements justify it
- Start simple, then refactor when patterns emerge

## Python Standards

### Naming Conventions
- Use snake_case for variables and functions
- Use PascalCase for classes
- Use UPPER_CASE for constants

### Type Hints
- Use type hints for public functions and classes
- Avoid Any unless necessary
- Always include return types for top-level functions

### Immutability and Side Effects
- Prefer returning new objects instead of mutating inputs
- Avoid mutable default arguments

### Error Handling
- Raise meaningful exceptions
- Preserve context using `raise ... from`
- Avoid silent failures

### Control Flow
- Prefer early returns over deep nesting
- Keep conditionals simple and readable

## Comments and Documentation

- Explain WHY, not WHAT
- Remove redundant or outdated comments
- Use docstrings for all functions, classes, and modules
- No emojis or meta-commentary in code comments

## Data Modeling

- Prefer dataclasses or structured types over raw dictionaries

## Workflow
- Default to plan mode unless trivial.
- Break work into steps before coding.
- Use subagents liberally.
- Verify before completion, tests, behavior, outputs.
- Prefer elegant solutions.
- Fix bugs autonomously.

## Improvement
- Record lessons in `_lessons/lessons.md` after mistakes.

## Logging

- Use logging instead of print. 
- Prefer the `loguru` library for structured logging.
- Avoid logging sensitive data

## Performance

- Measure before optimizing
- Avoid unnecessary complexity
- Use efficient Python patterns

## Testing

- Prefer `pytest` for testing
- Follow Arrange-Act-Assert pattern
- Use descriptive test names
- Keep tests isolated and deterministic

## Code Smells

- Long functions
- Deep nesting
- Magic numbers
- Too many boolean flags

## Tooling

- ruff for linting and formatting
- ty for type checking
- pyproject.toml as single source of truth

## General Rules

- Follow PEP 8
- Prefer f-strings
- Avoid wildcard imports
- Keep functions small and focused

**Remember**: Clear, maintainable Python code enables faster development and safer changes.
