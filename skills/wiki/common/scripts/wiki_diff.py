#!/usr/bin/env python3
"""Scripted new/changed-file detection for the LLM wiki's raw/ folder.

Usage:
  wiki_diff.py check --raw raw/ --manifest wiki/manifest.json
  wiki_diff.py mark  --raw raw/ --manifest wiki/manifest.json --file raw/doc.pdf --pages wiki/a.md,wiki/b.md
"""

import argparse
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            digest.update(chunk)
    return f"sha256:{digest.hexdigest()}"


def load_manifest(manifest_path: Path) -> dict:
    if not manifest_path.exists():
        return {}
    return json.loads(manifest_path.read_text())


def save_manifest(manifest_path: Path, manifest: dict) -> None:
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")


def current_files(raw_dir: Path) -> dict:
    return {
        str(p.relative_to(raw_dir.parent)): hash_file(p)
        for p in sorted(raw_dir.rglob("*"))
        if p.is_file()
    }


def cmd_check(args: argparse.Namespace) -> None:
    raw_dir = Path(args.raw)
    manifest = load_manifest(Path(args.manifest))
    files_now = current_files(raw_dir)

    new_files = [p for p in files_now if p not in manifest]
    changed_files = [
        p for p in files_now if p in manifest and manifest[p]["hash"] != files_now[p]
    ]
    removed_files = [p for p in manifest if p not in files_now]

    print(
        json.dumps(
            {"new": new_files, "changed": changed_files, "removed": removed_files},
            indent=2,
        )
    )


def cmd_mark(args: argparse.Namespace) -> None:
    raw_dir = Path(args.raw)
    manifest_path = Path(args.manifest)
    manifest = load_manifest(manifest_path)

    file_path = Path(args.file)
    if not file_path.is_file():
        print(f"error: {args.file} is not a file", file=sys.stderr)
        sys.exit(1)

    manifest[args.file] = {
        "hash": hash_file(file_path),
        "ingested_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "pages_touched": args.pages.split(",") if args.pages else [],
    }
    save_manifest(manifest_path, manifest)
    print(f"marked {args.file}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    check_p = sub.add_parser("check", help="list new/changed/removed files under raw/")
    check_p.add_argument("--raw", required=True)
    check_p.add_argument("--manifest", required=True)
    check_p.set_defaults(func=cmd_check)

    mark_p = sub.add_parser("mark", help="record a file as ingested")
    mark_p.add_argument("--raw", required=True)
    mark_p.add_argument("--manifest", required=True)
    mark_p.add_argument("--file", required=True, help="path to the raw file, e.g. raw/doc.pdf")
    mark_p.add_argument("--pages", default="", help="comma-separated wiki page paths touched")
    mark_p.set_defaults(func=cmd_mark)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
