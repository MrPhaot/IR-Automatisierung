"""Lookup of IR track-definition resources in directories and jars/zips."""

from __future__ import annotations

import json
import zipfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


@dataclass(frozen=True)
class ResourceMatch:
    track_id: str
    source: str
    metadata: dict[str, Any]


def _candidate_names(track_id: str) -> tuple[str, ...]:
    namespace, _, clean = track_id.partition(":")
    if not clean:
        namespace, clean = "immersiverailroading", namespace
    if clean.startswith("track/"):
        clean = clean[len("track/") :]
    clean = clean.removesuffix(".json")
    preferred_namespace = namespace or "immersiverailroading"
    return (
        f"assets/{preferred_namespace}/track/{clean}.json",
        f"assets/immersiverailroading/track/{clean}.json",
        f"immersiverailroading/track/{clean}.json",
        f"track/{clean}.json",
    )


class ResourceCatalog:
    def __init__(self, roots: Iterable[Path] = ()):
        self.roots = tuple(Path(root) for root in roots)
        self._cache: dict[str, ResourceMatch | None] = {}

    def find_track(self, track_id: str) -> ResourceMatch | None:
        key = str(track_id or "default")
        if key in self._cache:
            return self._cache[key]
        for root in self.roots:
            match = self._find_in_root(key, root)
            if match:
                self._cache[key] = match
                return match
        self._cache[key] = None
        return None

    def _find_in_root(self, track_id: str, root: Path) -> ResourceMatch | None:
        names = _candidate_names(track_id)
        if root.is_dir():
            for name in names:
                path = root / name
                if not path.is_file():
                    continue
                try:
                    metadata = json.loads(path.read_text(encoding="utf-8"))
                except (OSError, UnicodeDecodeError, json.JSONDecodeError):
                    metadata = {"parse_error": True}
                return ResourceMatch(track_id, str(path), metadata if isinstance(metadata, dict) else {})
            return None
        if root.is_file() and root.suffix.lower() in {".jar", ".zip"}:
            try:
                with zipfile.ZipFile(root) as archive:
                    for name in names:
                        try:
                            raw = archive.read(name)
                        except KeyError:
                            continue
                        try:
                            metadata = json.loads(raw.decode("utf-8"))
                        except (UnicodeDecodeError, json.JSONDecodeError):
                            metadata = {"parse_error": True}
                        return ResourceMatch(track_id, f"{root}!/{name}", metadata if isinstance(metadata, dict) else {})
            except (OSError, zipfile.BadZipFile):
                return None
        return None
