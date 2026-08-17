# Runtime source-field, physics, and timing investigation

Status: evidence report, not a proof-readiness declaration.

This report separates facts available in Immersive Railroading 1.11.0’s selected
Minecraft 1.7.10 Java-8 root classes from definition/configuration data,
geometry-derived values, runtime contracts, and operational exclusions. Jar
provenance is recorded in [pid-jar-manifest.md](pid-jar-manifest.md). Current
Lean interfaces are in `pid-proof-lean/IRRevision.lean`.

## 1. Provenance rule

The following labels are mandatory:

| Label | Use |
|---|---|
| `BYTECODE_DERIVED` | Method order, constants, branches, and equations read from root bytecode. |
| `DEFINITION_DERIVED` | Stock/track definition fields loaded from JSON/CAML or parsed definitions. |
| `CONFIG_DERIVED` | Global/server configuration values. |
| `GEOMETRY_COMPUTED` | Values calculated from a certified spline or orientation. |
| `RUNTIME_CERTIFIED` | Numeric adapter or runtime bound established outside the jar. |
| `OPERATIONAL_EXCLUSION` | Excluded only with detection and fail-closed behavior. |
| `UNAVAILABLE/NOT_READY` | No sound producer or bound currently exists. |

An exact theorem over rational values is not automatically a theorem about the
Lua/IEEE-float/API boundary. Every conversion and every missing source field must
be explicit.

## 2. Field-by-field source investigation

| Field | Jar/source result | Classification and required producer |
|---|---|---|
| Brake-system efficiency | Ordinary stock `getBrakeSystemEfficiency()` returns the definition’s brake-shoe friction. `Locomotive` returns `10.0` when cogging is enabled, otherwise its superclass result. | `BYTECODE_DERIVED` + `DEFINITION_DERIVED`; obtain the definition and cogging state, do not infer from `info()`. :codex-annotation{index="1"} |
| Brake-adhesion efficiency | Ordinary stock returns `1.0`; `Locomotive` returns `10.0` when cogging is enabled, otherwise the superclass result. | `BYTECODE_DERIVED`; obtain locomotive subtype/cogging state. :codex-annotation{index="2"} |
| Brake-shoe friction | `EntityRollingStockDefinition` initializes `brakeCoefficient` from `PhysicalMaterials.STEEL.kineticFriction(material)`, with optional `brake_friction_coefficient` override. `STEEL/CAST_IRON` kinetic friction is `0.25`. | Material constant is `BYTECODE_DERIVED`; per-stock coefficient is `DEFINITION_DERIVED`. They must not be conflated. :codex-annotation{index="3"} |
| Steel/steel adhesion | `PhysicalMaterials.STEEL.staticFriction(STEEL) = 0.70`; kinetic steel/steel is `0.42`. | `BYTECODE_DERIVED`; use exact root-class constants. |
| `brakeMultiplier` | Static `Config$ConfigBalance.brakeMultiplier`, default initialized to `1.0`, configurable. | `CONFIG_DERIVED`; configuration snapshot required. It cannot be recovered uniquely from motion. :codex-annotation{index="4"} |
| Rolling resistance | Definition field `rollingResistanceCoefficient`; base definition default is `0.002`; used as coefficient times mass times `9.8`. | `DEFINITION_DERIVED` and `BYTECODE_DERIVED`; no zero default unless the verified definition says zero. :codex-annotation{index="5"} |
| Slope multiplier | Static `Config$ConfigBalance.slopeMultiplier`, default `1.0`, used in gravity force. | `CONFIG_DERIVED` + `BYTECODE_DERIVED`; configuration snapshot required. :codex-annotation{index="6"} |
| Pitch/slope sine | `SimulationState` stores `entity.getRotationPitch()` and computes `sin(toRadians(pitch))`. A spline tangent can estimate grade but is not automatically identical to the entity rotation-pitch field. | Exact IR value is `BYTECODE_DERIVED`; tracer estimate is `GEOMETRY_COMPUTED`; equality requires `RUNTIME_CERTIFIED` mapping or an interval enclosure. :codex-annotation{index="7"} |
| Speed-retarder resistance | `getDirectFrictionNewtons` detects `Augment.SPEED_RETARDER` and adds `(redstonePower / 15) / numberOfTrackBlocks * (massKg * 9.8)` for each applicable retarder block. | `BYTECODE_DERIVED`; if not used operationally, require route scan/precondition and runtime fail-closed detection. Never silently set to zero. :codex-annotation{index="8"} |
| Direct-resistance coefficient | Definition field `directFrictionCoefficient`; dynamic force also adds `directFrictionCoefficient * independentBrake * massKg * 9.8` and `directFrictionCoefficient * trainBrakePressure * massKg * 9.8`, plus speed-retarder resistance. | Definition coefficient is `DEFINITION_DERIVED`; dynamic result is `BYTECODE_DERIVED` from current state and track query. :codex-annotation{index="9"} |
| Interference resistance | `SimulationState.frictionNewtons` adds `interferingResistance * 1000 * ConfigDamage.blockHardness`. | Equation is `BYTECODE_DERIVED`; block/interference state is runtime/world-derived. A no-collision route is an `OPERATIONAL_EXCLUSION` only with detection. :codex-annotation{index="10"} |
| Block hardness | `ConfigDamage.blockHardness` defaults to `50`; it is configuration, not a universal physics constant. | `CONFIG_DERIVED`. |
| Braking wheel sliding | If brake candidate exceeds maximum adhesion and `abs(velocity) > 0.01`, source sets `sliding` and uses steel/steel kinetic friction. | `BYTECODE_DERIVED`; must be a certified branch, not a caller Boolean. |
| Locomotive traction slip | `Locomotive.simulateWheelSlip` compares applied/static tractive effort, except cogging returns zero; slip affects traction behavior. | `BYTECODE_DERIVED`; distinct from braking sliding. With throttle zero it may be guarded, but the guard must be explicit. :codex-annotation{index="11"} |
| Curvature | Reconstruct from a certified spline and derive the relevant track/bogey geometry effect. | `GEOMETRY_COMPUTED`; no invented arbitrary force term. |
| Coupler slack | Definition supplies front/rear coupler slack; linkage state computes current distance and push/pull limits. | `DEFINITION_DERIVED` + `BYTECODE_DERIVED` + runtime state. |
| Push/pull/linkage | `Consist$Linkage` derives coupled state, min/max distances, `canPush`, and `canPull`; particles interact through permitted linkage paths. | `BYTECODE_DERIVED`; model or conservatively bound the effect. It is not safe to omit because it is “usually irrelevant.” :codex-annotation{index="12"} |
| Track switch state | `RailInfo`/`TileRailBase` carries switch state and branch semantics; current remote API does not expose a complete topology query. | Source fact is `BYTECODE_DERIVED`; runtime producer requires world/block access or mapper evidence. |
| Collision state | `SimulationState` stores colliding/interfering blocks and particle collision correction is part of the plant. | `BYTECODE_DERIVED`; normal-operation exclusion requires detection and fail-closed behavior. |

