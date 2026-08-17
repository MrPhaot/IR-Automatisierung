"""Format-independent scene objects used by the visualizer."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Iterable, Mapping


WorldPoint = tuple[float, float, float]
Polyline = tuple[WorldPoint, ...]


def world_point(value: Any) -> WorldPoint | None:
    """Convert a JSON coordinate sequence to a validated world point."""

    if not isinstance(value, (list, tuple)) or len(value) != 3:
        return None
    try:
        return (float(value[0]), float(value[1]), float(value[2]))
    except (TypeError, ValueError):
        return None


def world_points(values: Iterable[Any]) -> tuple[WorldPoint, ...]:
    result: list[WorldPoint] = []
    for value in values:
        point = world_point(value)
        if point is not None:
            result.append(point)
    return tuple(result)


@dataclass(frozen=True)
class SceneObject:
    """A selectable render object in Minecraft world coordinates.

    ``positions`` contains point-like geometry such as tile positions or Bézier
    controls. ``polylines`` contains line-like geometry such as curves and
    topology candidates. Both are intentionally retained because a future
    renderer may use the original controls rather than sampled display points.
    ``metadata`` is the original source record, not a lossy summary.
    """

    object_id: str
    kind: str
    dimension: str | None
    positions: tuple[WorldPoint, ...] = ()
    polylines: tuple[Polyline, ...] = ()
    status: str | None = None
    metadata: Mapping[str, Any] = field(default_factory=dict)

    @property
    def primary_position(self) -> WorldPoint | None:
        if self.positions:
            return self.positions[0]
        for polyline in self.polylines:
            if polyline:
                return polyline[0]
        return None

    @property
    def all_geometry(self) -> tuple[WorldPoint, ...]:
        points = list(self.positions)
        for polyline in self.polylines:
            points.extend(polyline)
        return tuple(points)


@dataclass(frozen=True)
class SceneDocument:
    """Normalized artifact document consumed by the view and picking layers."""

    format: str
    complete: bool
    source: Mapping[str, Any]
    stats: Mapping[str, Any]
    dimensions: tuple[str, ...]
    objects: tuple[SceneObject, ...]
    warnings: tuple[str, ...] = ()
    extra: Mapping[str, Any] = field(default_factory=dict)

    def objects_for(self, kinds: set[str] | None = None, status: str | None = None, dimension: str | None = None) -> tuple[SceneObject, ...]:
        return tuple(
            item
            for item in self.objects
            if (kinds is None or item.kind in kinds)
            and (status is None or item.status == status)
            and (dimension is None or item.dimension == dimension)
        )

    @property
    def bounds(self) -> tuple[WorldPoint, WorldPoint] | None:
        points = [point for item in self.objects for point in item.all_geometry]
        if not points:
            return None
        return (
            tuple(min(point[index] for point in points) for index in range(3)),
            tuple(max(point[index] for point in points) for index in range(3)),
        )  # type: ignore[return-value]
