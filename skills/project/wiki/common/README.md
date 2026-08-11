# LLM Wiki

An implementation of [Andrej Karpathy's LLM wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f): instead of re-retrieving and re-synthesizing raw source material on every question (classic RAG), you compile it once, into a persistent, growing collection of markdown pages that an agent maintains and you query directly. Compilation happens at ingest time; querying just reads what's already been organized.

This is one skill, [`wiki`](../SKILL.md), with four flows sharing one schema, dispatched by the first word of the invocation:

| Flow | Use it to... |
|---|---|
| [`wiki ingest`](../ingest.md) | Process new/changed files sitting in `wiki/raw/` into wiki pages |
| [`wiki add`](../add.md) | Feed in ad-hoc info on the spot (a paste, a note, a fact) |
| [`wiki query`](../query.md) | Ask the wiki a question, with citations |
| [`wiki lint`](../lint.md) | Health-check the wiki for contradictions, orphans, stale claims |

## How it fits together

```
wiki/
  raw/*.{pdf,docx,md,...}  ← immutable sources, git-ignored
        │
        │  /wiki ingest  (scripted hash-diff decides what's new — no LLM guessing)
        ▼
  pages/*.md     ← wiki pages (OKF-style frontmatter + a per-page Contents block)
  WIKI_INDEX.md  ← flat catalog: title, type, tags, one-line summary per page
  log.md         ← append-only history of every ingest/add/query/lint run
  manifest.json  ← {file: hash, ingested_at, pages_touched} — the diff's memory
```

`wiki add` and `wiki query`'s "file this back" path both write into `wiki/raw/` and then run the same ingest flow — there's exactly one way pages get created or changed, which is what makes `wiki lint` and the manifest trustworthy. Querying and linting read `wiki/pages/` only — `wiki/raw/` is ingestion input, never a wiki page, and living in its own folder keeps that distinction structural rather than a rule to remember.

## One-time setup

`common/` carries its own `pyproject.toml`. Only `wiki_convert.py` needs it (non-text conversion, via [MarkItDown](https://github.com/microsoft/markitdown)) — `wiki_diff.py` is stdlib-only and runs with plain `python3`, no venv required.

```bash
cd common
uv venv .venv --python 3.13 && uv sync
```

Do this once wherever the `wiki` skill lives — every project's `wiki ingest` flow shells out to this same venv via `uv run --project common ...`, so it's shared across every project using this skill, not reinstalled per project. If it's missing, the ingest flow will tell you to run it rather than falling back to a global `pip install`.

## Setup, per project

1. Make sure the `wiki` skill folder (which bundles `common/` inside it) is available to your agent harness (e.g. copied or symlinked under `~/.claude/skills/` or the project's `.claude/skills/`). The skill's flows reference `common/` by relative path, so it needs to stay nested inside `wiki/`, not moved out.
2. Drop source material into `wiki/raw/` at the project root — any mix of `.md`, `.txt`, `.pdf`, `.docx`, `.pptx`, `.xlsx`, etc.
3. Run `/wiki ingest`.
4. `wiki/` gets added to `.gitignore` automatically on first run — this is local working state, not something to commit. (Karpathy's original recommends git-backing the wiki for free version history; if you want that later, replace the blanket `wiki/` entry with `wiki/raw/` and `wiki/manifest.json` — those two stay ignored regardless, since they're working state, not wiki content.)

## Design choices worth knowing

- **No vectors, no Obsidian, no graph view.** Navigation is `WIKI_INDEX.md` plus grep — sufficient at the scale of project documentation, and it means zero embedding infrastructure to run or pay for.
- **"What's new" is a hash diff, not an LLM guess.** `scripts/wiki_diff.py` compares SHA-256 hashes in `manifest.json` against what's currently in `wiki/raw/` — deterministic, and it also catches *edited* files, not just new ones.
- **Section-level detail is progressively disclosed, not stuffed into the index.** `WIKI_INDEX.md` stays flat and cheap to read in full no matter how large the wiki gets; each page carries its own section-level outline (one-line gists per heading) in a Contents block at the top. `wiki query` shortlists from the flat index, then peeks at a candidate's Contents block before deciding whether to read the rest — the same reasoning-down idea behind [PageIndex](https://github.com/VectifyAI/PageIndex)'s reasoning-based retrieval, without duplicating each page's own headers into a second, ever-growing file.
- **Pages carry an [OKF](https://github.com/google/knowledge-catalog)-subset frontmatter** (`type`, `title`, `description`, `tags`, `timestamp`) — cheap to add, and gives the wiki a portable, standardized shape if the format gains traction, without buying into any heavier tooling.
- **Ingest never resolves contradictions** — it notes them and moves on; only `wiki lint` decides, and even lint only auto-resolves the unambiguous cases (orphans, single-candidate stale claims). Anything requiring judgment about which claim is *true* is always left for you.

See [`SCHEMA.md`](SCHEMA.md) for the exact file formats.
