"""Extraction orchestration and artifact generation."""

from __future__ import annotations

import hashlib
import json
import os
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable

from .anvil import TileRecord, iter_chunks, iter_tile_records
from .geometry import build_curves
from .nbt import json_safe
from .resources import ResourceCatalog
from .topology import build_topology


Progress = Callable[[str], None]


class MissingResourceError(RuntimeError):
    """Raised after an incomplete artifact has been written."""


@dataclass
class ExtractionConfig:
    save_path: Path
    output_path: Path
    resource_roots: tuple[Path, ...] = ()
    distance_tolerance: float = 0.25
    tangent_tolerance: float = 0.35


@dataclass
class ExtractionResult:
    artifact_path: Path
    report_path: Path
    artifact: dict[str, Any]


def validate_paths(save_path: Path, output_path: Path) -> list[str]:
    errors: list[str] = []
    save = save_path.expanduser().resolve()
    output = output_path.expanduser().resolve()
    if not save.is_dir():
        errors.append(f"save path is not a directory: {save}")
    elif not (save / "level.dat").is_file() and not any(save.rglob("region/*.mca")):
        errors.append("save path contains neither level.dat nor region/*.mca")
    if save == output:
        errors.append("output directory must not equal save directory")
    try:
        output.relative_to(save)
    except ValueError:
        pass
    else:
        errors.append("output directory must not be inside the save directory")
    if output.exists() and not output.is_dir():
        errors.append(f"output path is not a directory: {output}")
    else:
        probe = output
        while not probe.exists() and probe != probe.parent:
            probe = probe.parent
        if not os.access(probe, os.W_OK):
            errors.append(f"output path is not writable or cannot be created: {output}")
    return errors


def _canonical_hash(value: Any) -> str:
    raw = json.dumps(json_safe(value), sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def _tile_id(record: TileRecord) -> str:
    return f"{record.dimension}:{record.x},{record.y},{record.z}"


def _parent_key(record: TileRecord) -> tuple[str, int, int, int] | None:
    parent = record.instance_data.get("parent")
    if not isinstance(parent, dict):
        return None
    try:
        px = int(parent.get("X", parent.get("x")))
        py = int(parent.get("Y", parent.get("y")))
        pz = int(parent.get("Z", parent.get("z")))
    except (TypeError, ValueError):
        return None
    return record.dimension, record.x + px, record.y + py, record.z + pz


def extract_save(config: ExtractionConfig, progress: Progress | None = None) -> ExtractionResult:
    save = config.save_path.expanduser().resolve()
    output = config.output_path.expanduser().resolve()
    errors = validate_paths(save, output)
    if errors:
        raise ValueError("; ".join(errors))
    output.mkdir(parents=True, exist_ok=True)
    started = time.time()
    log = progress or (lambda _message: None)
    catalog_roots = list(config.resource_roots)
    project_root = Path(__file__).resolve().parents[2]
    bundled = project_root / ".cache" / "jar"
    if bundled.is_dir() and bundled not in catalog_roots:
        catalog_roots.append(bundled)
    catalog = ResourceCatalog(catalog_roots)
    parents: list[dict[str, Any]] = []
    gags: list[dict[str, Any]] = []
    warnings: list[str] = []
    dimensions: set[str] = set()
    region_files: set[str] = set()
    chunks_read = 0

    for chunk in iter_chunks(save, progress=log):
        chunks_read += 1
        dimensions.add(chunk.dimension)
        region_files.add(chunk.region_path)
        for record in iter_tile_records(chunk):
            raw_hash = _canonical_hash(record.tile)
            item = {
                "id": _tile_id(record),
                "dimension": record.dimension,
                "position": [record.x, record.y, record.z],
                "instance_id": record.instance_id,
                "source_nbt_sha256": raw_hash,
                "parent": list(_parent_key(record)[1:]) if _parent_key(record) else None,
                "raw_instance_data": json_safe(record.instance_data),
            }
            if record.instance_id.endswith(":block_rail_gag"):
                gags.append(item)
                continue
            if record.instance_id.endswith(":block_rail"):
                settings = record.instance_data.get("info", {}).get("settings", {})
                track_id = settings.get("track", "default") if isinstance(settings, dict) else "default"
                resource = catalog.find_track(str(track_id))
                tile_pos = (float(record.x), float(record.y), float(record.z))
                builder_type, curves, geometry_warnings, metadata = build_curves(record.instance_data, tile_pos)
                metadata["gauge"] = settings.get("gauge") if isinstance(settings, dict) else None
                item.update({
                    "builder_type": builder_type,
                    "curves": [curve.as_dict() for curve in curves],
                    "metadata": metadata,
                    "geometry_status": "RECONSTRUCTED" if curves else "INVALID",
                    "resource": ({"source": resource.source, "metadata": resource.metadata} if resource else None),
                })
                if resource is None:
                    item["geometry_status"] = "INVALID"
                    warning = f"{item['id']}: missing track resource {track_id}"
                    warnings.append(warning)
                    log(f"warning: {warning}")
                for warning in geometry_warnings:
                    warnings.append(f"{item['id']}: {warning}")
                parents.append(item)

    topology, topology_counts = build_topology(parents, distance_tolerance=config.distance_tolerance, tangent_tolerance=config.tangent_tolerance)
    status_counts = {"RECONSTRUCTED": sum(item.get("geometry_status") == "RECONSTRUCTED" for item in parents), "INVALID": sum(item.get("geometry_status") == "INVALID" for item in parents)}
    complete = bool(parents) and not warnings and status_counts["INVALID"] == 0 and topology_counts["AMBIGUOUS"] == 0 and topology_counts["UNTRACED"] == 0 and topology_counts["INVALID"] == 0
    artifact = {
        "format": "ir-save-extractor/v1",
        "complete": complete,
        "created_unix": time.time(),
        "source": {"save_path": str(save), "level_dat_present": (save / "level.dat").is_file()},
        "geometry_authority": "IR RailInfo parameters reconstructed from Anvil/UMC tile NBT",
        "dimensions": sorted(dimensions),
        "stats": {"chunks_read": chunks_read, "region_files": len(region_files), "parents": len(parents), "gags": len(gags), "geometry": status_counts, "topology": topology_counts},
        "parents": parents,
        "gags": gags,
        "topology": topology,
        "warnings": warnings,
        "limitations": [
            "TrackAPI/global world connectivity is not serialized as a graph.",
            "AMBIGUOUS topology is never promoted to CONNECTED by geometry alone.",
            "Geometry must be differentially checked against live IR builders before proof use.",
        ],
    }
    artifact_path = output / "ir-geometry-topology.json"
    report_path = output / "ir-extraction-report.json"
    artifact_path.write_text(json.dumps(artifact, indent=2, sort_keys=True, ensure_ascii=True) + "\n", encoding="utf-8")
    report_path.write_text(json.dumps({"complete": complete, "stats": artifact["stats"], "warnings": warnings, "artifact": str(artifact_path)}, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    log(f"wrote {artifact_path}")
    log(f"finished in {time.time() - started:.2f}s; complete={complete}")
    if any(item.get("resource") is None for item in parents):
        raise MissingResourceError("one or more referenced IR/addon track resources are missing; see the incomplete report")
    return ExtractionResult(artifact_path, report_path, artifact)
