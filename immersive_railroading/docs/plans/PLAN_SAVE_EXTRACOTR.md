# Implement an Offline IR Save Extractor and Geometry/Topology Builder

## Feasibility

Yes, this can be built now without the Lean proof.

The save already contains IR rail tile entities and their serialized `RailInfo`
data. Geometry can therefore be reconstructed without a tracer. Full topology is
also approachable, but must initially use conservative statuses because the save
does not contain a global route graph.

The immediate implementation should be a standalone Python 3 tool. The current
environment has Python 3.12, but no Java 8 runtime or Gradle/Maven setup. Python
can parse Anvil/NBT data and reproduce the verified IR geometry formulas directly.
A later Java/Forge adapter can provide differential validation against the live
IR classes.

## Implementation

Create a standalone tool under:

```text
immersive_railroading/tools/ir_save_extractor/
```

It must:

- read a save directory without modifying it;
- scan all dimension region files and chunks;
- parse UMC `universalmodcore:tile_track` records;
- identify IR `block_rail` and `block_rail_gag` records;
- resolve gag parents;
- preserve source coordinates, dimension, raw NBT hash, and source metadata;
- load the referenced IR/addon track-definition resources;
- emit a versioned JSON geometry artifact.

The geometry kernel must reproduce the Java-8-root behavior for:

- straight builders;
- turn builders and IR’s cubic Bézier circle approximation;
- slopes;
- custom cubic curves and control points;
- switches;
- crossings;
- gauge, direction, grade, smoothing, and placement transforms.

Every geometry record must include builder type, control points or equivalent
parameters, endpoint/tangent data, source hash, and a reconstruction status.

## GUI Front End

Provide a lightweight Python GUI using the standard-library `tkinter` toolkit.

The GUI must contain:

- a field for the source save-folder path;
- a “Browse…” button for selecting the save folder;
- a field for the extraction-output directory;
- a “Browse…” button for selecting the output directory;
- a “Validate paths” button;
- an “Extract” button;
- a read-only status/log area showing progress, warnings, counts, and failures.

Validation must require:

- the save path exists and contains `level.dat` or region data;
- the output path is writable or can be created;
- source and output paths are not the same;
- the output directory is not inside the save directory, preventing accidental
  modification of the source world;
- extraction is refused when required IR/addon resources are missing.

The GUI must invoke the same extractor core as the command-line interface rather
than duplicating parsing or geometry logic. The selected paths must be passed
explicitly to that core.

The GUI must display:

- extracted dimensions and region counts;
- number of IR parent rail records;
- number of gag records;
- number of generated spline records;
- topology status counts;
- unresolved, ambiguous, invalid, or missing-resource cases;
- the final artifact path.

The source save must remain read-only. Extraction failures must leave partial
output clearly marked as incomplete and must never be reported as a valid route
artifact.

Add GUI tests covering path validation, browse-path assignment, refusal of
invalid or overlapping paths, successful extraction invocation, and display of
`AMBIGUOUS`, `UNTRACED`, and `INVALID` results.


## Topology builder

Build topology separately from geometry.

The first version should produce explicit edge statuses:

```text
CONNECTED
DISCONNECTED
AMBIGUOUS
UNTRACED
INVALID
```

It must:

- use parent/gag metadata as authoritative component grouping;
- generate endpoint adjacency candidates using 3-D distance, tangent, gauge,
  elevation, and residual tolerances;
- preserve separate paths at crossings and overpasses;
- distinguish IR’s built-in crossing item from independent coincident tracks;
- apply saved switch state when constructing branch candidates;
- never connect segments solely because their 2-D projections intersect;
- emit `AMBIGUOUS` or `UNTRACED` instead of guessing.

The routing graph must be derived from the validated spline records and must not
modify them.

## Validation

Add tests for:

- Anvil compression and NBT parsing;
- extraction of the existing save’s IR rail records;
- parent/gag grouping;
- straight, turn, slope, custom, switch, and crossing geometry;
- known bytecode-derived control-point examples;
- endpoint matching and 3-D overpass separation;
- same-level ambiguous intersections;
- invalid or missing addon definitions;
- source-hash and artifact-version validation.

The tool must also provide a report listing every unresolved topology case.

A Java/Forge validation stage should later compare the Python output with actual
`RailInfo.getBuilder`, `TileRailBase.getNextPosition`, `MovementTrack.findTrack`,
and TrackAPI behavior on the same fixture world.

## Acceptance boundary

The extractor can be used immediately as an engineering geometry source and
visualization input once it successfully processes the target save.

It must not yet be treated as proof evidence or implementation-ready until:

- geometry output is differentially checked against the live IR classes;
- addon definitions are validated;
- topology statuses required by the active route are all `CONNECTED` or
  explicitly `DISCONNECTED`;
- no active route contains `AMBIGUOUS`, `UNTRACED`, or `INVALID` edges.

No Lean, LaTeX, production Lua, or existing plan files should be modified by this
implementation.
