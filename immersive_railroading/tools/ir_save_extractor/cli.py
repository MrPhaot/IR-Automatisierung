"""Command-line entry point for the offline extractor."""

from __future__ import annotations

import argparse
from pathlib import Path

from .extractor import ExtractionConfig, extract_save, validate_paths


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Extract Immersive Railroading geometry from a Minecraft save")
    parser.add_argument("save", type=Path, help="Minecraft save directory (read-only)")
    parser.add_argument("output", type=Path, help="separate output directory")
    parser.add_argument("--resource", action="append", type=Path, default=[], help="IR/addon jar, zip, or extracted resource directory; repeatable")
    parser.add_argument("--distance-tolerance", type=float, default=0.25)
    parser.add_argument("--tangent-tolerance", type=float, default=0.35)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    errors = validate_paths(args.save, args.output)
    if errors:
        for error in errors:
            print(f"error: {error}")
        return 2
    try:
        result = extract_save(ExtractionConfig(args.save, args.output, tuple(args.resource), args.distance_tolerance, args.tangent_tolerance), progress=print)
    except Exception as exc:  # CLI boundary: report a clean failure, retain traceback for debugging with -m callers.
        print(f"error: extraction failed: {exc}")
        return 1
    print(f"artifact: {result.artifact_path}")
    print(f"report: {result.report_path}")
    return 0
