# Geometry and topology investigation

Status: evidence report, not a proof-readiness declaration.

This report records what can be established from the Immersive Railroading
1.11.0 Minecraft 1.7.10 Java-8 root classes, what can be computed by a sound
tracer/mapper, and what remains unavailable without a world adapter, repeated
runs, or human classification. The authoritative jar selection and hashes are
recorded in [pid-jar-manifest.md](pid-jar-manifest.md). The current Lean
interfaces examined here are in `pid-proof-lean/IRRevision.lean`.

## 1. Evidence boundary and classifications

The report uses the following classifications.

| Classification | Meaning |
|---|---|
| `BYTECODE_DERIVED` | Directly established by the selected root Java-8 bytecode. |
| `DEFINITION_DERIVED` | Read from an IR track/stock definition or its parsed fields. |
| `CONFIG_DERIVED` | Read from an IR configuration value. |
| `GEOMETRY_COMPUTED` | Computed from ordered observations using a declared algorithm and error certificate. |
| `RUNTIME_CERTIFIED` | Established by an adapter contract or runtime validation with a numeric bound. |
| `OPERATIONAL_EXCLUSION` | Deliberately outside the supported route, with detection and fail-closed behavior. |
| `UNAVAILABLE/NOT_READY` | Not established by the available source or observations. |

The mapper must not turn an observation supplied by its caller into a
`BYTECODE_DERIVED` fact. In particular, an input field named `knownConnection`,
`sameLevel`, or `fittingError` is a certificate input until a producer proves
how it was obtained.

## 2. IR geometry primitives

### 2.1 Cubic curves

`cam72cam.immersiverailroading.track.CubicCurve` stores four 3-D points:
`p1`, `ctrl1`, `ctrl2`, and `p2`. Its `position(t)` is the standard cubic
Bézier polynomial

```text
B(t) = (1-t)^3 p1
     + 3(1-t)^2 t ctrl1
     + 3(1-t)t^2 ctrl2
     + t^3 p2,       0 <= t <= 1.
```

Its `derivative(t)` is

```text
B'(t) = 3(1-t)^2(ctrl1-p1)
      + 6(1-t)t(ctrl2-ctrl1)
      + 3t^2(p2-ctrl2).
```

These formulas are `BYTECODE_DERIVED` from `CubicCurve.position` and
`CubicCurve.derivative`. `truncate`, `split`, `reverse`, `subsplit`, and
`linearize` operate on the Bézier control polygon. They are source operations,
not curve-fitting algorithms.

`lengthWithCache` and `lengthInBetween` numerically approximate arc length by
sampling/trapezoidal accumulation. They must therefore carry a numerical length
error; they are not an exact symbolic arc-length implementation.

`CubicCurve.circle(int radius, float angle)` constructs a cubic Bézier using the
constant `0.55191502449`, rotates it, and translates it. It is consequently an
IR-compatible cubic approximation of a circular segment, not an exact circle.
A proof must not silently replace that source geometry by an exact circle.

### 2.2 Track builders and metadata

The root classes establish the following source-side geometry paths.

| Source item | Established fact | Classification |
|---|---|---|
| `BuilderStraight` | Constructs straight track geometry. | `BYTECODE_DERIVED` |
| `BuilderTurn` | Constructs turn geometry, including curved track settings. | `BYTECODE_DERIVED` |
| `BuilderSlope` | Constructs sloped track geometry. | `BYTECODE_DERIVED` |
| `BuilderSwitch` | Has distinct switch/straight branch semantics. | `BYTECODE_DERIVED` |
| `BuilderCrossing` | Is a distinct crossing track item/builder. | `BYTECODE_DERIVED` |
| `BuilderCubicCurve` | Exposes a cubic-curve builder path. | `BYTECODE_DERIVED` |
| `RailInfo` | Stores settings, builders, placement/custom data, switch state, and identifiers. | `BYTECODE_DERIVED` |
| `RailSettings` | Stores gauge/type/length/degrees/curvosity/position/direction/grade-related settings. | `BYTECODE_DERIVED` |
| `TileRail`/`TileRailBase` | Stores parent tile, augment, switch, and track metadata and exposes next-position traversal. | `BYTECODE_DERIVED` |

