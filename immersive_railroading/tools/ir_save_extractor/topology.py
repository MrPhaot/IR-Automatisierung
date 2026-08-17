"""Conservative topology construction from reconstructed curves."""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Any

from .geometry import Curve, distance, length, sub


STATUSES = ("CONNECTED", "DISCONNECTED", "AMBIGUOUS", "UNTRACED", "INVALID")


@dataclass(frozen=True)
class Endpoint:
    segment_id: str
    side: str
    position: tuple[float, float, float]
    tangent: tuple[float, float, float]
    gauge: float | None
    builder_type: str


def _unit(value: tuple[float, float, float]) -> tuple[float, float, float]:
    magnitude = length(value)
    return (0.0, 0.0, 0.0) if magnitude == 0 else (value[0] / magnitude, value[1] / magnitude, value[2] / magnitude)


def endpoints(segment: dict[str, Any]) -> list[Endpoint]:
    curves = segment.get("curves", [])
    if not curves:
        return []
    curve = Curve(tuple(curves[0]["p1"]), tuple(curves[0]["ctrl1"]), tuple(curves[0]["ctrl2"]), tuple(curves[0]["p2"]))
    gauge = segment.get("metadata", {}).get("gauge")
    return [
        Endpoint(segment["id"], "start", curve.p1, _unit(curve.derivative(0.0)), gauge, segment.get("builder_type", "UNKNOWN")),
        Endpoint(segment["id"], "end", curve.p2, _unit(curve.derivative(1.0)), gauge, segment.get("builder_type", "UNKNOWN")),
    ]


def build_topology(segments: list[dict[str, Any]], *, distance_tolerance: float = 0.25, tangent_tolerance: float = 0.35) -> tuple[list[dict[str, Any]], dict[str, int]]:
    all_endpoints = [endpoint for segment in segments for endpoint in endpoints(segment)]
    edges: list[dict[str, Any]] = []
    matched: set[tuple[str, str]] = set()
    for segment in segments:
        if not segment.get("curves"):
            edges.append({
                "kind": "segment",
                "segment": segment.get("id"),
                "status": "INVALID",
                "reason": "segment has no reconstructed curve",
            })
    for index, left in enumerate(all_endpoints):
        for right in all_endpoints[index + 1 :]:
            if left.segment_id == right.segment_id:
                continue
            gap = distance(left.position, right.position)
            dot = sum(a * b for a, b in zip(left.tangent, right.tangent))
            if gap > distance_tolerance:
                continue
            if left.builder_type == "CROSSING" or right.builder_type == "CROSSING":
                status = "DISCONNECTED"
                reason = "built-in crossing retained as separate paths"
            elif abs(dot) < 1.0 - tangent_tolerance:
                status = "AMBIGUOUS"
                reason = "coincident endpoints have incompatible tangent evidence"
            else:
                status = "AMBIGUOUS"
                reason = "save data provides candidate proximity but no global connectivity relation"
            matched.add((left.segment_id, left.side))
            matched.add((right.segment_id, right.side))
            edges.append({
                "kind": "candidate",
                "from": {"segment": left.segment_id, "side": left.side},
                "to": {"segment": right.segment_id, "side": right.side},
                "status": status,
                "distance": gap,
                "tangent_dot": dot,
                "reason": reason,
            })
    for endpoint in all_endpoints:
        if (endpoint.segment_id, endpoint.side) not in matched:
            edges.append({
                "kind": "endpoint",
                "endpoint": {"segment": endpoint.segment_id, "side": endpoint.side},
                "status": "UNTRACED",
                "position": list(endpoint.position),
                "reason": "no saved/source-supported endpoint candidate was found",
            })
    counts = {status: sum(1 for edge in edges if edge["status"] == status) for status in STATUSES}
    return edges, counts
