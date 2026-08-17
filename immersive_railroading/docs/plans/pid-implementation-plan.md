# Source-connected IR proof implementation contract and ledger

Status: `NOT_READY`. This ledger records the replacement proof work and the
remaining runtime/refinement obligations. It is not permission to edit or
deploy `programs/train_controller.lua`; that file and all production Lua are
unchanged.

The authoritative specifications are `PLAN_NEWPROOF.md` and
`PLAN_NEWPROOF_REVISION.md`, with the revision taking precedence. The proof
funnel is:

```text
detector/tracer observations
  -> centreline cubic splines
  -> validated topology and directed graph
  -> directed station/route localization
  -> ordered immutable consist profile
  -> front-coupler error and velocity
  -> combined throttle/train-brake/independent-brake command
  -> source-shaped IR force and particle transition
  -> guarded arrival, holding, or fail-closed stop
```

Raw `getPos()` is neither the rail centreline nor the front coupler. The
spline is geometric source of truth; the graph only references validated
spline IDs and intervals.

## Deliverable map

| Artifact | Purpose | Current classification |
|---|---|---|
| `pid-proof-lean/IRRevision.lean` | normative source-connected exact-rational model | proved by Lean under explicit source/runtime premises |
| `pid-proof-lean/IRRevisionTestVectors.lean` | positive and mutation vectors | executable contract tests |
| `pid-proof-lean/Axioms.lean` | transitive theorem axiom inventory | foundational Lean axioms only |
| `pid-formal-proof.tex` | readable definitions, equations, claims, limitations | proof/report artifact |
| `pid-bytecode-traceability.md` | root Java-8 branch ledger and theorem mapping | derived from bytecode plus model boundary |
| `pid-test-vectors.md` | reproducible vector specification | executable contract test description |
| `pid-audit-report.md` | Gates A--I and anti-cheating audit | final audit status |
| `pid-readiness-report.md` | handoff classification and blockers | `NOT_READY` |

## Connected model obligations

### Geometry and graph

The Lean producer validates trace identity, offset, finite nonnegative error
terms, trace residual, fitting rows, positive spline length, source IDs, and
parameter intervals before constructing `ValidatedSpline`. A validated spline
stores cubic controls, reverse orientation, length, arc/fitting data, tangent,
grade, curvature, trace IDs, and builder source. The graph producer consumes
only this validated output. `validated_spline_to_directed_routing_edge` is the
required nontrivial relation: it proves stable ID, forward/reverse endpoints,
directed interval coordinate, point correspondence, and localization-error
transfer.

Incremental topology uses 3-D distance, tangent, curvature, arc, and height
observations. Continuation, extension, split, overlap, shared connection,
crossing, overpass, new geometry, and unresolved states are distinct. Isolated
crossings and height-separated overpasses do not create connections;
unresolved cases remain unroutable.

Stations/signals are mapped to a spline only within a recorded tolerance and
carry one configured approach orientation. `graphNetworkProducer` validates
each candidate before assembling its spline output into a revisioned graph and
rejects empty stable IDs and duplicate stable IDs rather than silently aliasing
geometry. Active route
validation checks only the active edge pairs and graph revision. A changed
graph invalidates the route, triggers current-graph replanning, and fails
closed if no route is available.

### Detector profile and physics source boundary

The catalogue consumes `ir_train_overhead`, records UUID, immediately consumes
`info()`, preserves order, and separates `DynamicInfo`, `StaticDefinition`,
`GlobalConfiguration`, and runtime timing/physics inputs. Missing information,
definition mismatch, or changed frozen fingerprints fail closed. `consist()` is
aggregate validation only.

The exact source record contains current/design mass, pitch and its sine,
slope, traction, rolling/direct/interference terms, block hardness, both brake
channels, both efficiencies, `brakeMultiplier`, velocity, shoe coefficient,
and cogging. `sourcePhysicsAdapter` rejects missing or invalid fields; it does
not accept caller-supplied certificates as evidence of their own validity.
The exact force ledger follows root Java-8 branch order, including the steel
static/kinetic constants, cast-iron constant as a separately recorded source
material, near-zero term, both brake channels, wheel-slip branch, multiplier,
and signed grade/traction.

### Controller, particle plant, and arrival

