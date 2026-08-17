from __future__ import annotations

import gzip
import json
import struct
import tempfile
import unittest
import zlib
from pathlib import Path

from ir_save_extractor.anvil import iter_chunks, iter_tile_records
from ir_save_extractor.extractor import ExtractionConfig, extract_save, validate_paths
from ir_save_extractor.geometry import Curve, build_curves, circle
from ir_save_extractor.nbt import TAG_COMPOUND, TAG_INT, TAG_LIST, TAG_STRING, parse_nbt
from ir_save_extractor.topology import build_topology


def _tag(tag_type: int, name: str, payload: bytes) -> bytes:
    encoded = name.encode("utf-8")
    return bytes([tag_type]) + struct.pack(">H", len(encoded)) + encoded + payload


def _compound(entries: list[bytes]) -> bytes:
    return b"".join(entries) + b"\x00"


def _string(value: str) -> bytes:
    encoded = value.encode("utf-8")
    return struct.pack(">H", len(encoded)) + encoded


def _list(item_type: int, payloads: list[bytes]) -> bytes:
    return bytes([item_type]) + struct.pack(">i", len(payloads)) + b"".join(payloads)


def _minimal_chunk() -> bytes:
    tile = _compound([
        _tag(TAG_STRING, "id", _string("universalmodcore:tile_track")),
        _tag(TAG_STRING, "instanceId", _string("immersiverailroading:block_rail")),
        _tag(TAG_INT, "x", struct.pack(">i", 4)),
        _tag(TAG_INT, "y", struct.pack(">i", 70)),
        _tag(TAG_INT, "z", struct.pack(">i", 8)),
    ])
    level = _compound([_tag(TAG_LIST, "TileEntities", _list(TAG_COMPOUND, [tile]))])
    return _tag(TAG_COMPOUND, "", _compound([_tag(TAG_COMPOUND, "Level", level)]))


class NBTAndAnvilTests(unittest.TestCase):
    def test_nbt_compound_and_list(self) -> None:
        name, root = parse_nbt(_minimal_chunk())
        self.assertEqual(name, "")
        self.assertIn("Level", root)
        self.assertEqual(root["Level"]["TileEntities"][0]["x"], 4)

    def test_anvil_reads_zlib_and_gzip_chunks(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            save = Path(directory)
            region = save / "region"
            region.mkdir()
            payloads = [zlib.compress(_minimal_chunk()), gzip.compress(_minimal_chunk())]
            data = bytearray(8192 + 4 * 4096)
            for index, payload in enumerate(payloads):
                sector = 3 + index
                record = struct.pack(">I", len(payload) + 1) + bytes([2 if index == 0 else 1]) + payload
                data[sector * 4096 : sector * 4096 + len(record)] = record
                data[index * 4 : index * 4 + 4] = struct.pack(">I", (sector << 8) | 1)
            path = region / "r.0.0.mca"
            path.write_bytes(data)
            chunks = list(iter_chunks(save))
            self.assertEqual(len(chunks), 2)
            records = list(iter_tile_records(chunks[0]))
            self.assertEqual(records[0].x, 4)


class GeometryTests(unittest.TestCase):
    def test_straight_is_source_shape(self) -> None:
        builder, curves, warnings, metadata = build_curves({"info": {"settings": {"type": "STRAIGHT", "length": 10}, "placement": {"yaw": 0, "placementPosition": {"x": 0, "y": 0, "z": 0}}}}, (0, 0, 0))
        self.assertEqual(builder, "STRAIGHT")
        self.assertEqual(curves[0].p1, (0.0, 0.0, 0.0))
        self.assertEqual(curves[0].p2, (0.0, 0.0, 9.0))
        self.assertFalse(warnings)
        self.assertEqual(metadata["length"], 10)

    def test_bezier_position_and_circle(self) -> None:
        curve = Curve((0, 0, 0), (0, 0, 1), (1, 0, 1), (1, 0, 0))
        self.assertEqual(curve.position(0), (0, 0, 0))
        self.assertEqual(curve.position(1), (1, 0, 0))
        self.assertGreater(circle(9, 90).length(), 0)

    def test_custom_control_points_are_used(self) -> None:
        data = {"info": {"settings": {"type": "CUSTOM", "length": 10, "track": "default"}, "placement": {"yaw": 0, "placementPosition": {"x": 0, "y": 0, "z": 0}, "control": {"x": 2, "y": 0, "z": 3}}, "custom": {"yaw": 0, "placementPosition": {"x": 0, "y": 0, "z": 0}}}}
        _, curves, _, _ = build_curves(data, (0, 0, 0))
        self.assertEqual(curves[0].ctrl1, (2.0, 0.0, 3.0))

    def test_switch_and_crossing_keep_separate_geometry_paths(self) -> None:
        placement = {"yaw": 0, "placementPosition": {"x": 0, "y": 0, "z": 0}}
        switch_data = {"info": {"settings": {"type": "SWITCH", "length": 10, "degrees": 30}, "placement": placement, "custom": placement}}
        crossing_data = {"info": {"settings": {"type": "CROSSING", "length": 10}, "placement": placement, "custom": placement}}
        switch_type, switch_curves, _, _ = build_curves(switch_data, (0, 0, 0))
        crossing_type, crossing_curves, warnings, _ = build_curves(crossing_data, (0, 0, 0))
        self.assertEqual(switch_type, "SWITCH")
        self.assertEqual(len(switch_curves), 2)
        self.assertEqual(crossing_type, "CROSSING")
        self.assertEqual(len(crossing_curves), 2)
        self.assertTrue(warnings)


class TopologyAndExtractionTests(unittest.TestCase):
    def test_coincident_endpoints_are_not_auto_connected(self) -> None:
        curve = Curve((0, 0, 0), (0, 0, 1), (0, 0, 2), (0, 0, 3)).as_dict()
        segments = [{"id": "a", "builder_type": "STRAIGHT", "curves": [curve]}, {"id": "b", "builder_type": "STRAIGHT", "curves": [curve]}]
        edges, counts = build_topology(segments)
        self.assertTrue(edges)
        self.assertEqual(edges[0]["status"], "AMBIGUOUS")
        self.assertEqual(counts["AMBIGUOUS"], 2)

    def test_path_validation_rejects_nested_output(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            save = Path(directory)
            (save / "level.dat").write_bytes(b"placeholder")
            self.assertTrue(validate_paths(save, save / "output"))

    def test_extraction_writes_incomplete_report_for_empty_save(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            save, output = Path(directory) / "save", Path(directory) / "output"
            save.mkdir()
            (save / "level.dat").write_bytes(b"not parsed here")
            result = extract_save(ExtractionConfig(save, output))
            self.assertTrue(result.artifact_path.is_file())
            artifact = json.loads(result.artifact_path.read_text())
            self.assertFalse(artifact["complete"])


if __name__ == "__main__":
    unittest.main()
