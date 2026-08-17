#!/usr/bin/env python3
"""Launch the Immersive Railroading save extractor GUI."""

from __future__ import annotations

import sys
from pathlib import Path


TOOLS_DIR = Path(__file__).resolve().parent
if str(TOOLS_DIR) not in sys.path:
    sys.path.insert(0, str(TOOLS_DIR))


def main() -> int:
    try:
        from ir_save_extractor.gui import main as gui_main
    except ImportError as exc:
        print(f"Unable to load the extractor GUI: {exc}", file=sys.stderr)
        print("Run this file with Python 3 and ensure tkinter is installed.", file=sys.stderr)
        return 1
    try:
        return gui_main()
    except Exception as exc:
        # Tk raises TclError when a desktop display is unavailable. Keeping the
        # launcher boundary readable is more useful than exposing a traceback.
        if exc.__class__.__name__ == "TclError":
            print("Unable to start the GUI: no usable desktop display was found.", file=sys.stderr)
            print("Run this launcher from a graphical desktop session.", file=sys.stderr)
            return 1
        raise


if __name__ == "__main__":
    raise SystemExit(main())