`ControllerCommand` carries throttle, train brake, independent brake,
emergency, command age, and pressure age. `apiCommandProducer` rejects
nonfinite and invalid values and emits a source path. `exactPlantTransition`
uses the same source-shaped force ledger with positive throttle and both brake
channels, then applies a discrete particle step and unchanged-position branch.
`SourceParticleInput` retains interacting mass/friction, push/pull direction,
linkages, slack, collision observation, and track-transition observation.

The front-coupler coordinate is directed:

```text
x   = target_s - front_coupler_s
v_s = d(front_coupler_s)/dt
```

Only `x>0` and `v_s>0` enter the stopping guard. The uniform lower bound
subtracts positive traction, adverse grade, curvature, slack, and push/pull
terms from lower braking over the complete delay horizon. It includes
observation age, command delay, pressure delay, detector timing, route-change
latency, geometry error, and terminal tolerance. No-crossing, terminal
velocity/distance, stable-observation acceptance, IR rest holding, and route
failure are separate claims.

## Ralph implementation ledger

Statuses mean that the artifact work and its recorded checks are complete;
they do not mean that the unchanged production Lua already fulfills the future
obligations listed below.

### R0 — fresh baseline and provenance freeze

- Dependencies: none.
- Status: `verified`.
- Iteration: baseline.
- Changed files: status/report/ledger artifacts only.
- Commands: `lake build`; `lake env lean Axioms.lean`; forbidden scan;
  `latexmk`; SHA-256 manifest check; scoped changed-file check.
- Expected/actual: previous readiness withdrawn; root Java-8 provenance
  recorded; no production Lua or authoritative plan changed. Actual baseline
  was `NOT_READY`.
- Producer boundary: checked-in proof sources and hashed jar inputs produce
  evidence records; no compilation-only claim is inferred.
- Mutation/premise result: preserving a previous READY label would be an
  invalid inherited premise; all later gates require fresh evidence.
- Classification/remediation: verified baseline only; substantive tasks below
  remain required.

### R1 — source ledger and Java-8 equations

- Dependencies: R0.
- Status: `verified` for the proof ledger.
- Changed files: `pid-jar-manifest.md`, `pid-bytecode-traceability.md`,
  `IRRevision.lean`, `Axioms.lean`.
- Checks: root class major/version/hash inspection; complete decompiler input
  inspection; `javap -p -c`; SHA-256 check; `lake env lean Axioms.lean`.
- Producer boundary: root bytecode branch -> `SourceRef` and exact model
  fields/ledger.
- Mutation result: version-16 substitution is excluded by variant/hash check;
  missing source fields reject the source adapter.
- Classification/remediation: derived from bytecode and proved model mapping;
  live floating-point and external timing remain runtime contracts.

### R2 — trace, spline, and directed edge

- Dependencies: R1.
- Status: `verified` for the compiled model and vectors.
- Changed files: `IRRevision.lean`, `IRRevisionTestVectors.lean`,
  `pid-bytecode-traceability.md`, `pid-test-vectors.md`.
- Checks: `lake build`; `lake env lean IRRevisionTestVectors.lean`;
  required theorem and `#print axioms` inventory.
- Producer boundary: `validatedSplineProducer` -> `directedEdge`.
- Relation theorem: `validated_spline_to_directed_routing_edge`.
- Mutation result: reverse orientation, interval coordinate, invalid fitting
  row, and different stable ID change or reject the result.
- Classification/remediation: proved by Lean over the certified exact-rational
  model; live fitting, arc-length approximation, and tracer residual measurement
  remain future Lua obligations.

### R3 — topology, graph, markers, and route locality

- Dependencies: R2.
- Status: `verified` for the model and negative vectors.
- Changed files: `IRRevision.lean`, test vectors, traceability, reports.
- Checks: crossing/overpass/unresolved vectors; marker interval/approach
  vectors; single/duplicate `graphNetworkProducer` vectors; the
  `graph_network_consumes_only_source_validated_splines` relation; wrong active-route
  orientation; route revision theorem; build.
- Producer boundary: validated spline/topology observations -> graph edge and
  active route decision.
- Mutation result: projection-only crossing, insufficient height separation,
  wrong marker orientation, and missing replacement route do not route.
- Classification/remediation: proved by Lean under recorded 3-D observations
  and validated-spline producer outputs;
  persistent graph builder, hidden connectivity, and live replan remain Lua
  obligations.

### R4 — detector profile and source separation

