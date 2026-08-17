"""Tkinter application embedding the interactive 3-D scene view."""

from __future__ import annotations

import argparse
import json
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, ttk
from typing import Iterable

from .loader import ArtifactError, load_artifact
from .model import SceneDocument, SceneObject
from .picking import PickCandidate, pick_candidates


LAYER_LABELS = {
    "parent_point": "Parent points",
    "gag_point": "Gag points",
    "curve": "Curves",
    "curve_control_point": "Curve controls/endpoints",
    "topology_candidate": "Topology candidates",
    "topology_endpoint": "Unresolved endpoints",
    "topology_segment": "Invalid topology records",
}


class VisualizerApp(tk.Tk):
    def __init__(self, artifact_path: Path | None = None, *, sample_count: int = 64, pick_tolerance: float = 8.0) -> None:
        super().__init__()
        self.title("Immersive Railroading Geometry Visualizer")
        self.minsize(1100, 700)
        self.document: SceneDocument | None = None
        self.sample_count = sample_count
        self.pick_tolerance = pick_tolerance
        self.layer_vars = {kind: tk.BooleanVar(value=True) for kind in LAYER_LABELS}
        self.status_var = tk.StringVar(value="All statuses")
        self.dimension_var = tk.StringVar(value="All dimensions")
        self.summary_var = tk.StringVar(value="Open an ir-geometry-topology.json artifact.")
        self._candidate_objects: tuple[PickCandidate, ...] = ()
        self._build()
        if artifact_path is not None:
            self.after(0, lambda: self.open_artifact(artifact_path))

    def _build(self) -> None:
        root = ttk.Panedwindow(self, orient="horizontal")
        root.pack(fill="both", expand=True)
        plot_frame = ttk.Frame(root, padding=6)
        side_frame = ttk.Frame(root, padding=8)
        root.add(plot_frame, weight=5)
        root.add(side_frame, weight=2)
        plot_frame.rowconfigure(1, weight=1)
        plot_frame.columnconfigure(0, weight=1)
        controls = ttk.Frame(plot_frame)
        controls.grid(row=0, column=0, sticky="ew", pady=(0, 6))
        ttk.Button(controls, text="Open artifact…", command=self._choose_artifact).pack(side="left")
        ttk.Button(controls, text="Reset view", command=self._reset_view).pack(side="left", padx=(6, 0))
        ttk.Label(controls, textvariable=self.summary_var).pack(side="left", padx=(12, 0))

        from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
        from matplotlib.figure import Figure

        self.figure = Figure(figsize=(8, 6), dpi=100)
        from .view import SceneView

        self.scene_view = SceneView(self.figure, sample_count=self.sample_count)
        self.canvas = FigureCanvasTkAgg(self.figure, master=plot_frame)
        self.canvas.draw()
        self.canvas.get_tk_widget().grid(row=1, column=0, sticky="nsew")
        toolbar = NavigationToolbar2Tk(self.canvas, plot_frame, pack_toolbar=False)
        toolbar.update()
        toolbar.grid(row=2, column=0, sticky="ew")
        self.canvas.mpl_connect("button_press_event", self._on_click)

        side_frame.rowconfigure(4, weight=1)
        ttk.Label(side_frame, text="Layers", font=("TkDefaultFont", 10, "bold")).grid(row=0, column=0, sticky="w")
        layer_frame = ttk.Frame(side_frame)
        layer_frame.grid(row=1, column=0, sticky="ew", pady=(2, 8))
        for row, (kind, label) in enumerate(LAYER_LABELS.items()):
            ttk.Checkbutton(layer_frame, text=label, variable=self.layer_vars[kind], command=self._rerender).grid(row=row, column=0, sticky="w")
        filter_frame = ttk.Frame(side_frame)
        filter_frame.grid(row=2, column=0, sticky="ew", pady=(0, 8))
        ttk.Label(filter_frame, text="Status:").grid(row=0, column=0, sticky="w")
        self.status_combo = ttk.Combobox(filter_frame, textvariable=self.status_var, state="readonly", values=("All statuses",), width=18)
        self.status_combo.grid(row=0, column=1, sticky="ew", padx=(4, 0))
        self.status_combo.bind("<<ComboboxSelected>>", lambda _event: self._rerender())
        ttk.Label(filter_frame, text="Dimension:").grid(row=1, column=0, sticky="w", pady=(4, 0))
        self.dimension_combo = ttk.Combobox(filter_frame, textvariable=self.dimension_var, state="readonly", values=("All dimensions",), width=18)
        self.dimension_combo.grid(row=1, column=1, sticky="ew", padx=(4, 0), pady=(4, 0))
        self.dimension_combo.bind("<<ComboboxSelected>>", lambda _event: self._rerender())
        filter_frame.columnconfigure(1, weight=1)
        ttk.Label(side_frame, text="Selection candidates", font=("TkDefaultFont", 10, "bold")).grid(row=3, column=0, sticky="w")
        self.candidates = tk.Listbox(side_frame, height=5, exportselection=False)
        self.candidates.grid(row=4, column=0, sticky="ew", pady=(2, 8))
        self.candidates.bind("<<ListboxSelect>>", self._candidate_selected)
        ttk.Label(side_frame, text="Metadata", font=("TkDefaultFont", 10, "bold")).grid(row=5, column=0, sticky="w")
        self.metadata = tk.Text(side_frame, width=42, wrap="word", state="disabled")
        self.metadata.grid(row=6, column=0, sticky="nsew", pady=(2, 0))
        side_frame.rowconfigure(6, weight=1)

    def _choose_artifact(self) -> None:
        selected = filedialog.askopenfilename(title="Choose IR geometry artifact", filetypes=(("JSON artifacts", "*.json"), ("All files", "*")))
        if selected:
            self.open_artifact(Path(selected))

    def open_artifact(self, path: Path) -> None:
        try:
            document = load_artifact(path, sample_count=self.sample_count)
        except ArtifactError as exc:
            messagebox.showerror("Cannot open artifact", str(exc), parent=self)
            return
        self.document = document
        self.title(f"IR Geometry Visualizer — {path.name}")
        self.summary_var.set(f"{len(document.objects)} objects; {'complete' if document.complete else 'INCOMPLETE'}")
        statuses = sorted({item.status for item in document.objects if item.status})
        dimensions = sorted({item.dimension for item in document.objects if item.dimension})
        self.status_combo.configure(values=("All statuses", *statuses))
        self.dimension_combo.configure(values=("All dimensions", *dimensions))
        self.status_var.set("All statuses")
        self.dimension_var.set("All dimensions")
        self._rerender()
        self._show_document_summary(path)

    def _show_document_summary(self, path: Path) -> None:
        if self.document is None:
            return
        summary = {
            "artifact": str(path),
            "format": self.document.format,
            "complete": self.document.complete,
            "dimensions": self.document.dimensions,
            "stats": self.document.stats,
            "warnings": self.document.warnings,
            "extra_root_fields": self.document.extra,
        }
        self._set_metadata(summary)

    def _enabled_kinds(self) -> set[str]:
        return {kind for kind, variable in self.layer_vars.items() if variable.get()}

    def _filter_value(self, variable: tk.StringVar, prefix: str) -> str | None:
        value = variable.get()
        return None if value == prefix else value

    def _rerender(self) -> None:
        if self.document is None:
            return
        self.scene_view.render(
            self.document,
            enabled_kinds=self._enabled_kinds(),
            status=self._filter_value(self.status_var, "All statuses"),
            dimension=self._filter_value(self.dimension_var, "All dimensions"),
        )

    def _reset_view(self) -> None:
        self.scene_view.reset()
        self._rerender()

    def _on_click(self, event: object) -> None:
        if self.document is None or getattr(event, "inaxes", None) is not self.scene_view.axes:
            return
        x, y = getattr(event, "x", None), getattr(event, "y", None)
        if x is None or y is None:
            return
        self._candidate_objects = pick_candidates(self.scene_view.visible_objects, x, y, self.scene_view.project, self.pick_tolerance)
        self.candidates.delete(0, "end")
        for candidate in self._candidate_objects:
            item = candidate.object
            self.candidates.insert("end", f"{item.kind} | {item.object_id} | {candidate.distance_pixels:.1f}px")
        if self._candidate_objects:
            self.candidates.selection_set(0)
            self._show_object(self._candidate_objects[0].object)
        else:
            self._set_metadata({"selection": None, "message": "No visible object within the picking tolerance."})

    def _candidate_selected(self, _event: object) -> None:
        selection = self.candidates.curselection()
        if not selection:
            return
        self._show_object(self._candidate_objects[selection[0]].object)

    def _show_object(self, item: SceneObject) -> None:
        summary = {
            "id": item.object_id,
            "kind": item.kind,
            "dimension": item.dimension,
            "status": item.status,
            "world_positions": item.positions,
            "polylines": item.polylines,
            "metadata": item.metadata,
        }
        self._set_metadata(summary)

    def _set_metadata(self, value: object) -> None:
        encoded = json.dumps(value, indent=2, sort_keys=True, default=str)
        self.metadata.configure(state="normal")
        self.metadata.delete("1.0", "end")
        self.metadata.insert("1.0", encoded)
        self.metadata.configure(state="disabled")


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="View an IR save-extractor geometry artifact")
    parser.add_argument("artifact", nargs="?", type=Path, help="ir-geometry-topology.json; otherwise choose it in the GUI")
    parser.add_argument("--samples", type=int, default=64, help="display samples per Bézier curve (default: 64)")
    parser.add_argument("--pick-tolerance", type=float, default=8.0, help="screen-space pick tolerance in pixels")
    args = parser.parse_args(list(argv) if argv is not None else None)
    app = VisualizerApp(args.artifact, sample_count=args.samples, pick_tolerance=args.pick_tolerance)
    app.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