## 3. Complete source force path

### 3.1 Signed tractive/grade force

`SimulationState.forcesNewtons()` computes, in its source sign convention,

```text
F_source
  = massKg * (-9.8) * sin(toRadians(pitch)) * slopeMultiplier
  + tractiveEffortNewtons(Speed.fromMinecraft(velocity)).
```

The first term is source-derived from `SimulationState.pitch` and
`Config$ConfigBalance.slopeMultiplier`; the second comes from the locomotive or
zero traction for non-locomotives. The proof must preserve the source direction
convention instead of treating a positive magnitude as a signed force.

### 3.2 Friction/brake magnitude

The source computes at least these components:

```text
rolling = rollingResistanceCoefficient * massKg * 9.8
nearZero = (velocity == 0) ? 0.001 * massKg * 9.8 : 0
interference = interferingResistance * 1000 * blockHardness

brakeCandidate = designAdhesionNewtons
                 * min(1, max(brakePressure, independentBrakePosition))

if brakeCandidate > maximumAdhesionNewtons and abs(velocity) > 0.01:
    sliding = true
    brakeMaterial = massKg * STEEL/STEEL kinetic friction
else:
    sliding = false
    brakeMaterial = brakeCandidate

brake = brakeMaterial * brakeMultiplier
friction = rolling + nearZero + interference + brake + directResistance.
```

The exact source method is `SimulationState.frictionNewtons`. The braking term
must include `brakeMultiplier` on every source branch. `directResistance` is
populated from `EntityCoupleableRollingStock.getDirectFrictionNewtons`, which
includes speed-retarder effects and direct-friction coefficient times train and
independent brake positions.

