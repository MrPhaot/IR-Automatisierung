# Reproducible geometry, physics, controller, timing, and arrival vectors

The normative executable vectors are in
`pid-proof-lean/IRRevisionTestVectors.lean`. They use exact `Rat` values and
test producer/consumer boundaries; they are not a claim that Java floating
point or live Lua timing is exact.

Run from `immersive_railroading/docs/plans/pid-proof-lean/`:

```bash
lake build
lake env lean IRRevisionTestVectors.lean
lake env lean Axioms.lean
```

## Geometry and reconstruction

### G1 — tracer centre and fit

The compact tracer has raw position `(0,0,0)`, reference offset `(1,0,0)`,
sampling spacing `1`, curvature bound `1`, floating error `1/10`, missing
observation bound `1/10`, and measured residual `(1/10,0,0)`. The candidate
is the degenerate cubic from `(0,0,0)` to `(10,0,0)`, fitting error `1/100`,
with trace parameter `0`.

Expected results:

```text
traceCentre = (1,0,0)
traceResidualBound = 6/5
traceObservationValid = true
splineCandidateValid = true
validatedSplineProducer.isSome = true
validated localizationError = 121/100
```

Removing the trace parameter or changing the fitting error to `-1` makes the
producer return `none`. The front coupler is not used in this vector.

### G2 — both directed edges

For the validated `spline-1` with length `10`:

```text
forward: startS=0, endS=10, startPoint=p1, endPoint=p2
reverse: startS=10, endS=0, startPoint=p2, endPoint=p1
```

At parameter `t=1/4`, the reverse directed coordinate is `(1-t)*10`; mapping
it back with `edgeCoordinate` gives `t*10`, and `edgePointAt` equals the
forward cubic point. These are executable `native_decide` tests.

### G3 — required spline-to-graph theorem

`validated_spline_to_directed_routing_edge` is exercised with arbitrary
candidate, validated result, orientation, parameter `t`, error `eps`, point
`q`, interval premise `0≤t≤1`, and pointwise premise
`distance3L1 q (cubicPosition curve t) ≤ eps`. The theorem returns stable ID,
orientation, endpoints, directed interval coordinate, point correspondence,
source trace IDs, and the same error inequality. The test also invokes
`validated_spline_trace_fit_is_checked` from the same producer.

The theorem’s mutation cases are:

| Mutation | Expected result |
|---|---|
| forward ↔ reverse | endpoints and coordinate formula change; wrong expected edge fails |
| parameter interval changed | interval premise or edge coordinate fails |
| trace parameter removed/mismatched | `splineCandidateValid` and producer fail |
| fitting error negative | producer returns `none` |
| different stable spline ID | graph consumer no longer has the expected ID |

### G4 — topology

The crossing vector has zero 3-D distance/height, tolerance `1`, both paths
continue, and no known connection. It classifies as `isolatedCrossing` and is
not routable. The overpass vector changes `sameLevel=false` and height to `4`;
it classifies as `overpass` and is not routable. An unresolved observation
leaves the incremental spline store unchanged and unavailable.

This distinguishes 3-D topology from 2-D projection intersection. The
future builder must provide the observations; the Lean classifier does not
invent hidden connectivity.

### G5 — directed marker and route locality

`station-a` is at spline coordinate `5`, distance `1/2`, tolerance `1`, with
forward approach. It is accepted and stores the spline ID, interval coordinate,
and exactly the forward approach. A marker outside `[0,L]` or beyond the
tolerance is rejected. A route graph revision `3` accepts forward and reverse
edge pairs when their spline IDs and endpoint vertex IDs are present.
`graphNetworkProducer 3 [splineVector]` succeeds, while a network containing
the same stable spline candidate twice returns `none`; an empty stable ID
candidate also returns `none` through the validated-spline producer. A forward edge paired with
reverse orientation, missing spline ID, or missing vertex ID is rejected. The
route predicate scans only the active spline/vertex/edge references.

