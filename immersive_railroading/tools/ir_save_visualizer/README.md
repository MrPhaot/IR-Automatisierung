# IR Geometry Visualizer

This is a read-only viewer for `ir-save-extractor/v1` JSON artifacts. It keeps
the extractor and the visualizer separate: the viewer never reads or writes the
Minecraft save, and it never rewrites the JSON artifact.

## Start

From the repository root:

```bash
./immersive_railroading/tools/run_ir_save_visualizer.py
```

The GUI opens a file chooser. An artifact can also be supplied directly:

```bash
./immersive_railroading/tools/run_ir_save_visualizer.py \
  /path/to/ir-geometry-topology.json
```

For point-heavy saves, display sampling and picking can be adjusted:

```bash
./immersive_railroading/tools/run_ir_save_visualizer.py artifact.json \
  --samples 32 --pick-tolerance 10
```

The only runtime dependencies are Python 3, Tkinter, and Matplotlib. The
launcher places Matplotlib configuration in the system temporary directory.

## Coordinate and object model

Coordinates are rendered as the original Minecraft world `(X, Y, Z)` values;
the axes are labelled `Minecraft X`, `Minecraft Y`, and `Minecraft Z`. View
centering, equal aspect scaling, camera movement, and curve display sampling
are visual-only and do not alter coordinates shown in the metadata panel.

The current adapter produces separate selectable objects for parent points, gag
points, curve controls/endpoints, sampled curves, and topology records. Raw
source records are retained in each object’s metadata. A missing curve list is
valid and produces a point-only view. Incomplete artifacts are displayed with
an `INCOMPLETE` title and their warnings remain visible.

## Picking

Clicking the 3-D plot uses projected screen-space picking. Every object within
the configured pixel tolerance is shown in the candidate list. Overlapping or
depth-ambiguous objects are not silently merged or discarded; selecting a
candidate displays its exact coordinates, source IDs, status, control points,
resource/hash information, and preserved source metadata.

## Extending artifact support

`loader.py` dispatches by the artifact `format` field. To support a future
format, add an adapter implementing `load(payload, sample_count=...)` and
register it in `ADAPTERS`. Convert it into `SceneDocument` and `SceneObject`
records rather than adding format-specific logic to the renderer or picker.
Unknown root and record fields must continue to be preserved.

The GUI needs a desktop display. Model, loader, scene, and picking tests can
run headlessly with Matplotlib’s `Agg` backend.
