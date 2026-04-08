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

- Default to planning before coding unless the task is trivial
- Break work into clear steps before implementation
- Verify outputs, behavior, and tests before completion
- Fix bugs proactively when discovered
- Prefer simple, elegant solutions over complex ones

## Improvement

- Record lessons in `_lessons/lessons.md` after mistakes

## Logging

- Use logging instead of print
- Prefer the `loguru` library for structured logging
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
- uv for dependency and environment management

## General Rules

- Follow PEP 8
- Prefer f-strings
- Avoid wildcard imports
- Keep functions small and focused

## Python Environment and Dependency Management

All Python work follows a deterministic setup to minimize environment drift and dependency conflicts.

### Tooling

Use `uv` for all environment and dependency operations. Do not use `pip`, `poetry`, or `conda` directly.

### Python Version

Default to Python 3.12 for all new projects and environments unless explicitly specified otherwise.

### Project Root (Default)

- Default project root is the current working directory (cwd)
- In monorepos, use the subdirectory if it contains dependency files

### Dependency Declaration

A project declares dependencies if any of the following exist:

- pyproject.toml
- requirements.txt
- requirements-dev.txt
- requirements.lock

### Environment Rules

1. Prefer a project-local virtual environment in .venv
2. Create it only if dependency files exist
3. Reuse existing .venv if present
4. Otherwise use the shared global environment

### Setup Flow

If pyproject.toml exists:

    uv venv .venv --python 3.12
    uv sync
    source .venv/bin/activate

If requirements.txt exists:

    uv venv .venv --python 3.12
    uv pip install -r requirements.txt
    source .venv/bin/activate

If only requirements-dev.txt exists:

    uv venv .venv --python 3.12
    uv pip install -r requirements-dev.txt
    source .venv/bin/activate

Otherwise:

    source ~/personal/bin/activate

### Activation Rule

Always activate the environment before:

- Running scripts
- Installing dependencies
- Running tests

    source .venv/bin/activate

### Global Environment

If no dependency files exist:

    source ~/personal/bin/activate

- Use uv pip only
- Do not install dependencies unless necessary

### Non-Negotiables

- Do not mix environments
- Do not install dependencies implicitly
- Do not assume system Python
- Do not create ad-hoc environments
- Always use Python 3.12 unless specified
- Use uv sync for pyproject-based projects
- Always set a default `max_tokens` limit in code when calling any LLM API.

**Remember:** Clear, maintainable Python code enables faster development and safer changes.
