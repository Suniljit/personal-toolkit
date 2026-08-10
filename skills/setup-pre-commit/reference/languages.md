# Per-language hooks

For each language, the lint hook below runs at the default `pre-commit` stage; the typecheck/test hooks are `local` and need `stages: [pre-push]` set explicitly. Replace `<dir>/` with the language's directory from the repo map (`^` prefix, trailing `/`) — omit `files:` entirely if the language owns the whole repo.

## Python

```yaml
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.6.9
  hooks:
    - id: ruff
      args: [--fix]
      files: ^<dir>/
    - id: ruff-format
      files: ^<dir>/

- repo: local
  hooks:
    - id: <dir>-typecheck
      name: <dir> typecheck (ty)
      entry: bash -c 'cd <dir> && ty check'
      language: system
      pass_filenames: false
      stages: [pre-push]
      files: ^<dir>/
    - id: <dir>-test
      name: <dir> test (pytest)
      entry: bash -c 'cd <dir> && pytest'
      language: system
      pass_filenames: false
      stages: [pre-push]
      files: ^<dir>/
```

[`ty`](https://github.com/astral-sh/ty) is Astral's type checker — install it alongside `ruff` (`uv tool install ty` or add as a dev dependency). If the repo already has `mypy` configured and the user hasn't asked to migrate, keep `mypy` instead rather than replacing an existing setup silently. If the repo uses another test runner (`unittest`, `nox`, `tox`), swap the `entry` command accordingly — pytest is the default, not a requirement.

## JS / TypeScript

```yaml
- repo: https://github.com/pre-commit/mirrors-prettier
  rev: v4.0.0-alpha.8
  hooks:
    - id: prettier
      files: ^<dir>/

- repo: local
  hooks:
    - id: <dir>-typecheck
      name: <dir> typecheck (tsc)
      entry: bash -c 'cd <dir> && npx tsc --noEmit'
      language: system
      pass_filenames: false
      stages: [pre-push]
      files: ^<dir>/
    - id: <dir>-test
      name: <dir> test
      entry: bash -c 'cd <dir> && npm test'
      language: system
      pass_filenames: false
      stages: [pre-push]
      files: ^<dir>/
```

Only add the typecheck hook if `tsconfig.json` exists in `<dir>/`. Check `package.json` for the actual test script name (`test`, `test:unit`, ...) and lint tool (some repos use ESLint instead of/alongside Prettier — add `eslint --fix` as its own `pre-commit`-stage hook if so) rather than assuming `npm test` runs the whole suite.

## Rust

```yaml
- repo: https://github.com/doublify/pre-commit-rust
  rev: v1.0
  hooks:
    - id: fmt
      args: ["--manifest-path=<dir>/Cargo.toml", "--"]
    - id: clippy
      args: ["--manifest-path=<dir>/Cargo.toml", "--", "-D", "warnings"]

- repo: local
  hooks:
    - id: <dir>-test
      name: <dir> test (cargo test)
      entry: bash -c 'cd <dir> && cargo test'
      language: system
      pass_filenames: false
      stages: [pre-push]
      files: ^<dir>/
```

Rust has no separate typecheck step — `cargo test` already type-checks; `clippy` at the `pre-commit` stage catches most issues earlier.

## Go

```yaml
- repo: https://github.com/dnephin/pre-commit-golang
  rev: v0.5.1
  hooks:
    - id: go-fmt
      files: ^<dir>/
    - id: go-vet
      files: ^<dir>/

- repo: local
  hooks:
    - id: <dir>-test
      name: <dir> test (go test)
      entry: bash -c 'cd <dir> && go test ./...'
      language: system
      pass_filenames: false
      stages: [pre-push]
      files: ^<dir>/
```

## Other languages

If a directory's language isn't listed above, search the [pre-commit hooks directory](https://pre-commit.com/hooks.html) for a maintained hook before writing a `local` one by hand — most common formatters/linters (Ruby, Java, PHP, ...) already have one.
