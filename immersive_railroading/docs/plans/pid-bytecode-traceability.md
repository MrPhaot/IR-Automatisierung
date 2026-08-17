# Root Java-8 bytecode and proof traceability

This file is the source-to-model ledger for the replacement proof. The
authoritative inputs are the extracted files under
`immersive_railroading/.cache/jar/`. The root classes are the target; classes
under `META-INF/versions/16` and later are excluded.

## Provenance

| Item | Evidence | Classification |
|---|---|---|
| Minecraft | `mcmod.info`: `1.7.10` | derived from package metadata |
| Immersive Railroading | `mcmod.info`: `1.11.0` | derived from package metadata |
| variant | `META-INF/MANIFEST.MF`: `Multi-Release: true` | bytecode/package fact |
| target class level | root classes have major `52` | bytecode fact; Java 8 |
| excluded variants | `META-INF/versions/16` classes have major `60` | bytecode fact; not used |
| identity and inputs | `pid-jar-manifest.md`, `pid-physics-contract-manifest.sha256` | reproducibility contract |

The six-input hash check is:

```bash
cd immersive_railroading
sha256sum -c docs/plans/pid-physics-contract-manifest.sha256
```

It covers `MANIFEST.MF`, `mcmod.info`, and the complete decompiled inputs
`SimulationState_decompiled.txt`, `Configuration_decompiled.txt`,
`Particle_decompiled.txt`, and `LocomotiveDefinition_decompiled.txt`. The
relevant root class hashes, including `CommonAPI`, detector adapters,
`EntityRollingStock`, `SimulationState`, `SimulationState$Configuration`,
`Consist`, `Consist$Particle`, `MovementTrack`, `ITrack`, `CubicCurve`, all
four builders, `RailInfo`, `PhysicalMaterials`, `Config$ConfigBalance`, and
the locomotive classes, are recorded in `pid-jar-manifest.md`.

## Exact root-bytecode facts

The following are observations from `javap -p -c` on the root class path. A
fact is not promoted to a runtime guarantee until its adapter supplies every
required value.

| Producer / consumer | Root method and branch | Fact used by the proof | Classification |
|---|---|---|---|
| detector event | `AugmentManagerBase.update`, identity-change branch | emits `ir_train_overhead` and stock UUID | bytecode fact |
| detector payload | `DetectorAugment.info` | delegates stock information through `CommonAPI.info()` | bytecode fact |
| dynamic stock data | `CommonAPI.info`, identity/weight/speed/direction and brake/control branches | definition ID, weight, speed, direction, independent brake, traction, train brake, throttle/reverser are dynamic observations; missing data remains unavailable | bytecode fact / runtime contract |
| aggregate data | `CommonAPI.consist(true)` | ordered/aggregate consist report is validation support, not a replacement for per-stock `info()` | bytecode fact |
| raw position | `EntityRollingStock` position path | returned position is not established as F3 hitbox or rail centreline | bytecode fact / model boundary |
| coupler geometry | `SimulationState.Configuration` constructor and `calculateCouplerPositions` | mass, bogey offsets, coupler offsets/distances/slack, yaw and track adjustment feed coupler positions | bytecode fact |
| signed grade/traction | `SimulationState.forcesNewtons`, bytecode offsets 0--44 | `mass * -9.8 * sin(toRadians(pitch)) * slopeMultiplier + tractiveEffort` | bytecode fact / derived equation |
| IR rest | `SimulationState.atRest`, offsets 0--29 | true exactly when velocity is zero and `abs(force) < frictionNewtons()` | bytecode fact |
| rolling / near-zero | `SimulationState.frictionNewtons`, offsets 0--48 | rolling coefficient times mass and gravity; at exact zero velocity add `0.001 * mass * 9.8` | bytecode fact |
| interference | `frictionNewtons`, offsets 49--63 | `interferingResistance * 1000 * ConfigDamage.blockHardness` | bytecode fact |
| both brake channels | `frictionNewtons`, offsets 65--92 | `min(1, max(brakePressure, independentBrakePosition)) * designAdhesion` | bytecode fact |
| wheel slip | `frictionNewtons`, offsets 94--155 | if candidate exceeds maximum adhesion and `abs(velocity) > .01`, replace candidate by `mass * STEEL.kineticFriction(STEEL)` and set sliding | bytecode fact |
| global multiplier | `frictionNewtons`, offsets 155--177 | selected brake term is multiplied by `ConfigBalance.brakeMultiplier` before the resistance sum | bytecode fact |
| direct resistance | `SimulationState.next`, offsets 146--171 | direct resistance is recomputed from the current track update and consumed by the next friction calculation | bytecode fact |
| movement direction | `SimulationState.next` and `moveAlongTrack` | next clones state, moves along track, recalculates state; negative distance is negated and front yaw rotated by 180 degrees | bytecode fact |
| unchanged position | `SimulationState.next`, offsets 16--40 | unchanged movement sets velocity to zero | bytecode fact |
| particle force | `Consist$Particle.computeVelocity`, offsets 0--297 | selects push/pull interactions, aggregates mass/friction, caps friction by force direction, updates selected particles, distributes remaining friction | bytecode fact |
| particle position | `Consist$Particle.computePosition`, offsets 0--29 | performs `position += velocity * dt`, then invokes linkage `correctDistance` when a previous link exists | bytecode fact |
| cubic geometry | `CubicCurve.position` and `derivative` | Bernstein cubic and derivative factors 3, 6, 3 | bytecode fact |
| arc length | `CubicCurve.lengthWithCache` / `lengthInBetween` | samples derivative values and accumulates trapezoids; exact-circle length is not established | bytecode fact / numerical contract |
| straight/turn builders | `BuilderStraight`, `BuilderTurn`, `BuilderSlope` | builder-produced controls and metadata are source observations; straight is representable as a degenerate cubic | bytecode fact / model input |
| switches/crossings | `BuilderSwitch`, `BuilderCrossing`, `MovementTrack`, `ITrack`, `RailInfo` | topology and rail metadata are source observations; a 2-D projection intersection does not prove connectivity | bytecode fact / runtime contract |
| material constants | root `PhysicalMaterials` calls | steel static `0.70`, steel kinetic `0.42`, steel/cast-iron kinetic `0.25` are recorded; the inspected `frictionNewtons` slip branch invokes steel/steel kinetic, not the cast-iron branch | bytecode fact; branch use distinguished |
| locomotive overrides | root `Locomotive` / definition overrides | cogging-specific brake-system and adhesion efficiency overrides are `10`; ordinary definition data is separate | bytecode fact |
| configuration | root `Config$ConfigBalance`, `Config$ConfigDamage` | multiplier and block hardness are global configuration, not caller certificates | bytecode fact |
| API normalization | `CommonAPI.normalize`, offsets 0--31 | NaN maps to zero and finite values clamp to `[-1,1]`; proof API boundary rejects nonfinite values and explicitly bounds command channels | bytecode fact / runtime contract |

