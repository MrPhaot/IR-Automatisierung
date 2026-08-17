"""Module entry point for the IR geometry visualizer."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path


def _prepare_matplotlib_config() -> None:
    """Keep Matplotlib configuration outside the repository and home config."""

    if os.environ.get("MPLCONFIGDIR"):
        return
    config_dir = Path(tempfile.gettempdir()) / "ir-save-visualizer-mpl"
    config_dir.mkdir(parents=True, exist_ok=True)
    os.environ["MPLCONFIGDIR"] = str(config_dir)


def main() -> int:
    _prepare_matplotlib_config()
    # Prime the toolkit path before Matplotlib imports its projection registry.
    # This prevents a mixed user/system Matplotlib installation from emitting
    # a false "3-D projection unavailable" warning at startup.
    from .view import SceneView

    SceneView._prefer_matching_mplot3d()
    from .ui import main as ui_main

    return ui_main()


if __name__ == "__main__":
    raise SystemExit(main())