### 3.3 Configuration and adhesion

`SimulationState.Configuration` obtains:

- current/design mass from the entity and fuel configuration;
- coupler offsets/slack from the stock definition and gauge;
- maximum adhesion as `massKg * 0.70 * 9.8 * getBrakeAdhesionEfficiency()`;
- design adhesion as design mass times `0.70 * 9.8 * getBrakeSystemEfficiency()`;
- rolling/direct resistance fields from the definition;
- train-brake target from the locomotive;
- independent-brake position from the entity.

The configuration is therefore not reconstructible from the aggregate
`consist()` response alone. A verified per-stock definition catalogue and current
runtime state are needed.

### 3.4 Particle/consist aggregation

`Consist$Particle` stores mass, position, velocity, force, friction, and linkage
references. It computes velocity using the participating particles’ combined mass
and friction, applies friction, computes position, processes collisions, and
applies a state update. `Consist$Linkage` uses coupled UUIDs, coupler distances,
front/rear slack, and current 3-D distance to determine coupling and push/pull
interaction. The particle path therefore affects the consist’s aggregate motion;
the front locomotive alone is not a complete plant model.

The source `Consist.iterate` uses `dTime = 1/(20*40) = 0.025` seconds for its
40-substep loop, with source calls for velocity, friction, position, linkage, and
state application. This is deterministic simulation-step semantics, not a bound
on wall-clock time between Lua calls and those steps.

## 4. Brake command and pressure path

`CommonAPI.setTrainBrake`, `setIndependentBrake`, and `setThrottle` pass through
`normalize`, which maps NaN to `0`, clamps values above `1` to `1`, below `-1` to
`-1`, and otherwise casts to float. The remote manager’s `setBrake` is an alias to
`setTrainBrake`.

This is an API fact, not a proof of physical acknowledgement. The command path is:

```text
OpenComputers call
 -> radioDrain
 -> CommonAPI normalization
 -> locomotive target setter
 -> desiredBrakePressure in SimulationState.Configuration
 -> Consist.iterate pressure update
 -> SimulationState.brakePressure
 -> frictionNewtons brake branch
 -> Particle/Consist transition.
```

For pressure-brake states, `Consist.iterate` either assigns desired pressure
immediately when `Config$ImmersionConfig.instantBrakePressure` is true, or moves
the current pressure toward the desired value by a per-iteration increment. The
source lambda uses the largest desired pressure and a rate of `0.1 / number of
pressure-brake states`; it clamps at the target. The proof must represent both
configuration branches and cannot equate a setter return with immediate physical
pressure.

The current Lean `apiCommandProducer` rejects NaN and only accepts a narrower
nonnegative command shape. That is not the exact root `CommonAPI.normalize` path.
Either the proof deliberately specifies a stricter precondition and documents it,
or the Lean adapter must model the source normalization exactly.

## 5. What the remote API supplies

`CommonAPI.info()` supplies definition ID/name/tag, weight, speed/direction and
independent brake for movable stock, and locomotive horsepower/traction/max speed,
brake/train-brake/throttle/reverser plus applicable steam/diesel/cargo data.

`CommonAPI.consist(boolean)` supplies aggregate car count, tractive effort, moving
mass, speed, direction, aggregate locomotive information when requested, and
related totals. It does not expose a complete per-wagon profile, brake-shoe
material/coefficient, rolling/direct-resistance coefficients, coupler offsets or
slack, pitch, curvature, linkage state, wheel sliding, interference, or complete
track topology.

Therefore:

- dynamic fields must be read from the API where present;
- static fields must be resolved by definition ID from the verified jar catalogue
  or addon definition catalogue;
- configuration fields must come from a configuration snapshot;
- world/geometry fields require a geometry/world adapter or runtime certificate;
- missing or conflicting values must make the certified input unavailable.

The current `sourcePhysicsRecordFromProfile` and `sourcePhysicsAdapter` are useful
fail-closed shapes, but they accept static definitions, configuration, and runtime
exact fields as already populated. They do not prove that `info()` or `consist()`
produced them. In particular, `RuntimeExactPhysicsInputs` currently treats pitch,
speed-retarder, direct coefficient, and interference values as caller inputs.

