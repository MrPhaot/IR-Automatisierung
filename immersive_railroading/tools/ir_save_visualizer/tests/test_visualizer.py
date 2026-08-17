from __future__ import annotations

import json
import os
import tempfile
import unittest
from pathlib import Path

os.environ.setdefault("MPLCONFIGDIR", tempfile.mkdtemp(prefix="ir-visualizer-mpl-"))

from ir_save_visualizer.loader import ArtifactError, load_artifact
from ir_save_visualizer.picking import pick_candidates
from ir_save_visualizer.scene import build_scene_document, sample_cubic


def payload(*, curves: bool = True, complete: bool = False) -> dict:
    parent = {
        "id": "overworld:0,70,0",
        "dimension": "overworld",
        "position": [0, 70, 0],
        "builder_type": "STRAIGHT",
        "geometry_status": "RECONSTRUCTED",
        "source_nbt_sha256": "parent-hash",
        "metadata": {"track": "demo", "gauge": 0.9144},
        "curves": [{
            "p1": [0, 70, 0],
            "ctrl1": [0, 70, 1],
            "ctrl2": [0, 70, 2],
            "p2": [0, 70, 3],
            "length_approximation": 3,
        }] if curves else [],
        "future_field": {"kept": True},
    }
    return {
        "format": "ir-save-extractor/v1",
        "complete": complete,
        "source": {"save_path": "/save"},
        "stats": {"parents": 1, "gags": 1},
        "dimensions": ["overworld"],
        "parents": [parent],
        "gags": [{"id": "overworld:1,70,0", "dimension": "overworld", "position": [1, 70, 0], "raw_instance_data": {"x": 1}}],
        "topology": [{"kind": "endpoint", "status": "UNTRACED", "position": [0, 70, 3], "reason": "test"}],
        "warnings": ["test warning"],
        "future_root_field": "preserved",
    }


class VisualizerModelTests(unittest.TestCase):
    def test_point_only_artifact_is_supported(self) -> None:
        document = build_scene_document(payload(curves=False))
        kinds = {item.kind for item in document.objects}
        self.assertIn("parent_point", kinds)
        self.assertIn("gag_point", kinds)
        self.assertNotIn("curve", kinds)
        self.assertEqual(document.bounds, ((0.0, 70.0, 0.0), (1.0, 70.0, 3.0)))

    def test_curve_controls_and_sampled_world_coordinates_are_retained(self) -> None:
        document = build_scene_document(payload())
        curve = next(item for item in document.objects if item.kind == "curve")
        self.assertEqual(curve.positions[0], (0.0, 70.0, 0.0))
        self.assertEqual(curve.positions[-1], (0.0, 70.0, 3.0))
        self.assertEqual(curve.polylines[0][0], curve.positions[0])
        self.assertEqual(curve.polylines[0][-1], curve.positions[-1])
        self.assertEqual(curve.metadata["source_record"]["future_field"], {"kept": True})

    def test_root_unknown_fields_and_incomplete_status_are_preserved(self) -> None:
        document = build_scene_document(payload())
        self.assertFalse(document.complete)
        self.assertEqual(document.extra["future_root_field"], "preserved")
        self.assertEqual(document.warnings, ("test warning",))

    def test_topology_endpoint_is_separate_from_geometry(self) -> None:
        document = build_scene_document(payload(curves=False))
        topology = next(item for item in document.objects if item.kind == "topology_endpoint")
        self.assertEqual(topology.status, "UNTRACED")
        self.assertEqual(topology.positions, ((0.0, 70.0, 3.0),))

    def test_cubic_sampling_preserves_endpoints(self) -> None:
        controls = ((0.0, 70.0, 0.0), (0.0, 70.0, 1.0), (1.0, 70.0, 2.0), (3.0, 70.0, 3.0))
        sampled = sample_cubic(controls, 5)
        self.assertEqual(sampled[0], controls[0])
        self.assertEqual(sampled[-1], controls[-1])
        self.assertTrue(all(point[1] == 70.0 for point in sampled))


class LoaderAndPickingTests(unittest.TestCase):
    def test_loader_reads_json_and_rejects_unknown_format(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "artifact.json"
            path.write_text(json.dumps(payload()), encoding="utf-8")
            self.assertEqual(load_artifact(path).format, "ir-save-extractor/v1")
            path.write_text(json.dumps({"format": "future/v2"}), encoding="utf-8")
            with self.assertRaises(ArtifactError):
                load_artifact(path)

    def test_picking_returns_point_and_curve_candidates(self) -> None:
        document = build_scene_document(payload())
        visible = document.objects_for({"parent_point", "curve"})

        def project(point: tuple[float, float, float]) -> tuple[float, float, float]:
            return point[0] * 10, point[2] * 10, point[1]

        candidates = pick_candidates(visible, 0, 0, project, tolerance_pixels=1)
        self.assertEqual({item.object.kind for item in candidates}, {"parent_point", "curve"})

    def test_picking_does_not_return_outside_tolerance(self) -> None:
        document = build_scene_document(payload(curves=False))
        point = next(item for item in document.objects if item.kind == "parent_point")
        candidates = pick_candidates((point,), 100, 100, lambda value: (value[0], value[2], value[1]), tolerance_pixels=1)
        self.assertEqual(candidates, ())

    def test_headless_3d_view_renders_with_legend(self) -> None:
        import matplotlib

        matplotlib.use("Agg")
        from matplotlib.figure import Figure

        from ir_save_visualizer.view import SceneView

        document = build_scene_document(payload())
        figure = Figure()
        view = SceneView(figure)
        view.render(document)
        self.assertTrue(view.axes.get_legend())
        descriptor, name = tempfile.mkstemp(suffix=".png")
        os.close(descriptor)
        output = Path(name)
        try:
            figure.savefig(output)
            self.assertGreater(output.stat().st_size, 0)
        finally:
            output.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()