## Detector profile and source separation

### P1 — immediate detector information

The event name is `ir_train_overhead`, UUID `stock-1`, and its immediate
`DynamicInfo` contains definition `compact-loco`, weight `1000`, speed `10`,
forward direction, both brake positions `1`, traction `1000`, and cogging
false. The static definition supplies design mass `1000`, cast-iron shoe
coefficient `1/4`, and both efficiencies `1`.

Expected: `consumeDetectorEvent` returns a stock record. Replacing
`infoResult` with `none` returns `none`. The catalogue preserves list order;
`consistResult` is intentionally unused for per-stock construction.

### P2 — immutable profile mutation

Freezing the stock record and changing brake-system efficiency from `1` to
`2` changes the complete fingerprint and returns `false`. The same mismatch
result is required for UUID, definition, weight, speed, direction, either
brake position, traction, shoe friction, adhesion efficiency, or cogging.

## Exact source-shaped physics

### F1 — source fields and branches

The exact source record is:

```text
current/design mass = 1000 kg
pitch degrees/sine = 0/0
slope multiplier = 1
tractive effort = 100 N
rolling coefficient = 1/100
speed retarder = 5 N
direct coefficient = 1/10
interference = 1, block hardness = 2
train and independent brake = 1/1
brake-system/adhesion efficiency = 1/1
brakeMultiplier = 1, velocity = 10 m/s
brake shoe coefficient = 1/4, cogging = false
```

The source adapter succeeds and derives design/max adhesion from the separate
mass and efficiency fields. Removing `pitchSine` makes it return `none`; a
definition ID mismatch in `sourcePhysicsRecordFromProfile` also returns
`none`. No missing field is replaced with zero.

### F2 — exact force ledger

For the explicitly supplied exact input, the executable result is:

```text
exactForceLedger.netN = -10823 N
```

The checked branch order is grade, traction, rolling, zero-speed resistance,
direct resistance, interference, brake candidate, selected brake material,
multiplier, and signed net sum. Changing `brakeMultiplier` from `1` to `0`
changes the net force. The wheel-slip mutation requires candidate above
maximum adhesion and `abs(velocity)>1/100`; it selects `mass*21/50` rather
than the ordinary candidate. The material vector separately checks
`steelStatic=7/10`, `steelKinetic=21/50`, and
`steelCastIronKinetic=1/4`. The root friction branch uses the steel kinetic
constant for slip; the cast-iron value is not silently substituted there.

Mutations that must change or reject the source result are mass, brake
coefficient/efficiency, `brakeMultiplier`, pitch sine/grade, positive
tractive effort, either brake channel, wheel-slip branch, and block hardness.

## Front coupler and command/plant transition

### C1 — stopping reference

The forward coupler definition has front offset `1`, rear offset `-2`, slack
`1/10`; reverse offsets are `-1` and `2`. With centre coordinate `5` and
centre error `1/10`, the producer returns:

```text
splineId = spline-1
frontCouplerS = 6
errorBound = 131/100
orientation = forward
```

This tests that the stopping target uses the front coupler and the validated
spline, not raw `getPos()` or a hitbox.

### C2 — coexistence and plant result

The valid command has throttle `1/20`, train brake `1`, independent brake `1`,
emergency true, command age `1/10`, and pressure age `1/10`. It passes
`commandValid`; changing throttle to `2` fails. Both the legacy transitional
plant vector and `exactPlantTransition` produce a next state for the valid
command. `exact_plant_rejects_invalid_command` proves the invalid branch is
`none`.

The exact transition constructs the source force ledger with the command’s
positive throttle and both brake channels, then applies the discrete particle
step and the unchanged-position stop branch. This is a certified model
boundary, not yet an identity proof for every Java linkage/collision path.

### C3 — linkage and per-particle state

With force `2`, interacting mass `1000`, interacting friction `1`, `dt=1`,
and a previous link whose current distance `0` is corrected to minimum
distance `1`, the expected state is:

