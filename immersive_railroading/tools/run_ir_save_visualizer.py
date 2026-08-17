#!/usr/bin/env python3
"""Launch the read-only Immersive Railroading artifact visualizer."""

from __future__ import annotations

import sys
from pathlib import Path


TOOLS_DIR = Path(__file__).resolve().parent
if str(TOOLS_DIR) not in sys.path:
    sys.path.insert(0, str(TOOLS_DIR))


def main() -> int:
    try:
        from ir_save_visualizer.__main__ import main as visualizer_main
    except ImportError as exc:
        print(f"Unable to load the visualizer: {exc}", file=sys.stderr)
        print("Run this file with Python 3 and install tkinter and Matplotlib.", file=sys.stderr)
        return 1
    try:
        return visualizer_main()
    except Exception as exc:
        if exc.__class__.__name__ == "TclError":
            print("Unable to start the visualizer: no usable desktop display was found.", file=sys.stderr)
            print("Run this launcher from a graphical desktop session.", file=sys.stderr)
            return 1
        raise


if __name__ == "__main__":
    raise SystemExit(main())
