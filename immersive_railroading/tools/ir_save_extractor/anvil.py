"""Read-only Anvil region/chunk traversal for Minecraft 1.7.10 saves."""

from __future__ import annotations

import gzip
import re
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable, Iterator

from .nbt import NBTError, parse_nbt


class AnvilError(ValueError):
    """Raised when a region file cannot be safely read."""


@dataclass(frozen=True)
class Chunk:
    dimension: str
    region_path: str
    region_x: int
    region_z: int
    local_x: int
    local_z: int
    chunk_x: int
    chunk_z: int
    root_name: str
    root: dict[str, Any]


@dataclass(frozen=True)
class TileRecord:
    dimension: str
    chunk_x: int
    chunk_z: int
    x: int
    y: int
    z: int
    tile: dict[str, Any]
    instance_data: dict[str, Any]

    @property
    def instance_id(self) -> str:
        value = self.tile.get("instanceId", "")
        return str(value)


_REGION_NAME = re.compile(r"^r\.(-?\d+)\.(-?\d+)\.mca$")


def _dimension_name(save_root: Path, region_dir: Path) -> str:
    relative = region_dir.parent.relative_to(save_root)
    if str(relative) in ("", "."):
        return "overworld"
    return str(relative).replace("\\", "/")


def iter_region_dirs(save_root: Path) -> Iterator[tuple[str, Path]]:
    """Yield each dimension's region directory once."""

    seen: set[Path] = set()
    for region_dir in save_root.rglob("region"):
        if not region_dir.is_dir() or region_dir in seen:
            continue
        seen.add(region_dir)
        yield _dimension_name(save_root, region_dir), region_dir


def _chunk_payload(region_data: bytes, sector_offset: int, sector_count: int) -> bytes:
    start = sector_offset * 4096
    end = start + sector_count * 4096
    if start < 8192 or end > len(region_data):
        raise AnvilError("chunk sector range lies outside region file")
    if start + 5 > end:
        raise AnvilError("chunk record is shorter than its header")
    length = struct.unpack(">I", region_data[start : start + 4])[0]
    compression = region_data[start + 4]
    if length < 1 or length > sector_count * 4096 - 4:
        raise AnvilError(f"invalid chunk payload length: {length}")
    payload = region_data[start + 5 : start + 4 + length]
    if compression == 1:
        return gzip.decompress(payload)
    if compression == 2:
        return zlib.decompress(payload)
    if compression == 3:
        return payload
    raise AnvilError(f"unsupported Anvil compression type: {compression}")


def iter_chunks(
    save_root: Path,
    *,
    progress: Callable[[str], None] | None = None,
) -> Iterator[Chunk]:
    for dimension, region_dir in iter_region_dirs(save_root):
        for region_path in sorted(region_dir.glob("r.*.*.mca")):
            match = _REGION_NAME.match(region_path.name)
            if not match:
                continue
            region_x, region_z = int(match.group(1)), int(match.group(2))
            data = region_path.read_bytes()
            if len(data) < 8192:
                raise AnvilError(f"region header is incomplete: {region_path}")
            for index in range(1024):
                location = struct.unpack(">I", data[index * 4 : index * 4 + 4])[0]
                sector_offset, sector_count = location >> 8, location & 0xFF
                if not sector_offset or not sector_count:
                    continue
                local_x, local_z = index % 32, index // 32
                try:
                    payload = _chunk_payload(data, sector_offset, sector_count)
                    root_name, root = parse_nbt(payload)
                    if not isinstance(root, dict):
                        raise AnvilError("chunk root is not a compound")
                except (AnvilError, NBTError, OSError, zlib.error, gzip.BadGzipFile) as exc:
                    if progress:
                        progress(f"warning: skipped {region_path.name} chunk {local_x},{local_z}: {exc}")
                    continue
                if progress:
                    progress(f"read {dimension} chunk {region_x * 32 + local_x},{region_z * 32 + local_z}")
                yield Chunk(
                    dimension=dimension,
                    region_path=str(region_path),
                    region_x=region_x,
                    region_z=region_z,
                    local_x=local_x,
                    local_z=local_z,
                    chunk_x=region_x * 32 + local_x,
                    chunk_z=region_z * 32 + local_z,
                    root_name=root_name,
                    root=root,
                )


def _level(chunk: Chunk) -> dict[str, Any]:
    level = chunk.root.get("Level", chunk.root)
    return level if isinstance(level, dict) else {}


def iter_tile_records(chunk: Chunk) -> Iterator[TileRecord]:
    level = _level(chunk)
    tiles = level.get("TileEntities", [])
    if not isinstance(tiles, list):
        return
    for tile in tiles:
        if not isinstance(tile, dict):
            continue
        instance_id = str(tile.get("instanceId", ""))
        if tile.get("id") != "universalmodcore:tile_track":
            continue
        if not instance_id.startswith("immersiverailroading:"):
            continue
        data = tile.get("instanceData", {})
        if not isinstance(data, dict):
            data = {}
        try:
            x, y, z = int(tile["x"]), int(tile["y"]), int(tile["z"])
        except (KeyError, TypeError, ValueError):
            continue
        yield TileRecord(chunk.dimension, chunk.chunk_x, chunk.chunk_z, x, y, z, tile, data)
