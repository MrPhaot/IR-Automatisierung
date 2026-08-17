"""Convert extractor JSON into selectable scene objects."""

from __future__ import annotations

import copy
from typing import Any

from .model import SceneDocument, SceneObject, WorldPoint, world_point


KNOWN_ROOT_KEYS = {
    "format",
    "complete",
    "source",
    "stats",
    "dimensions",
    "parents",
    "gags",
    "topology",
    "warnings",
}


def sample_cubic(control_points: tuple[WorldPoint, WorldPoint, WorldPoint, WorldPoint], samples: int = 64) -> tuple[WorldPoint, ...]:
    """Sample a cubic Bézier curve without changing its stored controls."""

    samples = max(2, min(int(samples), 4096))
    p1, c1, c2, p2 = control_points
    result: list[WorldPoint] = []
    for index in range(samples):
        t = index / (samples - 1)
        u = 1.0 - t
        result.append(tuple(
            u**3 * p1[axis]
            + 3 * u**2 * t * c1[axis]
            + 3 * u * t**2 * c2[axis]
            + t**3 * p2[axis]
            for axis in range(3)
        ))
    return tuple(result)  # type: ignore[return-value]


def _record(value: Any) -> dict[str, Any]:
    return copy.deepcopy(value) if isinstance(value, dict) else {}


def _position(record: dict[str, Any]) -> WorldPoint | None:
    return world_point(record.get("position"))


def _dimension(record: dict[str, Any]) -> str | None:
    value = record.get("dimension")
    return str(value) if value is not None else None


def _curve_data(record: dict[str, Any], curve_index: int) -> tuple[WorldPoint, WorldPoint, WorldPoint, WorldPoint] | None:
    curves = record.get("curves")
    if not isinstance(curves, list) or curve_index >= len(curves):
        return None
    curve = curves[curve_index]
    if not isinstance(curve, dict):
        return None
    points = tuple(world_point(curve.get(key)) for key in ("p1", "ctrl1", "ctrl2", "p2"))
    if any(point is None for point in points):
        return None
    return points  # type: ignore[return-value]


def _add_tile_objects(objects: list[SceneObject], records: Any, kind: str) -> None:
    if not isinstance(records, list):
        return
    for index, value in enumerate(records):
        record = _record(value)
        position = _position(record)
        if position is None:
            continue
        object_id = str(record.get("id", f"{kind}:{index}"))
        objects.append(SceneObject(
            object_id=f"{kind}:{object_id}",
            kind=kind,
            dimension=_dimension(record),
            positions=(position,),
            status=str(record.get("geometry_status")) if record.get("geometry_status") is not None else None,
            metadata=record,
        ))


def _add_parent_geometry(objects: list[SceneObject], records: Any, sample_count: int) -> dict[tuple[str, str], WorldPoint]:
    endpoints: dict[tuple[str, str], WorldPoint] = {}
    if not isinstance(records, list):
        return endpoints
    for index, value in enumerate(records):
        record = _record(value)
        segment_id = str(record.get("id", f"parent:{index}"))
        curves = record.get("curves")
        if not isinstance(curves, list):
            continue
        for curve_index in range(len(curves)):
            controls = _curve_data(record, curve_index)
            if controls is None:
                continue
            curve_id = f"curve:{segment_id}:{curve_index}"
            objects.append(SceneObject(
                object_id=curve_id,
                kind="curve",
                dimension=_dimension(record),
                positions=controls,
                polylines=(sample_cubic(controls, sample_count),),
                status=str(record.get("geometry_status")) if record.get("geometry_status") is not None else None,
                metadata={"source_record": record, "curve_index": curve_index, "curve": copy.deepcopy(curves[curve_index])},
            ))
            for label, point in zip(("start", "ctrl1", "ctrl2", "end"), controls):
                point_id = f"curve-control:{segment_id}:{curve_index}:{label}"
                objects.append(SceneObject(
                    object_id=point_id,
                    kind="curve_control_point",
                    dimension=_dimension(record),
                    positions=(point,),
                    status=str(record.get("geometry_status")) if record.get("geometry_status") is not None else None,
                    metadata={"source_record": record, "curve_index": curve_index, "control_name": label, "curve": copy.deepcopy(curves[curve_index])},
                ))
            endpoints[(segment_id, "start")] = controls[0]
            endpoints[(segment_id, "end")] = controls[3]
    return endpoints


def _endpoint_reference(value: Any) -> tuple[str, str] | None:
    if not isinstance(value, dict):
        return None
    segment = value.get("segment")
    side = value.get("side")
    if segment is None or side not in {"start", "end"}:
        return None
    return str(segment), str(side)


def _add_topology_objects(objects: list[SceneObject], records: Any, endpoints: dict[tuple[str, str], WorldPoint]) -> None:
    if not isinstance(records, list):
        return
    for index, value in enumerate(records):
        record = _record(value)
        kind = str(record.get("kind", "topology"))
        status = str(record.get("status")) if record.get("status") is not None else None
        positions: list[WorldPoint] = []
        explicit = world_point(record.get("position"))
        if explicit is not None:
            positions.append(explicit)
        from_point = endpoints.get(_endpoint_reference(record.get("from")) or ("", ""))
        to_point = endpoints.get(_endpoint_reference(record.get("to")) or ("", ""))
        endpoint = record.get("endpoint")
        if not positions and isinstance(endpoint, dict):
            endpoint_point = endpoints.get(_endpoint_reference(endpoint) or ("", ""))
            if endpoint_point is not None:
                positions.append(endpoint_point)
        polylines: tuple[tuple[WorldPoint, ...], ...] = ()
        if from_point is not None and to_point is not None:
            polylines = ((from_point, to_point),)
            if not positions:
                positions.append(from_point)
        object_id = f"topology:{index}"
        dimensions = record.get("dimension")
        objects.append(SceneObject(
            object_id=object_id,
            kind=f"topology_{kind}",
            dimension=str(dimensions) if dimensions is not None else None,
            positions=tuple(positions),
            polylines=polylines,
            status=status,
            metadata=record,
        ))


def build_scene_document(payload: dict[str, Any], *, sample_count: int = 64) -> SceneDocument:
    """Build a scene while retaining every source record and unknown root key."""

    objects: list[SceneObject] = []
    parents = payload.get("parents", [])
    gags = payload.get("gags", [])
    _add_tile_objects(objects, parents, "parent_point")
    _add_tile_objects(objects, gags, "gag_point")
    endpoints = _add_parent_geometry(objects, parents, sample_count)
    _add_topology_objects(objects, payload.get("topology", []), endpoints)
    dimensions = payload.get("dimensions", [])
    if not isinstance(dimensions, list):
        dimensions = []
    dimensions = tuple(str(value) for value in dimensions)
    if not dimensions:
        dimensions = tuple(sorted({item.dimension for item in objects if item.dimension is not None}))
    warnings = payload.get("warnings", [])
    if not isinstance(warnings, list):
        warnings = [str(warnings)]
    return SceneDocument(
        format=str(payload.get("format", "unknown")),
        complete=bool(payload.get("complete", False)),
        source=copy.deepcopy(payload.get("source", {})) if isinstance(payload.get("source"), dict) else {},
        stats=copy.deepcopy(payload.get("stats", {})) if isinstance(payload.get("stats"), dict) else {},
        dimensions=dimensions,
        objects=tuple(objects),
        warnings=tuple(str(value) for value in warnings),
        extra={key: copy.deepcopy(value) for key, value in payload.items() if key not in KNOWN_ROOT_KEYS},
    )