## Branch-to-Lean trace

| Root fact | `IRRevision.lean` producer/consumer | Relation theorem or vector | Classification |
|---|---|---|---|
| tracer offset and residual | `TraceObservation`, `traceCentre`, `traceResidualBound`, `traceFitRowsValid`, `validatedSplineProducer` | `validated_spline_trace_fit_is_checked`; trace and invalid-fit vectors | proved by Lean under certified observations |
| cubic forward/reverse geometry | `orientedCurve`, `edgeCoordinate`, `directedCoordinateOfParameter`, `edgePointAt` | `cubic_reverse_position`; `edge_point_at_parameter` | proved by Lean over exact-rational cubic model |
| validated spline to graph edge | `validatedSplineProducer`, `directedEdge`, `routingGraphProducer` | `validated_spline_to_directed_routing_edge`; `directed_edge_preserves_localization_error` | proved by Lean; source validity is producer output |
| graph network assembly | `graphNetworkProducer`, `endpointVertices`, `directedEdges` | single valid candidate network succeeds; empty/duplicate stable-ID candidate network rejects | proved by Lean over validated producer outputs |
| graph source discipline | `GraphVertex`, `routingGraphProducer`, `graphNetworkProducer`, `edgeWithSplinePresent`, `routeEdgeReferences` | `routing_graph_consumes_only_validated_spline`; active route checks spline/vertex/edge references together | proved by Lean at the validated-spline boundary |
| topology | `TopologyObservation`, `classifyTopology`, `reconstructionCommit` | `crossing_is_separate`, `overpass_is_separate`, unresolved/crossing unavailable vectors | proved by Lean under 3-D observations |
| marker mapping | `directedMarkerProducer` | `marker_maps_to_valid_spline_interval`, `marker_wrong_orientation_is_not_permitted` | proved by Lean under distance/interval producer checks |
| profile source boundary | `DetectorEvent`, `DynamicInfo`, `StaticDefinition`, `GlobalConfiguration`, `stockAdapter`, `catalogueProducer` | `catalogue_preserves_order`, `invalid_profile_is_not_accepted` | proved by Lean under source-adapter completeness |
| profile to physics | `sourcePhysicsRecordFromProfile`, `sourcePhysicsAdapter` | `source_profile_physics_requires_definition_match`, `source_profile_physics_preserves_mass_and_channels` | proved by Lean; missing source fields fail closed |
| exact force branches | `ExactPhysicsInput`, `exactPressure`, `exactWheelSlip`, `exactForceLedger` | `source_force_ledger_equation`, `source_wheel_slip_changes_branch`; net-force and multiplier vectors | derived from bytecode and proved algebraically |
| front coupler | `CouplerDefinition`, `frontCouplerLocalizationProducer` | `coupler_localization_consumes_validated_spline`; front-coupler vector | proved by Lean under definition/offset producer |
| command/API | `RawControllerCommand`, `numericConvert`, `apiCommandProducer`, `ControllerCommand` | `invalid_api_command_fails_closed`, `api_command_produces_valid_command` | proved by Lean at explicit numeric boundary |
| command to plant | `exactCommandPhysics`, `exactPlantTransition`, `sourceParticleTransition` | `exact_plant_rejects_invalid_command`, `exact_plant_has_source_next_state`, `source_particle_transition_has_next_state` | certified source-shaped abstraction; full Java refinement remains open |
| timing | `JarTiming`, `RuntimeTiming`, `runtimeTimingProducer`, `delayBudgetProducer` | `missing_runtime_timing_fails_closed`, `missing_runtime_budget_fails_closed` | deterministic jar bound separated from measured runtime contract |
| guarded arrival | `BrakingBound`, `terminalGuard`, `ArrivalState`, `revisionArrivalRun` | guard rejection, no-crossing, terminal one-step, velocity monotonicity vectors | proved by Lean under explicit uniform bound assumptions |
| terminal acceptance/holding | `TerminalAcceptanceContract`, `stableObservationAccepted`, `irRestCondition`, `holdingTransition` | `stable_observation_window_rejects_short_list`, `holding_preserves_ir_terminal_state` | runtime acceptance contract; not a live Lua guarantee |
| route-local failure | `ActiveRoute`, `routeReferencesGraph`, `routeDecision` | `invalid_route_fails_closed_without_replan` | proved by Lean under graph revision/edge inputs |