The mapper may use these values when a world/block adapter reads the corresponding
track tile. A tracer alone does not observe them. A `RailInfo` identifier is a
source identifier for an object; it is not, by itself, a complete graph relation
between every reachable branch.

`MovementTrack.findTrack` probes a position using lateral/vertical offsets and
gauge checks. `MovementTrack.iterativePathing` repeatedly uses
`TileRailBase.getNextPositionShort` or `ITrack.getNextPosition`. This is a
runtime traversal algorithm, not a public complete-topology enumeration API.

## 3. Tracer position and track-centre error

The intended data roles must remain separate:

1. tracer samples reconstruct track geometry;
2. the front coupler is used only for stopping/terminal localization.

The root OpenComputers path is:

```text
RadioCtrlCardManager.getPos
 -> CommonAPI.getPosition
 -> EntityRollingStock.getPosition
```

The manager returns the three coordinates of that position. The jar proves the
call path and returned coordinate values, but it does not prove that the entity
position is exactly the rail centreline at every orientation, on every stock,
or for every addon. The following are therefore separate obligations:

| Quantity | Status | Required treatment |
|---|---|---|
| API position is the entity position | `BYTECODE_DERIVED` | Cite `CommonAPI.getPosition` and `EntityRollingStock.getPosition`. |
| Entity position equals the desired track-centre point | `UNAVAILABLE/NOT_READY` from jar alone | Establish through entity geometry/source mapping or runtime certificate. |
| Lateral offset from centreline | `RUNTIME_CERTIFIED` | Bound it for the selected compact tracer locomotive; do not assume zero. |
| Vertical offset from rail reference | `RUNTIME_CERTIFIED` | Bound it separately from lateral error. |
| Coordinate rounding/serialization error | `RUNTIME_CERTIFIED` | Measure or bound at the API boundary. |
| Sample spacing and age | `RUNTIME_CERTIFIED` | Record per sample and propagate into the reconstruction envelope. |
| Front-coupler position | `DEFINITION_DERIVED` + `GEOMETRY_COMPUTED` | Use stock/gauge coupler offset and orientation; do not use tracer-centre samples as a substitute. |

A compact locomotive reduces body-offset and curvature-span effects, but it does
not establish exact centreline coincidence. The required certificate is of the
form

```text
distance(trackCentre(sample), getPos(sample))
 <= lateralBound + verticalBound + APIError.
```

If the certificate cannot be obtained for a stock or addon, that stock is not
covered. The mapper must report `NOT_READY` rather than silently assigning a
zero offset.

## 4. Sound curve reconstruction

### 4.1 Ordered samples and frames

Each sample must contain at least:

```text
traceId, tick/time, position, stock/definition ID,
coordinate frame, orientation or tangent evidence,
sample spacing, sample age, and raw numeric error bounds.
```

The trace coordinate frame must be explicitly anchored to Minecraft world
coordinates. A directed trace order is not an unordered point cloud. Repeated
runs may append samples and may reveal previously untraversed branches.

For adjacent samples `p_i`, `p_(i+1)`, use a bounded finite-difference tangent.
For a candidate cubic, use `B'(t)` and a declared parameter-to-sample matching
algorithm. Curvature is computed from the first and second derivatives with an
interval or conservative numerical bound; no exact curvature claim is valid
without a residual and conditioning analysis.

### 4.2 Segmentation and fitting

The mapper may use the following staged algorithm:

1. detect a maximal straight candidate using bounded point-to-line residual,
   tangent change, and a minimum sample count;
2. when the residual exceeds the straight certificate, close the straight
   segment before the first unassigned point;
3. classify a turn only when its fitted IR-compatible cubic/turn model has a
   bounded residual and sufficient tangent/curvature support;
4. use adaptive sampling where curvature or residual changes rapidly;
5. preserve shared endpoints and carry one-sided tangent bounds at segment joins;
6. treat a segment with inadequate samples or inconsistent residuals as
   unresolved rather than forcing a line or Bézier label.

The fit certificate must state:

```text
for every accepted sample p_i, there exists t_i in [0,1] such that
||p_i - B(t_i)|| <= fitError + observationError_i.
```

It must also state parameter monotonicity/order, endpoint error, tangent error,
and the numerical error of length and curvature calculations. A fitted cubic is
not automatically an IR track section: an IR builder witness or a separately
validated compatibility certificate is required.

