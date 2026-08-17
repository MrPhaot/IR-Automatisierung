"""Read-only visualizer for Immersive Railroading extraction artifacts."""

from .loader import ArtifactError, load_artifact
from .model import SceneDocument, SceneObject

__all__ = ["ArtifactError", "SceneDocument", "SceneObject", "load_artifact"]
