# Security

Scope: every changed file.

Do not introduce:

- Hardcoded credentials, tokens, passwords, or connection strings in source.
- SQL injection from string-built queries instead of parameterized queries.
- XSS from unescaped or unsanitized user content in HTML or JSX.
- Path traversal from unsanitized user-controlled file paths.
- Missing CSRF protection on state-changing endpoints.
- Auth or authorization bypasses on protected routes or actions.
- Known vulnerable dependencies.
- Sensitive data exposure in logs, errors, or telemetry.