### 4.3 What point samples cannot determine

Point samples alone cannot always distinguish:

- a connected switch from a geometrically coincident but separate track;
- a merger from a continuation whose curves overlap;
- an overpass/crossing when the relevant vertical separation is below the
  observation error;
- two different Bézier control polygons with the same finite samples;
- a missing branch that was never traversed.

These are mathematical non-identifiability results, not merely implementation
inconveniences. A source/world adapter, additional runs, or manual classification
is required for such cases.

## 5. Incremental spline reconstruction

The spline model and routing graph must not be conflated.

### 5.1 Spline model

The spline model is authoritative for:

- 3-D track geometry;
- segment endpoints and intervals;
- tangent, grade, curvature, and fitting envelopes;
- source track identifiers and trace provenance;
- confirmed split/merge/overlap relationships.

When a new trace arrives, the mapper must attempt, in order:

1. confirmation of an existing interval;
2. extension of an existing interval;
3. source-supported split at a certified junction;
4. insertion of a separate segment;
5. unresolved status.

Appending a new candidate solely because its stable ID is unique is not a sound
merge algorithm. The current `reconstructionCommit` only appends a routable
candidate or leaves the store unchanged; it does not prove extension, splitting,
overlap, or geometric compatibility.

Every accepted operation must compare 3-D residuals, tangent/curvature bounds,
gauge, elevation, interval overlap, source IDs, and endpoint tolerances. Two
segments must not be merged merely because their 2-D projections meet.

### 5.2 Multiple runs

A subsequent run may connect newly observed splines to the existing spline model.
The connection must be a certified relation to existing geometry, not an
assumption based on trace order alone. An untraversed switch branch remains
unknown until a later run or a source/world query supplies evidence.

## 6. Intersection and topology classification

The classification order must be based on evidence, not on a caller-provided
Boolean.

1. Use source/block metadata when available: track parent, `RailInfo`, track item,
   switch state, branch identity, gauge, and elevation.
2. Use certified 3-D geometry, tangent continuity, interval overlap, and endpoint
   relationships.
3. Identify an ordinary continuation when one certified spline continues through
   the geometric location without a branch/connectivity relation.
4. Identify a connected switch/merger only with a source/world connection witness
   or a player classification after all automatic tests remain ambiguous.
5. Identify an isolated crossing/overpass when the geometry intersects but no
   connection witness exists and the 3-D separation certificate supports it.
6. If the evidence is insufficient, classify as unresolved and do not create a
   routable graph edge.

An ordinary continuation is not the same as a crossing: it is a single connected
track interval that passes through the location without joining another path. A
crossing is a geometric intersection of separate paths. A built-in IR
`BuilderCrossing` must be handled as its own source track type. A player-built
overpass made by placing one track above another may have no shared IR connection
even if its projections intersect.

Automatic classification is required whenever the available 3-D/source evidence
is sufficient. Human classification is allowed only for genuinely indistinguish-
able connectivity semantics. Until classification is supplied, the result is
`UNAVAILABLE/NOT_READY` and unroutable.

The current Lean `TopologyObservation`/`classifyTopology` pair checks supplied
distances and flags. Its fail-closed classes are useful, but a later proof must
connect each field to a producer: geometric computation, source tile query, or
explicit human certificate. It must not treat arbitrary `knownConnection` or
`sameLevel` values as proof evidence.

## 7. Routing graph derived from splines

The graph is a routing projection of the certified spline model, not the
geometry store.

- Create vertices from certified spline endpoints and certified junctions.
- Add ordinary spline edges in both orientations.
- Add station/signal markers by nearest-spline mapping only when the 3-D distance
  is within the declared marker tolerance and the projected coordinate is in the
  spline interval.
- Apply the station/signal approach orientation to the relevant graph edge;
  marker direction does not alter the underlying spline geometry.
- Preserve isolated crossings and overpasses as separate non-connecting paths.
- Validate only the edges and vertices of the active route at runtime. If one
  changes, invalidate the route and invoke normal route finding; do not scan the
  entire graph for every train update.

