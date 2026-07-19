#!/usr/bin/env python3
"""Convert a non-text raw source (PDF, DOCX, PPTX, XLSX, etc.) to Markdown via MarkItDown.

Usage:
  wiki_convert.py raw/report.pdf
  wiki_convert.py raw/report.pdf --out /tmp/report.md
"""

import argparse
import sys
from pathlib import Path

from markitdown import MarkItDown


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", help="path to the source file")
    parser.add_argument("--out", help="write Markdown here instead of stdout")
    args = parser.parse_args()

    source = Path(args.file)
    if not source.is_file():
        print(f"error: {args.file} is not a file", file=sys.stderr)
        sys.exit(1)

    result = MarkItDown().convert(str(source))

    if args.out:
        Path(args.out).write_text(result.text_content)
        print(f"wrote {args.out}")
    else:
        print(result.text_content)


if __name__ == "__main__":
    main()