## 6. Runtime timing and failure contracts

The jar proves source step ordering and branch semantics. It does not prove
OpenComputers scheduler latency, radio RPC latency, server lag, event queue delay,
or the wall-clock interval between an API call and a physics step.

The stopping proof must use a total certified delay and position uncertainty. A
generic required inequality is:

```text
v_max * T_external
 + accelerationBound * T_external^2 / 2
 + sampleError
 + computationError
 <= terminalGuardMargin.
```

Calling a delay “negligible” is valid only if this inequality is checked with a
numeric bound for the actual operating context.

| Timing/failure item | Source result | Required status and handling |
|---|---|---|
| Radio range/energy | `radioDrain` checks API presence, current/card distance against configurable `RadioRange`, and connector energy via `tryChangeBuffer`; the root defaults are `RadioRange = 500` and `RadioCostPerMetre = 0`, but both are configurable. | The operational assumption that radio cannot fail requires preflight and every-call failure detection. Otherwise `NOT_READY`; never treat it as a theorem fact. :codex-annotation{index="13"} |
| `info()`/`consist()` request-to-result | Jar proves synchronous method call structure, not wall-clock duration. | `RUNTIME_CERTIFIED` only with a measured/conservative upper bound. Big-O describes algorithm growth, not latency. :codex-annotation{index="14"} |
| OpenComputers scheduling/event delivery | Not established by IR jar. | Runtime contract or `NOT_READY`. “Negligible” requires the inequality above. :codex-annotation{index="15"} |
| Setter to next physics step | Jar establishes setter target and source tick/substep semantics; it does not establish when the server executes the next step relative to Lua. | Separate `BYTECODE_DERIVED` tick ordering from a numeric external command-to-step bound. :codex-annotation{index="16"} |
| Brake-pressure propagation | Source-derived through `instantBrakePressure` or the `0.1/count` pressure update path. | Model exactly; additionally bound external command-to-update delay. :codex-annotation{index="17"} |
| Detector event to `info()` | Event name/payload and API call are source/runtime interface facts, but queue delay is external. | If detector events are not used by stopping, classify as irrelevant under that contract. If used, certify its delay. :codex-annotation{index="18"} |
| Active-route change detection | Not a jar constant. A bound can be derived from the active-route polling interval plus bounded check execution time. | `RUNTIME_CERTIFIED` only after the algorithm, interval, and worst-case execution bound are fixed; route invalidation must fail closed. :codex-annotation{index="19"} |
| Sample age at stop command | It contributes at least `v * sampleAge` displacement uncertainty and state-drift uncertainty. | Must be included in the terminal-entry guard and compared against its margin; missing age means `NOT_READY`. :codex-annotation{index="20"} |

The current Lean `RuntimeTiming` correctly makes the external fields optional and
fails closed when absent. However, `delayBudgetProducer` adds
`nextBranchBound` to command delay while retaining `tickPeriod` only as a
nonnegative check. A completed proof must show whether tick period is already
included elsewhere; otherwise it must add it to the certified total or document a
separate source-step convention. The detector delay must also be included only if
the stopping theorem actually depends on detector information.

## 7. Operational exclusions

The following exclusions can be pragmatic, but only with explicit preconditions,
detection, and fail-closed behavior:

- speed retarders: route scan or track augment check;
- block interference/collision: normal-operation route contract plus collision
  observation;
- traction slip during braking: throttle-zero supervisor and runtime confirmation;
- consist changes: player profile update plus detected profile mismatch;
- radio failure: range/energy preflight and per-call failure response;
- addon stock: definition compatibility check before certification.

“Players normally avoid collisions” is not a mathematical bound. If an excluded
state is detected or cannot be ruled out, the controller must stop issuing a
certified claim and enter the documented fail-closed state.

## 8. Current Lean gap inventory

The important current interfaces are:

