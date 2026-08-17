"""Versioned JSON artifact loading for the visualizer."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Protocol

from .model import SceneDocument
from .scene import build_scene_document


class ArtifactError(ValueError):
    """The selected file is not a supported visualizer artifact."""


class ArtifactAdapter(Protocol):
    format_name: str

    def load(self, payload: dict[str, Any], *, sample_count: int) -> SceneDocument:
        ...


class V1Adapter:
    format_name = "ir-save-extractor/v1"

    def load(self, payload: dict[str, Any], *, sample_count: int) -> SceneDocument:
        return build_scene_document(payload, sample_count=sample_count)


ADAPTERS: dict[str, ArtifactAdapter] = {V1Adapter.format_name: V1Adapter()}


def load_artifact(path: str | Path, *, sample_count: int = 64) -> SceneDocument:
    artifact_path = Path(path).expanduser().resolve()
    if not artifact_path.is_file():
        raise ArtifactError(f"artifact is not a file: {artifact_path}")
    try:
        payload = json.loads(artifact_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise ArtifactError(f"could not read JSON artifact {artifact_path}: {exc}") from exc
    if not isinstance(payload, dict):
        raise ArtifactError("artifact root must be a JSON object")
    format_name = payload.get("format")
    adapter = ADAPTERS.get(str(format_name))
    if adapter is None:
        supported = ", ".join(sorted(ADAPTERS))
        raise ArtifactError(f"unsupported artifact format {format_name!r}; supported formats: {supported}")
    return adapter.load(payload, sample_count=sample_count)
