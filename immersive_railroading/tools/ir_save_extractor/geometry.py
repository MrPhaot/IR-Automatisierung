"""IR-compatible geometry primitives reconstructed from Java-8 bytecode."""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Any


Vec = tuple[float, float, float]
KAPPA = 0.55191502449


def add(a: Vec, b: Vec) -> Vec:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def sub(a: Vec, b: Vec) -> Vec:
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def scale(a: Vec, factor: float) -> Vec:
    return (a[0] * factor, a[1] * factor, a[2] * factor)


def length(a: Vec) -> float:
    return math.sqrt(a[0] ** 2 + a[1] ** 2 + a[2] ** 2)


def distance(a: Vec, b: Vec) -> float:
    return length(sub(a, b))


def from_yaw(distance_value: float, yaw: float) -> Vec:
    angle = math.radians(yaw)
    return (math.sin(angle) * distance_value, 0.0, math.cos(angle) * distance_value)


def rotate_y(point: Vec, degrees: float) -> Vec:
    angle = math.radians(degrees)
    cosine, sine = math.cos(angle), math.sin(angle)
    return (cosine * point[0] + sine * point[2], point[1], -sine * point[0] + cosine * point[2])


def _vec(value: Any, default: Vec = (0.0, 0.0, 0.0)) -> Vec:
    if not isinstance(value, dict):
        return default
    keys = ("x", "y", "z") if "x" in value else ("X", "Y", "Z")
    try:
        return (float(value[keys[0]]), float(value[keys[1]]), float(value[keys[2]]))
    except (KeyError, TypeError, ValueError):
        return default


@dataclass(frozen=True)
class Curve:
    p1: Vec
    ctrl1: Vec
    ctrl2: Vec
    p2: Vec

    def position(self, t: float) -> Vec:
        u = 1.0 - t
        return add(add(scale(self.p1, u**3), scale(self.ctrl1, 3 * u * u * t)), add(scale(self.ctrl2, 3 * u * t * t), scale(self.p2, t**3)))

    def derivative(self, t: float) -> Vec:
        u = 1.0 - t
        return add(add(scale(sub(self.ctrl1, self.p1), 3 * u * u), scale(sub(self.ctrl2, self.ctrl1), 6 * u * t)), scale(sub(self.p2, self.ctrl2), 3 * t * t))

    def translated(self, offset: Vec) -> "Curve":
        return Curve(add(self.p1, offset), add(self.ctrl1, offset), add(self.ctrl2, offset), add(self.p2, offset))

    def transformed(self, yaw: float, mirror_z: bool = False) -> "Curve":
        def transform(point: Vec) -> Vec:
            value = (point[0], point[1], -point[2]) if mirror_z else point
            return rotate_y(value, yaw)

        return Curve(transform(self.p1), transform(self.ctrl1), transform(self.ctrl2), transform(self.p2))

    def linearize(self, smoothing: str) -> "Curve":
        a = distance(self.p1, self.ctrl1)
        b = distance(self.ctrl1, self.ctrl2)
        c = distance(self.ctrl2, self.p2)
        total = a + b + c
        if total == 0:
            return self
        dy = self.p2[1] - self.p1[1]
        ctrl1, ctrl2 = self.ctrl1, self.ctrl2
        smoothing = smoothing.upper()
        if smoothing in {"BOTH", "NEAR", "FAR"}:
            if smoothing in {"BOTH", "FAR"}:
                denominator = total if smoothing == "BOTH" else a + b
                if denominator:
                    ctrl1 = add(ctrl1, (0.0, a / denominator * dy, 0.0))
            if smoothing in {"BOTH", "NEAR"}:
                denominator = total if smoothing == "BOTH" else b + c
                if denominator:
                    ctrl2 = add(ctrl2, (0.0, -c / denominator * dy, 0.0))
        return Curve(self.p1, ctrl1, ctrl2, self.p2)

    def length(self, steps: int = 128) -> float:
        previous = self.position(0.0)
        total = 0.0
        for index in range(1, steps + 1):
            current = self.position(index / steps)
            total += distance(previous, current)
            previous = current
        return total

    def as_dict(self) -> dict[str, Any]:
        return {
            "p1": list(self.p1),
            "ctrl1": list(self.ctrl1),
            "ctrl2": list(self.ctrl2),
            "p2": list(self.p2),
            "length_approximation": self.length(),
        }


def circle(radius: int, degrees: float) -> Curve:
    ratio = degrees / 90.0
    curve = Curve(
        (0.0, 0.0, float(radius)),
        (ratio * KAPPA * radius, 0.0, float(radius)),
        (float(radius), 0.0, ratio * KAPPA * radius),
        (float(radius), 0.0, 0.0),
    ).transformed(-90.0 + degrees).translated((0.0, 0.0, -float(radius)))
    return curve


def _enum(value: Any, names: tuple[str, ...], default: str) -> str:
    if isinstance(value, str):
        candidate = value.split(":")[-1].upper()
        if candidate in names:
            return candidate
    if isinstance(value, (int, float)):
        index = int(value)
        if 0 <= index < len(names):
            return names[index]
    return default


def _info(data: dict[str, Any]) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
    info = data.get("info", {})
    if not isinstance(info, dict):
        return {}, {}, {}
    settings = info.get("settings", {})
    placement = info.get("placement", {})
    custom = info.get("custom", placement)
    return (
        settings if isinstance(settings, dict) else {},
        placement if isinstance(placement, dict) else {},
        custom if isinstance(custom, dict) else placement,
    )