| Lean item | Current strength | Remaining issue |
|---|---|---|
| `StaticDefinition`/`GlobalConfiguration` | Separates definition and configuration fields. | Producer from actual catalogue/config snapshot is absent. |
| `RuntimeExactPhysicsInputs` | Forces runtime-sensitive values to be optional. | Values are caller-supplied; no pitch, augment, block, or world-state adapter exists. |
| `sourcePhysicsRecordFromProfile` | Rejects definition-ID mismatch and missing fields. | It packages supplied fields; it does not establish provenance. |
| `sourcePhysicsAdapter` | Rejects negative inputs and constructs an exact model. | Exact rational arithmetic does not prove source/API/floating-point fidelity. |
| `exactForceLedger` | Encodes force branches and both brake channels. | Must be tied to the complete bytecode-derived source equation and mutation tests. |
| `source_particle_transition` | Has a state-transition shape. | Must represent source linkage, pressure, collision, and aggregation branches rather than simplified defaults. |
| `RuntimeTiming`/`delayBudgetProducer` | Fails closed on missing/nonnegative timing values. | Must include all required timing terms exactly once and distinguish jar time from external time. |
| `apiCommandProducer` | Has a command-to-plant theorem. | Its NaN/range behavior differs from `CommonAPI.normalize`; its source-path refinement must be repaired. |

The current Lean structures are therefore a useful contract skeleton, not proof
that the runtime fields have been obtained faithfully.

## 9. Required validation and mutation tests

A final implementation/proof audit must:

1. mutate `brakeMultiplier`, slope multiplier, rolling/direct coefficients, mass,
   brake-shoe coefficient, and adhesion efficiencies and verify the relevant
   force/bound result changes;
2. mutate pitch sign and route orientation and verify force sign changes;
3. exercise train-brake-only, independent-brake-only, and combined channels;
4. exercise no-slip, braking-slide, and traction-slip branches separately;
5. exercise instant and propagating brake-pressure configurations;
6. exercise nonzero direct resistance, speed-retarder detection, interference,
   and collision fail-closed cases;
7. remove each source definition/config/runtime field and verify certification
   becomes unavailable;
8. mutate command normalization with NaN, values above one, below minus one, and
   negative reverser/brake inputs;
9. mutate sample age, command delay, pressure delay, route latency, and detector
   delay until the terminal guard rejects the case;
10. compare the source adapter’s output with independently inspected root-bytecode
    branch traces rather than only testing abstract arithmetic.

## 10. Final conclusions

### Genuinely established by the jar

- exact root Java-8 force, friction, adhesion, brake, pressure, particle, linkage,
  and API branch structure;
- source constants and defaults listed in the provenance tables;
- deterministic 40-substep consist iteration semantics;
- the distinction between static definition data, configuration, and runtime
  state;
- the fact that `info()`/`consist()` do not expose the complete physics profile.

### Feasible with faithful implementation

- a definition/configuration catalogue adapter;
- exact source force and pressure modelling;
- conservative curvature/slack/linkage bounds;
- a complete controller-to-plant transition with explicit command and timing
  contracts;
- fail-closed operational exclusions.

### Still blocking a completed Gate E/I claim

- source-faithful producers for all fields currently supplied to
  `sourcePhysicsRecordFromProfile`;
- exact geometry-to-pitch/curvature and world-state adapters;
- complete linkage/particle/collision refinement;
- a proven command-normalization/API refinement;
- numeric external timing bounds and sample-age accounting;
- independent mutation tests against adapter and transition boundaries.

Until those are implemented and audited, the correct readiness result is
`NOT_READY`; the reports do not establish implementation readiness.

## 11. Evidence commands and audit checklist

Representative root-class checks:

```bash
javap -classpath /tmp/ir-jar-audit.IykqtX -p -c cam72cam.immersiverailroading.entity.physics.SimulationState
javap -classpath /tmp/ir-jar-audit.IykqtX -p -c cam72cam.immersiverailroading.entity.physics.Consist
javap -classpath /tmp/ir-jar-audit.IykqtX -p -c cam72cam.immersiverailroading.thirdparty.CommonAPI
```

Before accepting a future proof update, verify:

- every field in the source table has a real producer and provenance label;
- no static definition/configuration field is inferred from aggregate motion;
- every force/pressure branch has a source citation and Lean transition;
- every runtime delay has a numeric bound or forces `NOT_READY`;
- every exclusion has detection and fail-closed behavior;
- exact source timing is not presented as wall-clock timing;
- API normalization and NaN behavior match the selected contract;
- mutation tests cross the bytecode adapter, geometry adapter, and plant
  transition, not merely arithmetic helper definitions;
- the final report remains `NOT_READY` while any Gate E/I dependency is assumed,
  defaulted, excluded for convenience, or disconnected.
