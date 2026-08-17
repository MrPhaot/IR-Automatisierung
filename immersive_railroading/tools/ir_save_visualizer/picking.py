"""Screen-space picking independent of the GUI toolkit."""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable, Iterable

from .model import SceneObject, WorldPoint


Projection = Callable[[WorldPoint], tuple[float, float, float]]


@dataclass(frozen=True)
class PickCandidate:
    object: SceneObject
    distance_pixels: float
    depth: float


def _segment_distance(px: float, py: float, ax: float, ay: float, bx: float, by: float) -> float:
    dx, dy = bx - ax, by - ay
    denominator = dx * dx + dy * dy
    if denominator == 0:
        return math.hypot(px - ax, py - ay)
    factor = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / denominator))
    return math.hypot(px - (ax + factor * dx), py - (ay + factor * dy))


def _object_distance(item: SceneObject, click_x: float, click_y: float, project: Projection) -> tuple[float, float] | None:
    best: tuple[float, float] | None = None
    for point in item.positions:
        x, y, depth = project(point)
        candidate = (math.hypot(click_x - x, click_y - y), depth)
        if best is None or candidate[0] < best[0]:
            best = candidate
    for polyline in item.polylines:
        if not polyline:
            continue
        projected = [project(point) for point in polyline]
        for point in projected:
            candidate = (math.hypot(click_x - point[0], click_y - point[1]), point[2])
            if best is None or candidate[0] < best[0]:
                best = candidate
        for left, right in zip(projected, projected[1:]):
            distance = _segment_distance(click_x, click_y, left[0], left[1], right[0], right[1])
            depth = min(left[2], right[2])
            if best is None or distance < best[0]:
                best = (distance, depth)
    return best


def pick_candidates(objects: Iterable[SceneObject], click_x: float, click_y: float, project: Projection, tolerance_pixels: float = 8.0) -> tuple[PickCandidate, ...]:
    """Return every visible object within the screen-space tolerance."""

    candidates: list[PickCandidate] = []
    for item in objects:
        measured = _object_distance(item, click_x, click_y, project)
        if measured is None or measured[0] > tolerance_pixels:
            continue
        candidates.append(PickCandidate(item, measured[0], measured[1]))
    candidates.sort(key=lambda candidate: (candidate.distance_pixels, candidate.depth, candidate.object.object_id))
    return tuple(candidates)
