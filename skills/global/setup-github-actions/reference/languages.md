# Per-language jobs

Each job below assumes `defaults.run.working-directory: <dir>` is set on the job (from the repo map) — commands run relative to that directory already, no `cd` needed. Add `paths: ['<dir>/**']` to the job's `on.pull_request` override, or a path filter step, if PRs frequently touch only one part of a monorepo and re-running every language's job on every PR is wasteful.

## Python

```yaml
jobs:
  backend-python:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: <dir>
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
        with:
          enable-cache: true
      - run: uv sync
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run ty check
      - run: uv run pytest
```

If the repo doesn't use `uv`, swap `uv sync` / `uv run` for `pip install -e .[dev]` with `actions/setup-python@v5` (`cache: pip`) instead of `setup-uv`. [`ty`](https://github.com/astral-sh/ty) is Astral's type checker; if the repo already has `mypy` configured and the user hasn't asked to migrate, keep `mypy run` instead of replacing an existing setup silently. Swap `pytest` for the repo's actual test runner (`unittest`, `nox`, `tox`) if different.

## JS / TypeScript

```yaml
jobs:
  frontend-js:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: <dir>
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: <dir>/package-lock.json
      - run: npm ci
      - run: npx eslint .
      - run: npx tsc --noEmit
      - run: npm test
```

Only add the `tsc --noEmit` step if `tsconfig.json` exists in `<dir>/`. Check `package.json` for the actual lint tool (Prettier instead of/alongside ESLint — add `npx prettier --check .` as its own step if so) and the actual test script name (`test`, `test:unit`, ...) rather than assuming `npm test` runs the whole suite. Swap `cache-dependency-path` and the install command (`npm ci` → `pnpm install --frozen-lockfile` / `yarn install --frozen-lockfile`) to match the repo's actual package manager and lockfile.

## Rust

```yaml
jobs:
  rust:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: <dir>
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: clippy, rustfmt
      - uses: Swatinem/rust-cache@v2
      - run: cargo fmt --check
      - run: cargo clippy -- -D warnings
      - run: cargo test
```

Rust has no separate typecheck step — `cargo test` and `cargo clippy` already type-check.

## Go

```yaml
jobs:
  go:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: <dir>
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: <dir>/go.mod
          cache-dependency-path: <dir>/go.sum
      - run: gofmt -l . | tee /dev/stderr | (! read)
      - run: go vet ./...
      - run: go test ./...
```

Go's `go build`/`go vet` already type-check; there's no separate typecheck step.

## Other languages

If a directory's language isn't listed above, search the [GitHub Actions Marketplace](https://github.com/marketplace?type=actions) for a maintained setup action (Ruby, Java, PHP, ...) before writing raw shell steps by hand.