The current `graphNetworkProducer` proves only that graph edges came from
caller-supplied candidates accepted by `validatedSplineProducer`. It does not
derive adjacency, junctions, marker placement, or route-change certificates.
The current `MarkerObservation`/`directedMarkerProducer` validates a supplied
coordinate and distance; it does not calculate the closest spline from a marker’s
world position.

## 8. Lean gap inventory

The following existing structures are useful scaffolding but are not yet complete
source-faithful producers.

| Lean location | Good property | Missing property |
|---|---|---|
| `TraceObservation` | Carries error, spacing, age, curvature, and source identity fields. | Does not derive centreline position or those bounds from the API/source. |
| `traceCentre`/`traceResidualBound` | Makes error propagation explicit. | Uses caller-supplied offset and bounds. |
| `SplineCandidate` | Records curve, marks, samples, error, traces, and builder provenance. | Does not prove the candidate was fitted or matches an IR builder. |
| `validatedSplineProducer` | Rejects malformed candidates and combines fit/observation error. | Validates a supplied curve; it does not produce one. |
| `TopologyObservation` | Separates continuation, split, crossing, overpass, and unresolved classes. | Its distances/flags are unconstrained observations. |
| `reconstructionCommit` | Leaves unresolved and isolated-crossing candidates unroutable. | Does not implement sound extension, split, overlap, or merge. |
| `graphNetworkProducer` | Consumes only candidates accepted by the current validator. | Does not derive graph connectivity from spline geometry/source evidence. |
| `MarkerObservation` | Carries approach orientation and tolerance. | Marker coordinate and nearest spline are supplied rather than mapped. |
| `frontCouplerLocalizationProducer` | Separates front-coupler stopping localization from trace geometry. | Centre coordinate, error, and coupler geometry are supplied. |

The report therefore does not support a claim that current Lean reconstruction is
complete. It supports only a conditional architecture: if the required producers
and certificates are added, the funnel can be represented without conflating
geometry and routing.

## 9. Feasibility result

### Feasible with source/algorithmic work

- Exact reproduction of IR cubic evaluation, derivative, splitting, reversal, and
  numerical length semantics.
- Ordered tracer collection and repeated-run incremental reconstruction.
- Conservative line/Bézier segmentation with explicit residual envelopes.
- A separate spline model and graph projection.
- Automatic separation of clearly distinct 3-D paths and source-identified
  switches/crossings.
- Directed station/signal routing markers.

### Requires runtime certification or an additional adapter

- Entity position to track-centre error.
- Exact front-coupler localization for the selected stock/addon.
- Current track tile metadata, switch state, and branch connectivity.
- Addon geometry/definition compatibility.
- Numeric bounds on sampling, rounding, missing samples, and route changes.

### Fundamentally questionable from tracer points alone

- Unique control-point recovery from finite noisy samples.
- Connectivity classification for geometrically indistinguishable paths.
- Discovery of untraversed branches in one run.

For each such case, the only sound outcomes are a source/world witness, a later
trace, an explicit player certificate, or `NOT_READY`.

## 10. Verification commands and acceptance checks

The evidence was checked against the extracted root classes using commands of the
following form:

```bash
javap -classpath /tmp/ir-jar-audit.IykqtX -p -c cam72cam.immersiverailroading.track.CubicCurve
javap -classpath /tmp/ir-jar-audit.IykqtX -p -c cam72cam.immersiverailroading.track.BuilderSwitch
javap -classpath /tmp/ir-jar-audit.IykqtX -p -c cam72cam.immersiverailroading.track.BuilderCrossing
javap -classpath /tmp/ir-jar-audit.IykqtX -p -c cam72cam.immersiverailroading.util.RailInfo
```

Before accepting a future geometry proof, verify:

- every accepted sample has a producer and numeric error bound;
- every fitted segment has parameter order, residual, endpoint, tangent, and
  length certificates;
- every topology field has source, geometry, or human-certificate provenance;
- unresolved/isolated-crossing/overpass cases create no routable connection;
- subsequent traces can extend/split/confirm rather than merely append;
- marker mapping and active-route change detection are tested;
- addon stock and compact-tracer assumptions are separately checked;
- no theorem or report calls a caller-supplied flag bytecode-derived.

Until these checks pass, geometry/topology is a conditional implementation input,
not a completed proof funnel.
