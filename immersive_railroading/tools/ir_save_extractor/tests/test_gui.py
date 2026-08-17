from __future__ import annotations

import os
import unittest
from pathlib import Path
from unittest import skipUnless

from ir_save_extractor.extractor import validate_paths


class GUIBoundaryTests(unittest.TestCase):
    def test_gui_uses_same_path_boundary_as_core(self) -> None:
        self.assertTrue(validate_paths(Path("/definitely/missing/save"), Path("/tmp/output")))

    @skipUnless(os.environ.get("DISPLAY"), "requires a graphical display")
    def test_gui_can_be_constructed(self) -> None:
        from ir_save_extractor.gui import ExtractorApp
        import tkinter

        try:
            app = ExtractorApp()
        except tkinter.TclError as exc:
            self.skipTest(f"display is unavailable: {exc}")
        try:
            app.save_var.set("/save")
            app.output_var.set("/output")
            self.assertEqual(app.save_var.get(), "/save")
            self.assertEqual(app.output_var.get(), "/output")
        finally:
            app.destroy()


if __name__ == "__main__":
    unittest.main()