def build_curves(data: dict[str, Any], tile_pos: Vec) -> tuple[str, list[Curve], list[str], dict[str, Any]]:
    """Return builder type, local/world curves, warnings, and normalized metadata."""

    settings, placement, custom = _info(data)
    names = ("STRAIGHT", "CROSSING", "SLOPE", "TURN", "SWITCH", "TURNTABLE", "CUSTOM", "TRANSFERTABLE")
    track_type = _enum(settings.get("type"), names, "STRAIGHT")
    direction = _enum(placement.get("direction", settings.get("direction")), ("NONE", "RIGHT", "LEFT"), "NONE")
    smoothing = _enum(settings.get("smoothing"), ("BOTH", "NEAR", "FAR", "NEITHER"), "BOTH")
    try:
        track_length = int(settings.get("length", 10))
    except (TypeError, ValueError):
        track_length = 10
    try:
        degrees = float(settings.get("degrees", 90.0))
    except (TypeError, ValueError):
        degrees = 90.0
    try:
        curvosity = float(settings.get("curvosity", 1.0))
    except (TypeError, ValueError):
        curvosity = 1.0
    placement_pos = _vec(placement.get("placementPosition"))
    custom_pos = _vec(custom.get("placementPosition"), placement_pos)
    yaw = float(placement.get("yaw", 0.0))
    custom_yaw = float(custom.get("yaw", yaw))
    curves: list[Curve] = []
    warnings: list[str] = []
    base_length = float(track_length - 1)

    def straight_curve() -> Curve:
        direction_vector = from_yaw(base_length, yaw)
        return Curve(
            (0.0, 0.0, 0.0),
            from_yaw(base_length * 0.25, yaw),
            from_yaw(base_length * 0.75, yaw),
            direction_vector,
        )

    if track_type in {"STRAIGHT", "SLOPE"}:
        curve = straight_curve()
        if track_type == "SLOPE":
            dy = custom_pos[1] - placement_pos[1]
            curve = Curve(curve.p1, curve.ctrl1, add(curve.ctrl2, (0.0, dy, 0.0)), add(curve.p2, (0.0, dy, 0.0)))
        curves = [curve.linearize(smoothing)]
    elif track_type == "TURN":
        curve = circle(max(0, track_length - 1), degrees).transformed(yaw - 90.0, mirror_z=direction == "LEFT")
        dy = custom_pos[1] - placement_pos[1]
        if dy:
            curve = Curve(curve.p1, curve.ctrl1, add(curve.ctrl2, (0.0, dy, 0.0)), add(curve.p2, (0.0, dy, 0.0)))
        curves = [curve.linearize(smoothing)]
    elif track_type == "CUSTOM":
        end = tuple(int(value) for value in from_yaw(float(track_length), yaw + 45.0))
        same_placement = custom_pos == placement_pos
        if not same_placement:
            end = tuple(custom_pos[index] - placement_pos[index] for index in range(3))
        curvature_distance = max(length(end) / 2.0, 0.1 * curvosity)
        ctrl1 = from_yaw(curvature_distance, yaw)
        ctrl2 = add(end, from_yaw(curvature_distance, yaw + 180.0 if same_placement else custom_yaw))
        preliminary = Curve((0.0, 0.0, 0.0), ctrl1, ctrl2, end).linearize(smoothing)
        placement_control = _vec(placement.get("control"), None) if placement.get("control") is not None else None
        custom_control = _vec(custom.get("control"), None) if custom.get("control") is not None else None
        if placement_control is not None:
            ctrl1 = sub(placement_control, placement_pos)
        else:
            ctrl1 = preliminary.ctrl1
        if custom_control is not None and not same_placement:
            ctrl2 = sub(custom_control, placement_pos)
        else:
            ctrl2 = preliminary.ctrl2
        curves = [Curve((0.0, 0.0, 0.0), ctrl1, ctrl2, end)]
    elif track_type == "CROSSING":
        half = max(0.0, base_length / 2.0)
        first = Curve(from_yaw(-half, yaw), from_yaw(-half / 3.0, yaw), from_yaw(half / 3.0, yaw), from_yaw(half, yaw))
        second_yaw = yaw + 90.0
        second = Curve(from_yaw(-half, second_yaw), from_yaw(-half / 3.0, second_yaw), from_yaw(half / 3.0, second_yaw), from_yaw(half, second_yaw))
        curves = [first, second]
        warnings.append("crossing lanes reconstructed as two source-compatible straight paths; verify against live BuilderCrossing")
    elif track_type == "SWITCH":
        straight = straight_curve().linearize(smoothing)
        turn = circle(max(0, track_length - 1), degrees).transformed(yaw - 90.0, mirror_z=direction == "LEFT").linearize(smoothing)
        curves = [straight, turn]
        warnings.append("switch branches reconstructed from saved settings; verify live BuilderSwitch branch placement")
    else:
        warnings.append(f"builder type {track_type} requires world-aware IR builder support")

    origin = add(tile_pos, placement_pos)
    world_curves = [curve.translated(origin) for curve in curves]
    switch_state = _enum(data.get("info", {}).get("switchState"), ("NONE", "STRAIGHT", "TURN"), "NONE")
    switch_forced = _enum(data.get("info", {}).get("switchForced"), ("NONE", "STRAIGHT", "TURN"), "NONE")
    effective_switch = switch_forced if switch_forced != "NONE" else switch_state
    metadata = {
        "track_type": track_type,
        "direction": direction,
        "smoothing": smoothing,
        "length": track_length,
        "degrees": degrees,
        "yaw": yaw,
        "placement_position": list(placement_pos),
        "custom_position": list(custom_pos),
        "track": str(settings.get("track", "default")),
        "switch_state": switch_state,
        "switch_forced": switch_forced,
        "active_curve_indices": ([0] if effective_switch == "STRAIGHT" else [1] if effective_switch == "TURN" else list(range(len(world_curves)))),
    }
    return track_type, world_curves, warnings, metadata