## Required worked theorem

`validated_spline_to_directed_routing_edge` is in
`pid-proof-lean/IRRevision.lean` near the geometry producer. Its producer
premise is `validatedSplineProducer c = some v`, not a caller-supplied
`SplineCertificate v`. It depends on:

1. `TraceObservation`, `traceCentre`, `traceResidualBound`,
   `traceFitRowsValid`, and `splineCandidateValid`;
2. `validatedSplineProducer_candidate` and
   `validatedSplineProducer_error`;
3. `Cubic`, `cubicPosition`, `cubicReverse`, and the proved
   `cubic_reverse_position` identity;
4. `orientedCurve`, `edgeCoordinate`,
   `directedCoordinateOfParameter`, `edgePointAt`, and `directedEdge`.

It proves stable-ID preservation, both orientation cases, endpoint
correspondence, directed interval-coordinate mapping for every parameter in
`[0,1]`, point correspondence, and transfer of an arbitrary pointwise
localization inequality. The proof uses the nonzero certified total length,
rational division cancellation, reverse-cubic identity, and the producer's
recorded localization error. Its transitive `#print axioms` output is only:

```text
[propext, Classical.choice, Quot.sound]
```

The mutation vectors reverse orientation, alter the interval mapping, use an
invalid fitting row, and use a different spline ID; the changed results are
in `IRRevisionTestVectors.lean`. The theorem does not claim floating-point
correctness or live tracer accuracy.

The multi-spline consumer theorem
`IRRevision.graph_network_consumes_only_source_validated_splines` applies the
same producer/consumer discipline to `graphNetworkProducer`: every emitted edge
is shown to originate from a candidate whose `validatedSplineProducer` output
supplies the corresponding validated spline, while empty and duplicate
stable-ID inputs return `none`. Its transitive axiom set is
the same foundational Lean set, `[propext, Classical.choice, Quot.sound]`.

## Source boundary and withdrawn implications

The Lean equations are exact-rational contract equations. They do not by
themselves refine Java `double`/`float` arithmetic, Lua scheduling, detector
latency, radio failure, pressure propagation, collision resolution, hidden
track connectivity, or full consist linkage. Those values must be measured or
derived by future adapters and must be rejected when unavailable. The
cast-iron constant is recorded because the root material library exposes it;
the inspected `SimulationState.frictionNewtons` branch uses the steel kinetic
constant for wheel slip, so this proof does not silently substitute `0.25`
into that branch. Formal controller optimality and the old PID theorems are
withdrawn.