```text
positionS = 2
velocityMps = 1001/1000
frictionN = 1
```

Changing the link distance to `-1` returns `none`. The list transition remains
per-particle and rejects invalid link/mass inputs; it does not replace the
consist with one scalar mass.

## Numeric and timing boundary

### N1 — raw command conversion

Finite channels are converted in `[0,1]`, ages must be finite and nonnegative,
and the adapter records a source path. A NaN throttle makes
`apiCommandProducer` return `none`; `numericConvert 0 1 .nan = none`. Positive
and negative infinity have the same fail-closed contract.

### T1 — deterministic versus measured timing

The deterministic jar vector has tick period `1/20` and next-branch bound
`1/200`. Runtime values are sample age, command delay, pressure delay,
detector-info delay, and route-change latency, each supplied as `1/20` or
`1/10`. `delayBudgetProducer` succeeds and adds the deterministic branch
bound to command delay. Removing sample age makes both runtime timing and
delay budget unavailable. No measured runtime latency is presented as a jar
fact.

## Guard, safety, arrival, and holding

### A1 — uniform terminal-entry guard

The concrete bound uses mass `100`, brake lower `1000 N`, positive traction
upper `100 N`, adverse grade `100 N`, zero curvature/slack/push-pull, geometry
error `1`, terminal tolerance `1`, and zero delay. `terminalGuard 10 ... 2`
is true. Negative velocity, nonpositive distance, or brake lower `100 N`
causes false. Thus target crossing, wrong-way movement, and nonpositive
deceleration cannot enter the stopping theorem.

### A2 — no-crossing and separate terminal arrival

For `a=2`, `dt=1`, distance `10`, velocity `3`, the one-step result is
nonnegative in both distance and velocity. For stopping distance
`v²/(2a)` and `dt=v/a`, the terminal one-step result has exactly zero
velocity and zero distance. The repeated run vector proves velocity does not
increase from `3` over three steps. These are separate checks: no-crossing
does not itself prove stable terminal acceptance.

### A3 — stable acceptance and tolerance derivation

The stable contract allows position and speed tolerances `1`, but requires two
observations. A one-observation list is rejected. The error vector
`(trace,fit,coupler,sample-age,command-delay,numeric)=(1,2,3,4,5,6)` derives
the position tolerance `21`; no convenience tolerance is selected.

### A4 — IR holding

The exact rest predicate is `velocity=0 ∧ abs(force)<friction`. The vector
`(velocity,force,friction)=(0,3,4)` is accepted and
`holdingTransition 5 0 3 4` returns `(5,0)`. A zero-force-only predicate is
not the IR condition.

## Required mutation suite

The executable suite covers the following producer/consumer mutations. A
future Java/Lua harness must repeat them with actual adapters and measured
values before deployment:

| Mutation family | Lean vector/result | Live obligation |
|---|---|---|
| route direction / target crossing | wrong edge orientation and negative distance reject | mutate active route and marker direction |
| spline interval / overpass / crossing | coordinate, separate-path, and unroutable results change | mutate 3-D geometry and topology evidence |
| profile source | missing `info`, wrong definition, changed fingerprint reject | detector event/info/order mutation |
| mass / brake / multiplier / grade | force ledger changes or source adapter rejects | compare Java branch output and measured stock data |
| wheel slip / shoe material | selected branch changes; steel slip remains `21/50` | adhesion/slip and material mutation |
| throttle / both brake channels | combined command and plant branch changes | setter/normalization/pressure-delay mutation |
| curvature / slack / push-pull | guard bound must be recomputed | coupled consist and curved-track mutation |
| sample / command / pressure / route delay | missing data rejects; delay budget changes | timing and route-change latency mutation |
| NaN/infinity/out-of-range | numeric/API producer returns `none` | Java float/Lua numeric mutation |

The suite is intentionally not an optimality proof. Any claim that the chosen
controller minimizes time, energy, or jerk is unsupported and withdrawn.
