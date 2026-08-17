"""Tkinter GUI for selecting a save and extraction output directory."""

from __future__ import annotations

import queue
import threading
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

from .extractor import ExtractionConfig, extract_save, validate_paths


class ExtractorApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Immersive Railroading Save Extractor")
        self.minsize(760, 520)
        self.save_var = tk.StringVar()
        self.output_var = tk.StringVar()
        self.status_var = tk.StringVar(value="Select a save folder and an output folder.")
        self.messages: queue.Queue[str] = queue.Queue()
        self._build()
        self.after(100, self._drain_messages)

    def _build(self) -> None:
        frame = ttk.Frame(self, padding=12)
        frame.pack(fill="both", expand=True)
        frame.columnconfigure(1, weight=1)
        ttk.Label(frame, text="Save folder:").grid(row=0, column=0, sticky="w", padx=(0, 8), pady=4)
        ttk.Entry(frame, textvariable=self.save_var).grid(row=0, column=1, sticky="ew", pady=4)
        ttk.Button(frame, text="Browse…", command=self._choose_save).grid(row=0, column=2, padx=(8, 0), pady=4)
        ttk.Label(frame, text="Output folder:").grid(row=1, column=0, sticky="w", padx=(0, 8), pady=4)
        ttk.Entry(frame, textvariable=self.output_var).grid(row=1, column=1, sticky="ew", pady=4)
        ttk.Button(frame, text="Browse…", command=self._choose_output).grid(row=1, column=2, padx=(8, 0), pady=4)
        actions = ttk.Frame(frame)
        actions.grid(row=2, column=0, columnspan=3, sticky="w", pady=(8, 4))
        ttk.Button(actions, text="Validate paths", command=self._validate).pack(side="left")
        self.extract_button = ttk.Button(actions, text="Extract", command=self._extract)
        self.extract_button.pack(side="left", padx=(8, 0))
        ttk.Label(frame, textvariable=self.status_var).grid(row=3, column=0, columnspan=3, sticky="w", pady=4)
        self.log = tk.Text(frame, height=24, state="disabled", wrap="word")
        self.log.grid(row=4, column=0, columnspan=3, sticky="nsew", pady=(8, 0))
        frame.rowconfigure(4, weight=1)

    def _choose_save(self) -> None:
        selected = filedialog.askdirectory(title="Choose Minecraft save folder")
        if selected:
            self.save_var.set(selected)

    def _choose_output(self) -> None:
        selected = filedialog.askdirectory(title="Choose extraction output folder", mustexist=False)
        if selected:
            self.output_var.set(selected)

    def _validate(self) -> bool:
        errors = validate_paths(Path(self.save_var.get()), Path(self.output_var.get())) if self.save_var.get() and self.output_var.get() else ["both paths are required"]
        if errors:
            self.status_var.set("Path validation failed.")
            self._append("ERROR: " + "; ".join(errors))
            return False
        self.status_var.set("Paths are valid. The save will be read-only.")
        self._append("Paths validated.")
        return True

    def _extract(self) -> None:
        if not self._validate():
            return
        self.extract_button.configure(state="disabled")
        self.status_var.set("Extracting…")
        config = ExtractionConfig(Path(self.save_var.get()), Path(self.output_var.get()))
        threading.Thread(target=self._worker, args=(config,), daemon=True).start()

    def _worker(self, config: ExtractionConfig) -> None:
        try:
            result = extract_save(config, progress=self.messages.put)
            self.messages.put(f"SUCCESS: artifact={result.artifact_path}")
            self.messages.put(f"STATS: {result.artifact['stats']}")
            self.messages.put("__DONE__")
        except Exception as exc:
            self.messages.put(f"ERROR: extraction failed: {exc}")
            self.messages.put("__DONE__")

    def _drain_messages(self) -> None:
        try:
            while True:
                message = self.messages.get_nowait()
                if message == "__DONE__":
                    self.extract_button.configure(state="normal")
                    self.status_var.set("Extraction finished; inspect the report for completeness.")
                else:
                    self._append(message)
        except queue.Empty:
            pass
        self.after(100, self._drain_messages)

    def _append(self, message: str) -> None:
        self.log.configure(state="normal")
        self.log.insert("end", message + "\n")
        self.log.see("end")
        self.log.configure(state="disabled")


def main() -> int:
    app = ExtractorApp()
    app.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