- Dependencies: R1.
- Status: `verified` for the producer model.
- Changed files: `IRRevision.lean`, vectors, reports.
- Checks: immediate-info, missing-info, order, static-definition, and frozen
  fingerprint vectors; build and axiom inventory.
- Producer boundary: detector event + dynamic info + static definition + global
  configuration -> ordered `StockRecord`/`FrozenProfile`.
- Mutation result: absent info, wrong definition, changed brake data, reorder,
  or UUID mismatch fails closed.
- Classification/remediation: proved by Lean under API event-delivery contract;
  detector speed, effective length, response time, and live profile mutation
  detection require runtime tests.

### R5 — source-derived force model

- Dependencies: R1, R4.
- Status: `verified` for the exact source-shaped ledger.
- Changed files: `IRRevision.lean`, vectors, traceability, reports.
- Checks: source adapter; missing pitch sine; definition mismatch; exact net
  force `-10823`; multiplier mutation; material constants; source `#print axioms`.
- Producer boundary: source profile/config/runtime fields -> `ExactPhysicsInput`
  -> `ExactForceLedger`.
- Mutation result: mass, multiplier, grade, traction, wheel slip, resistance,
  hardness, and brake branch changes alter the result or reject missing input.
- Classification/remediation: branch equation derived from root bytecode and
  algebraically represented in Lean. Full per-stock dynamic source extraction,
  Java float semantics, and physical lower-bound certification remain future
  obligations.

### R6 — particle and consist transition

- Dependencies: R5.
- Status: `verified` for the conservative source-shaped abstraction.
- Changed files: `IRRevision.lean`, vectors, reports.
- Checks: valid exact plant, invalid command, source particle expected next
  state, bad linkage rejection, build/axioms.
- Producer boundary: source command/force + per-particle linkage summary ->
  next particle state.
- Mutation result: invalid mass/linkage/command returns `none`; changed
  interacting friction or link distance changes the next state.
- Classification/remediation: source-shaped model is proved; exact Java
  collision, track lookup, pressure propagation, and every `Consist` linkage
  branch remain a required refinement and live harness obligation.

### R7 — directed front coupler and controller

- Dependencies: R2, R3, R4, R6.
- Status: `verified` for the contract model.
- Checks: front coupler localization `s=6`, error `131/100`, command
  coexistence, invalid command, API source path, exact plant existence.
- Producer boundary: validated spline + coupler definition + command adapter ->
  directed error/velocity and combined command/plant input.
- Mutation result: reverse orientation changes signed velocity/offset; throttle
  `2` rejects; positive throttle remains in the exact ledger.
- Classification/remediation: proved contract path; production Lua route state,
  setter ordering, saturation/slew, emergency handling, and pressure timing are
  future obligations.

### R8 — uniform guard and arrival

- Dependencies: R5, R6, R7.
- Status: `verified` for the explicit discrete model.
- Checks: positive guard, wrong-way/crossed target, nonpositive deceleration,
  no-crossing one-step, terminal zero velocity/distance, repeated velocity
  monotonicity, stable observation rejection, IR holding.
- Producer boundary: lower-braking/upper-traction/error/timing bound -> guard
  -> arrival state and stable acceptance.
- Mutation result: delay, grade, traction, curvature/slack/push-pull, mass,
  positive throttle, or lower brake must change/reject the guard. The current
  Lean vector suite includes the direct negative cases; a live mutation harness
  is still required.
- Classification/remediation: proved conditional theorems; a complete uniform
  physical bound over every Java branch and consist is not yet established.

### R9 — numeric, timing, and fail-closed boundary

- Dependencies: R1, R4, R7, R8.
- Status: `verified` for the explicit producer contracts.
- Checks: NaN conversion; command validity; missing runtime timing; delay
  budget; route fail closed; build/axioms.
- Producer boundary: raw numeric/runtime observations -> validated command and
  `DelayBudget`.
- Mutation result: nonfinite, negative age, missing sample/pressure/detector/
  route timing returns `none`; deterministic jar timing is never used as a
  measured external latency.
- Classification/remediation: proved contract; live scheduler, radio, detector,
  Lua numeric, and route-change measurements remain required.

### R10 — anti-cheating audit and mutations

- Dependencies: R2--R9.
- Status: `verified` for the checked-in exact-rational suite; live harness
  remains a blocker.
- Checks: forbidden-mechanism scan, all vector files, theorem axiom inventory,
  source-adapter/geometry/controller/transition/timing mutation matrix.
- Producer boundary: each mutation enters the actual producer/consumer path,
  not only a disconnected arithmetic lemma.
- Result: Lean vectors reject the listed mutations; no project-specific axiom,
  `sorry`, `admit`, `unsafe`, `cast`, or `ofReduceBool` declaration is present.
- Classification/remediation: proof audit complete; live Java/Lua mutation
  execution is a future implementation obligation.

### R11 — LaTeX, reports, and consistency

- Dependencies: R2--R10.
- Status: `verified` for the artifact consistency audit.
- Iteration: final document pass.
- Changed files: `pid-formal-proof.tex`, `pid-audit-report.md`,
  `pid-readiness-report.md`, `pid-bytecode-traceability.md`,
  `pid-test-vectors.md`, this ledger.
- Verification commands: `lake build`; `lake env lean Axioms.lean`;
  `lake env lean IRRevisionTestVectors.lean`; SHA-256 manifest; LaTeX build;
  stale-claim scan; scoped `git diff --check`.
- Expected/actual: all proof/report names, source branches, vectors, and
  readiness classifications agree; actual consistency check passes. LaTeX
  exits successfully and its final log has no TeX or layout diagnostics.
- Producer boundary: Lean theorem/model/source ledger -> LaTeX, test, audit,
  and readiness consumers.
- Mutation/premise result: stale PID theorem names are withdrawn; optimality
  and exact floating-point/refinement claims are explicitly classified
  unsupported rather than retained.
- Classification/remediation: artifact consistency verified; runtime/source
  blockers, not document formatting, determine the `NOT_READY` decision.
- Acceptance: theorem names, variables, equations, vectors, source offsets,
  graph/marker/profile/force branches, classifications, and readiness status
  agree across all artifacts.

### R12 — final independent audit

- Dependencies: R10, R11.
- Status: `verified` as a fresh read-only final audit with a negative readiness
  result.
- Iteration: final audit.
- Changed files: none during the read-only command set.
- Verification commands: the complete Gate A--I reproducer set, exact
  forbidden scan, root hash check, theorem axiom extraction, stale-claim
  scan, and scoped production-file check.
- Expected/actual: reject `READY_FOR_USER_APPROVAL` while source/runtime
  obligations remain; actual result is `NOT_READY` and Gate I is not passed.
- Producer boundary: final audit consumes all proof/report artifacts and
  produces the readiness classification; it does not infer deployment approval
  from compilation.
- Premise-removal/mutation result: removing live source, timing, or transition
  premises would make handoff unsound; mutation matrix remains required for
  the future Java/Lua harness.
- Classification/remediation: final audit complete; implement and measure the
  listed future Lua/runtime obligations before reconsidering Gate I.
- Acceptance: fresh Gates A--I audit; no stale PID claims; no readiness claim
  stronger than the remaining source/refinement/runtime evidence.
- Honest result: `NOT_READY`; this task cannot establish all required source
  connections and runtime bounds without modifying/observing production.

## Future production-Lua obligations

1. Persist trace observations and derive the compact tracer centre with stock,
   bogey, yaw, movement, sample-age, fitting, and residual bounds.
2. Fit and incrementally rebuild 3-D cubic splines with arc marks, tangent,
   grade, curvature, source traces, stable IDs, topology states, and explicit
   unresolved handling.
3. Build route graphs from validated spline IDs/intervals and directed markers;
   validate only active-route references and replan/fail closed on revisions.
4. Catalogue by detector UUID plus immediate `info()`, preserve order, record
   static/configuration data separately, freeze the complete profile, and stop
   on mismatch.
5. Derive front-coupler localization from stock/bogey/coupler semantics; never
   use raw position as a stopping target.
6. Send throttle, train brake, independent brake, emergency state, command
   age, and pressure age through one combined command contract.
7. Measure or derive a uniform lower-braking/upper-traction bound including
   grade, wheel slip, resistance, curvature, slack, push/pull, mass, and all
   delays before enabling automatic stopping.
8. Implement terminal deadbands from the complete error budget, stable
   observations, IR rest holding, diagnostics, and fail-closed recovery.
9. Execute the vectors against Java/Lua adapters for curved, slack, push/pull,
   adhesion-limited, wheel-slip, detector-delay, route-mutation, and profile-
   mutation scenarios.

Until these obligations are connected to the unchanged runtime, the proof
artifacts are a conditional implementation contract, not approval for user
deployment.
