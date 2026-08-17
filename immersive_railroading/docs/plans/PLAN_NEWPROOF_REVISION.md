# Final Source-Connected Proof Revision

## Authority and execution order

`PLAN_NEWPROOF.md` remains the base specification. This file is a mandatory
corrective supplement and overrides the base specification wherever the two
documents differ. Neither plan may be modified by the implementing agent.

All artifacts produced by an earlier implementation are untrusted migration
artifacts. A previous successful build or readiness report does not carry over
to this revision.

## Ralph-Wiggum execution protocol

Ralph is mandatory in both stages of this work:

```text
plan-refinement Ralph loop
→ handoff-ready revision
→ implementer Ralph loop
→ proof artifacts
→ independent final audit
```

Ralph is a bounded fresh-context state machine. It is not an instruction to
continue indefinitely and it is not allowed to weaken the proof requirements
after repeated failure.

Each iteration starts a fresh agent context. The agent must reread the
authoritative files and persistent state instead of relying on previous
conversation memory or its own previous conclusions.

### Plan-refinement Ralph loop

This loop refines and audits the handoff specification before implementation.

The plan loop uses these modes:

```text
PLAN_AUDIT
→ PLAN_REPAIR
→ PLAN_AUDIT
→ PLAN_HANDOFF_CHECK
```

`PLAN_AUDIT` is read-only and must inspect `AGENTS.md`, both authoritative
plans, the revision prompt, current proof artifacts, and current reports. It
must identify exactly one highest-priority defect, such as an undefined
interface, missing dependency, unclassified source value, gate without a
debugging procedure, vacuous completion condition, prompt contradiction,
undocumented implementation decision, or missing failure condition.

`PLAN_REPAIR` may change only the plan or prompt section required for that one
defect. After each repair, a fresh `PLAN_AUDIT` must verify that the defect was
removed, no unrelated section changed, no requirement was weakened, and the
prompt still agrees with the plan.

`PLAN_HANDOFF_CHECK` is read-only and may emit:

```text
<promise>PLAN_HANDOFF_READY</promise>
```

only when every implementation task has dependencies and acceptance criteria,
every funnel arrow has a producer, consumer, theorem, and test, every gate has
a debugging procedure, Ralph has finite stopping conditions, and no requirement
depends on undocumented agent judgment.

The plan loop has a maximum of 12 iterations and 3 repair attempts for one
defect. If either limit is reached, emit `<promise>BLOCKED</promise>` and
preserve the audit findings.

### Implementer Ralph loop

The implementation agent must receive both plans, the revision prompt,
`pid-implementation-plan.md`, and the current proof/report artifacts.

The implementation loop uses:

```text
BASELINE
→ IMPLEMENT
→ IMPLEMENT_AUDIT
→ IMPLEMENT
→ ...
→ FINAL_AUDIT
```

`BASELINE` records the current build, axiom, warning, provenance, readiness,
and forbidden-mechanism state. It must not inherit a previous readiness claim.

In `IMPLEMENT` mode, select exactly one pending task whose dependencies are
complete, implement only that task, run its verification, update
`pid-implementation-plan.md`, and stop with:

```text
<promise>ITERATION_COMPLETE</promise>
```

In `IMPLEMENT_AUDIT` mode, a fresh read-only context inspects changed files,
source evidence, and task checks; tests vacuous premises, disconnected
definitions, optimistic defaults, tautological certificates, fake aliases,
and unsupported claims; and reports findings without modifying repository
files. A task becomes `verified` only after implementation checks and the
independent audit pass.

### Persistent state and outer runner

Use `pid-implementation-plan.md` as the implementation ledger. Each task entry
must contain the task ID, description, dependencies, status
(`pending | in_progress | verified | blocked`), iteration number, changed
files, verification commands, expected result, actual result, audit result,
and remaining blockers.

The plan-refinement loop may use `/tmp/pid-plan-ralph-state.md`; that temporary
state is not proof evidence and must not replace the authoritative plan.

The outer runner, not the agent, decides whether another iteration starts. It
must launch a fresh context, pass the mode and task/defect identifier, preserve
the ledger, capture the final response, invoke read-only audit after
implementation, stop on `BLOCKED`, iteration limit, or changed-file violation,
never turn an audit failure into a pass, and preserve failed evidence.

A Bash loop, Codex CLI wrapper, or equivalent runner is acceptable. Installing
an external plugin is not required; the required behavior is authoritative.

### Completion, retry, and safety limits

Use these defaults:

- plan-refinement maximum: 12 iterations;
- implementation maximum: 40 iterations;
- maximum retries for one defect or task: 3.

Use these signals:

```text
<promise>PLAN_HANDOFF_READY</promise>
<promise>ITERATION_COMPLETE</promise>
<promise>BLOCKED</promise>
<promise>DONE</promise>
```

`DONE` is permitted only in `FINAL_AUDIT` mode after every task is verified,
Gates A–I pass, the final audit is fresh and read-only, and no required claim
is assumed, defaulted, conveniently excluded, or disconnected. On timeout or
retry exhaustion report `NOT_READY`; never emit `DONE`.

Both loops must preserve unrelated changes, never modify production Lua,
never modify either base plan or base prompt during implementation, never
modify proof artifacts during read-only audits, avoid unauthorized commits,
verify the changed-file allowlist, and use temporary copies for mutations.
Reusing the same underlying agent does not make its previous conclusions
independent evidence.

## Investigation checklist

The second-pass investigation is complete.

| Area | Finding | Status |
|---|---|---|
| `CommonAPI.info()` | Provides identity, weight, speed, direction, independent brake, locomotive controls, and starting traction; not all static physics data | Requires adapter redesign |
| Definition catalogue | Jar/addon definitions provide brake shoe friction, brake capabilities, rolling/direct resistance, geometry, bogey/coupler offsets, slack, and locomotive traction definitions | Usable, but currently absent from Lean |
| `brakeMultiplier` | Global configuration value, not an `info()` field | Requires configuration-source record |
| Grade/resistance | Derived from current IR state, track/world state, and definition data | Must not default to zero |
| Curvature/slack/push-pull | Must be represented through geometry and `Consist$Linkage`, not invented as arbitrary per-stock forces | Current model insufficient |
| Wheel slip | Derived by the IR branch condition, not supplied as a free Boolean | Current model insufficient |
| Timing | Internal physics substeps are bytecode-derived; Lua, detector, radio, scheduling, and lag latency require measured bounds | Must split proof and runtime contracts |
| Mutation testing | Current tests mutate abstract formulas only | Must add source-adapter and transition mutations |
| Current Lean build | Builds with unused-premise warnings | Must be warning-free before acceptance |
| Current readiness | Reports claim all gates pass while required refinements remain future obligations | Must be changed to `NOT_READY` |

## Good existing components to preserve

### 1. The overall funnel architecture

Keep the pipeline in the LaTeX scope section:

```text
tracer samples
→ spline geometry
→ routing graph
→ consist/definition profile
→ front-coupler controller
→ IR plant
```

This is good because it separates geometric truth, routing, physical state, and control responsibilities. Preserve the distinction between spline and graph models, the directed station approach, detector profiling, front-coupler stopping, combined commands, and fail-closed states.

Complete it by requiring a nontrivial Lean dependency path through every arrow:

```text
trace adapter
→ centreline witness
→ fitted spline certificate
→ graph construction
→ profile/catalogue adapter
→ front-coupler localization
→ controller command
→ source-derived IR transition
→ next controller state
```

A theorem that merely accepts all intermediate records as arbitrary premises does not complete an arrow.

### Worked example of an acceptable arrow

The arrow

```text
validated spline geometry → directed routing edge
```

must be demonstrated by a compiled, nontrivial Lean theorem before the other
funnel arrows can be accepted. Use the existing `Spline`,
`SplineCertificate`, `GraphEdge`, `splineForwardEdge`, `splineReverseEdge`,
and `buildRoutingGraph` concepts, strengthening them where necessary.

The theorem must be equivalent in content to:

```lean
theorem spline_to_graph_localization_sound
    (s : Spline)
    (hs : SplineCertificate s)
    (q : Vec3)
    (forward : Bool)
    (t : Q)
    (eps : Q)
    (hinterval : 0 ≤ t ∧ t ≤ 1)
    (hprojection :
      distance3L1 q (cubicPosition s.curve t) ≤ eps) :
    let edge := directedEdgeOfSpline s forward
    let u := t * s.totalLength
    distance3L1 q (graphPoint edge u) ≤ eps
    ∧ graphCoordinate edge u =
        if forward then u else s.totalLength - u
    ∧ graphStart edge =
        if forward then s.curve.p1 else s.curve.p2
    ∧ graphEnd edge =
        if forward then s.curve.p2 else s.curve.p1
```

Exact names may differ, but the proof must establish all of the following:

- the edge references the same stable spline identifier;
- the edge uses a certified spline interval;
- forward traversal preserves the spline parameter;
- reverse traversal uses the reversed cubic and reverses the coordinate;
- both edge endpoints correspond to the correct spline endpoints;
- the localization residual bound is preserved;
- the proof depends on the spline certificate, cubic geometry, orientation
  function, edge constructor, and graph representation.

This is not satisfied by defining the graph point and edge point identically
and proving the result by `rfl`. The proof must use the cubic reverse identity,
endpoint lemmas, interval/length hypotheses, and both orientation cases.

The final report must include:

- the theorem name and source location;
- its `#print axioms` output;
- the Lean definitions on which it depends;
- the corresponding LaTeX claim;
- a mutation test showing that reversing orientation, changing the edge
  interval, or assigning the wrong spline causes the theorem or its test to
  fail.

Use this theorem as the minimum standard for every other arrow. Record the
producer, consumer, relation theorem, assumptions, and mutation test for:

| Funnel arrow | Required Lean relation |
|---|---|
| tracer samples → spline | trace-fit and centreline soundness theorem |
| spline → graph | the worked theorem above |
| graph/profile → controller localization | route and front-coupler localization theorem |
| profile/catalogue → physics input | source-field and configuration refinement theorem |
| controller command → IR plant | command-to-force and next-state refinement theorem |
| plant transition → arrival | invariant-preservation and terminal-arrival theorem |

### Source-evidence boundary

Bytecode extraction is authoritative evidence, but it is not automatically a
Lean proof.

Maintain a `BytecodeEvidence` record or equivalent traceability artifact for
every source-derived fact. It must contain:

- jar hash;
- class name;
- method name;
- Java-8 root-class path;
- relevant `javap -p -c` excerpt;
- branch order;
- extracted constants;
- extracted equation;
- interpretation and units;
- Lean definition using the fact;
- LaTeX citation;
- classification as bytecode-derived, formally derived, assumed, or
  runtime-certified.

A manually transcribed bytecode fact must never be classified as “proved by
Lean” unless a formal source-verification theorem actually exists.

### Certificate semantics

A structure named `Certificate`, `Sound`, `Valid`, or `Bound` is a contract
boundary, not proof of its own validity.

For every certificate, identify:

- producer;
- data source;
- validation algorithm;
- Lean theorem validating the producer;
- runtime measurement or assumption;
- failure result when validation is unavailable.

A theorem consuming a certificate remains conditional until its producer is
connected and validated.

### Addon compatibility criteria

The deliverables must include a stock/addon compatibility manual.

An addon is compatible only if:

- its definition has a stable namespace and definition ID;
- its resource files can be located and hashed;
- required mass, brake, resistance, geometry, coupler, slack, and traction
  fields are available;
- its movement and coupler semantics match the modeled IR semantics;
- custom physics overrides are identified and modeled;
- missing or ambiguous data produces `UNAVAILABLE`, not a guessed profile.

### 2. The cubic and orientation algebra

Keep the cubic Bézier definitions, endpoint identities, derivatives, reverse operation, and degenerate straight representation in `IRProof.lean` lines 94–136.

Extend them with:

- exact IR builder witnesses for straight, turn, slope, switch, and crossing geometry;
- a proof that each accepted spline is fitted to its source samples;
- certified arc-length enclosures;
- tangent, grade, and curvature interval bounds;
- explicit forward/reverse coordinate transformation;
- a distinction between exact straight geometry and IR’s cubic turn approximation.

The LaTeX geometry chapter must not claim that an arbitrary fitted cubic is automatically an IR track section.

### 3. The topology categories and fail-closed intent

Keep `ReconstructionKind`, unresolved states, separate crossing/overpass paths, route revisioning, and fail-closed routing.

Rewrite `ReconstructionEvidence` and `commitReconstruction` in `IRCertifiedModel.lean` lines 30–115 so that:

- evidence is generated by matching and geometry procedures rather than supplied as unconstrained Boolean flags;
- continuation leaves the same interval unchanged;
- extension updates an existing spline interval;
- split physically partitions an existing spline;
- overlap records the overlap mapping rather than appending a duplicate;
- shared connections create explicit graph connection records;
- crossings and overpasses remain separate paths;
- unresolved cases add no routable geometry;
- stable IDs and source-trace provenance are preserved.

Manual classification remains allowed only for genuinely indistinguishable topology. It must be represented as unresolved until the player classifies it.

### 4. Ordered detector profiling and immutable fingerprints

Keep the ordered profile, repeated stock definitions, UUID preservation, fingerprinting, and `consist()` as aggregate validation.

Replace the current `StockObservation` with two records:

```text
DynamicObservation:
  stock UUID
  definition ID
  weight
  speed
  direction
  train-brake/independent-brake positions
  locomotive throttle/reverser/traction observations

DefinitionRecord:
  canonical definition ID and namespace
  static mass/max mass
  brake shoe material/coefficient
  pressure-brake and independent-brake capability
  rolling resistance
  direct friction
  bogey/front/rear geometry
  coupler offsets and slack
  locomotive traction function or certified upper envelope
```

`CommonAPI.info()` must be documented exactly from bytecode. Static data must be selected by the returned definition ID from the jar/addon catalogue. `brakeMultiplier` must come from the configuration source, not from `info()`.

Unknown IDs, missing addon resources, conflicting definitions, or incomplete required fields must produce an unavailable profile and fail closed.

The profile adapter must not treat locomotive `traction` from `info()` as the complete speed-dependent traction function. The proof must use the definition’s traction function or a conservative bound over the certified speed domain.

In addition to the dynamic and static records above, maintain an explicit
configuration/runtime source record containing at least:

```text
ConfigurationRecord / RuntimeCertificate:
  brakeMultiplier and other relevant balance/configuration values
  slack-enabled state
  current grade/interference observability
  sample age and command/pressure-delay bounds
  numeric conversion and validity certificates
```

Every proof-relevant field must identify whether it comes from dynamic
`info()`, a static definition/addon resource, global configuration, or a
runtime certificate. Missing or conflicting sources must produce an
unavailable profile rather than a default value.

Every proof-relevant value must carry one of these provenance labels:

- dynamic `info()` observation;
- static jar/addon definition;
- global configuration;
- runtime certificate;
- derived interval;
- unavailable.

A value may not silently move from `unavailable` to zero.

### 5. The front-coupler and directed-coordinate model

Keep the front coupler as the stopping reference and the route-local coordinate from the LaTeX directed-stopping chapter.

Rewrite `IRProof.lean` lines 740–802 so that orientation affects computation:

```text
s_reverse = L - s_forward
v_reverse = -v_forward
x = target_s - front_coupler_s
v_s = d(front_coupler_s)/dt
```

The front-coupler coordinate must be derived from the source definition, bogey offsets, coupler offsets, selected gauge, orientation, and IR movement semantics. It must not be a free `tracerCentreS + offsetS` record.

Prove separately:

- valid forward approach;
- valid reverse physical approach after route reorientation;
- wrong-way motion rejection;
- target-crossing rejection;
- localization error propagation into terminal tolerance.

### 6. The combined-command record and fail-closed supervisor

Keep `ControllerCommand`, route/profile/numeric validation, and explicit `Option` command output.

Complete them by making the command policy real:

```text
route-localization
→ front-coupler error and velocity
→ consist and linkage bounds
→ throttle allocation
→ train-brake allocation
→ independent-brake allocation
→ emergency/saturation/slew normalization
→ IR command adapter
→ plant transition
→ next controller state
```

The proof may use positive throttle, but the certified lower-force bound must include the exact commanded traction or a conservative upper bound. A positive throttle value must never disappear from the stopping proof.

### 7. The separate safety, arrival, and holding theorem structure

Keep the separation between:

- stopping-envelope preservation;
- no-crossing safety;
- velocity convergence;
- terminal arrival;
- settling/holding;
- route feasibility;
- optimality withdrawal.

Replace premise-consuming certificates with source-connected transition theorems. A theorem that accepts a `StableArrivalCertificate` containing already-valid observations may remain as a helper lemma, but it must not be reported as proof that the plant reaches the certificate.

Holding must use IR’s actual rest condition:

```text
velocity = 0
∧ abs(forcesNewtons) < frictionNewtons
```

rather than requiring an unrelated exact zero-force condition.

## Required substantive rewrite

### A. Replace optimistic/default physical inputs

Rewrite `physicsFromObservation` in `IRCertifiedModel.lean` lines 324–347.

The following values may not default to zero:

- grade;
- rolling resistance;
- direct resistance;
- interference resistance;
- curvature;
- slack;
- push/pull state;
- wheel-slip state;
- pressure delay;
- current brake state.

They must be populated as follows:

- Grade: derive local pitch from IR state or a certified spline/track tangent enclosure, then apply the exact `sin(toRadians(pitch))` source equation and slope multiplier.
- Rolling resistance: use the definition coefficient multiplied by current mass and gravity.
- Direct resistance: use the definition coefficient, current train-brake pressure, independent-brake position, and speed-retarder contributions.
- Interference: derive from the current interfering blocks and hardness, or mark the state unavailable.
- Curvature: derive from spline curvature and the corresponding IR track/bogey geometry; use it to bound linkage/geometry effects, not as an invented source force.
- Slack and push/pull: derive from coupler definitions and `Consist$Linkage` state, including `canPush`, `canPull`, current linkage distance, minimum distance, and collision state.
- Wheel slip: compute from the exact IR predicate:
  `brakeCandidate > maximumAdhesion ∧ abs(velocity) > 0.01`.
- Brake availability: derive from the definition record.
- Brake multiplier: derive from the deployed global configuration record.
- Mass: distinguish current mass from design/max mass exactly as `SimulationState.Configuration` does.

Unknown or unobservable values must be represented with `Option` or interval certificates. They must never be silently replaced by zero.

### B. Rebuild the source-derived force model

Rewrite `IRProof.lean` lines 543–677.

The Lean model must mirror the Java-8 root equations:

```text
forcesNewtons =
    massKg * (-9.8)
    * sin(toRadians(pitch))
    * slopeMultiplier
    + tractiveEffortNewtons(speed)
```

```text
rolling =
    rollingResistanceCoefficient * massKg * 9.8
```

```text
nearZero =
    if velocity = 0 then 0.001 * massKg * 9.8 else 0
```

```text
brakeCandidate =
    min 1 (max brakePressure independentBrakePosition)
    * designAdhesionNewtons
```

```text
brakeCandidate' =
    if brakeCandidate > maximumAdhesionNewtons
       ∧ abs velocity > 0.01
    then massKg * steelKinetic
    else brakeCandidate
```

```text
brakeForce =
    brakeMultiplier * brakeCandidate'
```

```text
directResistance =
    speedRetarderResistance
    + directFrictionCoefficient * independentBrakePosition * massKg * 9.8
    + directFrictionCoefficient * brakePressure * massKg * 9.8
```

The particle transition must preserve the distinction between source drive force and particle friction processing. It must model the direction multiplication, interacting-particle selection, friction allocation, velocity update, position update, linkage correction, and collision handling from `Consist$Particle` and `SimulationState.next`.

The theorem names may be retained, but a theorem such as `signed_force_equation := rfl` is insufficient unless its inputs are already source-linked.

### C. Replace the scalar Euler consist model

Rewrite `IRProof.lean` lines 679–738 and `IRCertifiedModel.lean` lines 365–373.

The next-state model must contain:

- one state per particle;
- source configuration per particle;
- positions and velocities;
- direction;
- source force and friction;
- linkage graph;
- coupler minimum/current distances;
- push/pull permissions;
- slack;
- collision state;
- front/rear coupler positions;
- track transition result.

Do not prove `consist_step_preserves_geometry` by merely preserving fields in a record update. Prove the actual invariants of the source transition or provide a conservative refinement theorem that bounds their effect.

### D. Make timing claims honest and usable

Split timing into two layers.

Bytecode-derived:

- server tick identity and tick IDs;
- internal `Consist.iterate` substep count and nominal substep duration;
- `SimulationState.next` movement ordering;
- command normalization/clamping;
- pressure-state update path where source code provides it.

Runtime-certified:

- detector event delivery latency;
- `info()` response time;
- controller execution time;
- radio/API command latency;
- command acknowledgement age;
- brake-pressure propagation age;
- sample age;
- server lag and scheduling delay;
- route-change detection latency.

The stopping guard must use the sum of these certified upper bounds. The proof may proceed with symbolic bounds, but the final report must classify them as runtime contracts until measured. An unbounded or unavailable timing value must force fail-closed behavior.

The detector catalogue bound must use detector geometry, train length/order, event semantics, response time, and event latency. The current simplistic `(detectorLength + minimumSpacing) / responseTime` theorem may remain only as a local arithmetic lemma, not as the complete detector correctness proof.

### E. Make geometry reconstruction sound

Rewrite `IRProof.lean` lines 198–259 and the LaTeX geometry sections.

Add a certificate containing:

- source sample IDs;
- source raw positions;
- compact tracer definition ID;
- definition-derived bogey/centre offsets;
- sample ticks and spacing;
- fitted control points;
- point-to-curve residuals;
- arc-length enclosure;
- tangent enclosure;
- grade enclosure;
- curvature enclosure;
- floating-point conversion error;
- missing-sample error;
- valid parameter domain.

Replace the current residual formula with a dimensionally valid derivation. The proof must show that every accepted sample is within the declared position error of the fitted spline and that the error remains valid between samples under the certified curvature/spacing bound.

`TraceCentreSound` must be produced by an adapter theorem or explicit runtime certificate, not constructed from an arbitrary `actualCentre` supplied by the caller.

### F. Complete graph and marker semantics

Rewrite `IRProof.lean` lines 358–396 and `IRCertifiedModel.lean` lines 191–235.

Require:

- exact endpoint/interval alignment for route edges;
- ordered edge-chain connectivity;
- marker spline-ID and arc-coordinate validity;
- marker direction constraints on the corresponding graph interval;
- no routable edge for unresolved or isolated-crossing geometry;
- no 2D-only merging;
- active-route-only validation;
- route revision invalidation and replan/fail-closed behavior.

The function actually used by closest-marker mapping must include both distance and arc-interval validation.

### G. Complete controller-to-plant refinement

Rewrite `IRProof.lean` lines 920–1074 and `IRCertifiedModel.lean` lines 375–490.

The controller state must include the data used by the policy, including:

- graph revision;
- profile fingerprint;
- target and orientation;
- front-coupler localization;
- consist/linkage bounds;
- command ages;
- brake-pressure age;
- saturation/slew state;
- stopping/holding/fail-closed mode.

`stoppingCommand` must be replaced by the actual intended allocation policy or a formally specified conservative policy. Full-brake hard-coding may be used only as an emergency branch, not as the general controller proof.

The refinement theorem must connect the emitted command to the source API path, not merely to a locally identical `commandPhysics` function.

### H. Complete arrival and tolerance proofs

Rewrite `IRProof.lean` lines 804–918 and lines 1076–1128.

Required theorems:

1. guard entry implies positive target-directed motion and positive certified deceleration;
2. one-step transition preserves the stopping envelope;
3. all allowed force branches preserve the lower-force bound;
4. repeated valid transitions cannot cross the target;
5. finite velocity convergence;
6. finite terminal arrival within position and speed tolerances;
7. stable observation-window acceptance;
8. holding under IR’s actual rest condition;
9. fail-closed result when any required premise becomes invalid.

The arrival theorem must refer to the evolving front-coupler state and target coordinate. A list of observations that already satisfies the terminal predicate is not a liveness proof.

### I. Correct the numeric boundary

Replace the Boolean-only `NumericBoundary` with a conversion certificate containing:

- raw runtime value;
- finite/NaN/infinity classification;
- normalization result;
- clamp result;
- exact-rational enclosure;
- absolute conversion error;
- accepted range.

Replace `invalid_numeric_boundary_is_rejected`, which currently repeats its premise, with a theorem that the adapter returns `none` or `failClosed` for invalid input.

Exact rational proofs must be explicitly conditional on this conversion certificate and must not be reported as automatic proofs of Lua floating-point execution.

## Mutation and anti-cheating revision

### New mistake classes

Add these classes to the anti-cheating audit.

#### Class 14: certificate or assumption laundering

A structure named `Certificate`, `Sound`, `Valid`, or `Bound` must not become proof merely because a caller supplies it.

Gates:

- identify the producer of every certificate;
- distinguish source-derived, algorithm-derived, measured, and assumed certificates;
- prove the adapter produces the certificate or classify the theorem as conditional;
- do not mark a conditional theorem as implementation proof;
- mutate or remove each certificate producer and require rejection.

#### Class 15: optimistic default or unknown-state erasure

Zero, identity, or neutral defaults must not erase unknown adverse physics.

Gates:

- every proof-relevant field requires source provenance;
- a default zero is accepted only with a proof that zero is physically exact or conservative;
- otherwise use an interval, `Option`, or fail-closed result;
- mutate each omitted term and require the guard/result to change or reject.

#### Class 16: source/catalogue adapter disconnect

A definition ID, configuration value, or API field may select the wrong or incomplete physical record.

Gates:

- document the exact `info()` schema;
- document the definition-resource resolution algorithm;
- hash the selected jar/addon records;
- reject missing, ambiguous, or incompatible definitions;
- prove that every required physics parameter is supplied by either dynamic observation, static definition data, configuration, or a runtime certificate;
- test wrong IDs, missing fields, addon drift, and configuration drift.

#### Class 17: unbounded runtime timing

Nominal jar timing must not be presented as a bound on Lua, detector, radio, scheduler, or server-lag timing.

Gates:

- separate deterministic source timing from runtime timing;
- record the source of every latency bound;
- require measured worst-case or explicitly conservative runtime bounds;
- propagate all ages into the terminal guard;
- fail closed when a bound is absent or exceeded.

### Strengthen existing classes

- Class 2: a theorem consuming a certificate is only a conditional contract lemma unless the certificate producer is proved.
- Class 4: `rfl` equations and hard-coded literals are not bytecode derivations; require a source ledger and mutation-linked adapter.
- Class 5: copying fields between records is not refinement; require a dependency graph through the source adapter and transition.
- Class 8: an Euler abstraction is unacceptable unless a theorem refines every relevant IR branch or proves a conservative bound.
- Class 9: aliases and identical definitions do not establish API refinement.
- Class 10: include stock-definition namespace, addon resource, configuration, and catalogue hashes.
- Class 11: require an actual runtime-to-rational conversion certificate.
- Class 12: distinguish conditional contract correctness from actual runtime liveness.
- Class 13: require upstream mutations and an independent oracle, not only mutations of the final abstract formula.

### Required mutation suite

Mutations must pass through the same adapter path used by the proof:

- remove or rename an `info()` field;
- replace a definition catalogue record;
- change brake-shoe coefficient;
- change `brakeMultiplier`;
- replace `sin(toRadians(pitch))` with raw pitch;
- omit rolling/direct/interference resistance;
- swap train and independent brake channels;
- remove the wheel-slip threshold;
- remove the kinetic-friction branch;
- change coupler offset or slack;
- reverse the route-coordinate sign;
- omit linkage correction;
- omit particle interaction;
- bypass marker orientation;
- append instead of split/extend geometry;
- reduce timing bounds;
- remove stale-data rejection.

Each mutant must either fail to compile, fail an adapter certificate, fail a theorem, or change an independently computed expected result. A mutation that passes merely because the theorem repeats an assumption is an audit failure.

## Gate-specific debugging procedures

The base Gates A–I remain mandatory. A gate may not be marked passed solely
because a later gate compensates for an earlier failure. For every gate, record
the command or reproducer, the producer-to-consumer boundary, the expected and
actual result, the premise-removal or mutation result, and the final
classification.

Universal gate rules:

- a build pass never overrides a failed semantic gate;
- a theorem with an arbitrary certificate premise is conditional;
- a zero/default value requires a source proof;
- a bytecode transcription is not automatically a Lean theorem;
- a passing positive test is insufficient without a relevant negative mutation;
- a same-agent prior result is not independent audit evidence;
- the final readiness label must equal the worst unresolved dependency.

Gate I must reject `READY_FOR_USER_APPROVAL` when:

- any funnel arrow lacks a producer-to-consumer theorem;
- the worked arrow is absent or trivial;
- any source field is supplied only by an arbitrary caller;
- any physical term uses an unjustified neutral default;
- any runtime delay is unbounded;
- any mutation bypasses the actual adapter or transition;
- any independent final audit is missing.

### Gate A: artifact and provenance debugging

- Force fresh Lean and LaTeX builds; do not rely on timestamps or stale output.
- Run the forbidden-token scan and inspect every match.
- Run `#print axioms` for every major theorem.
- Compare recorded jar/class hashes with the files actually used by the
  bytecode traceability document.
- Resolve every compiler warning, especially unused theorem premises.
- Keep the gate failed for any axiom, stale artifact, hash mismatch, or
  unexplained warning.

### Gate B: claim and scope debugging

- Build a matrix containing every LaTeX claim, Lean theorem, hypothesis,
  runtime contract, and excluded case.
- Remove one hypothesis at a time and verify that the claim no longer holds.
- Test both route orientations, wrong-way motion, target crossing,
  curved/slack consists, and unavailable route data.
- Compare each theorem statement with the prose immediately surrounding it.
- Downgrade or withdraw prose that is stronger than its theorem.

### Gate C: mathematical debugging

- Print each theorem type and verify that an actual state transition appears.
- Create a coordinate, sign, and unit table for every central equation.
- Evaluate forward and reverse orientations symbolically.
- Test grade, traction, braking, target crossing, and zero-velocity cases.
- Independently derive the terminal-entry guard and compare every term with
  the Lean definition.
- Mutate one sign, unit conversion, coefficient, or horizon bound and require
  the relevant theorem or test to fail.

### Gate D: model-consistency debugging

- Compare every LaTeX equation with the bytecode ledger and Lean definition.
- Trace every physical value through dynamic observation, static catalogue,
  configuration, and runtime certificate sources.
- Reject proof-relevant zero/default values without a source proof.
- Run a branch table for grade, resistance, adhesion limitation, wheel slip,
  both brake channels, curvature, slack, push/pull, and particle aggregation.
- Mutate one source coefficient or branch and verify that the corresponding
  result changes.
- Verify that geometry, graph intervals, markers, and physics use the same
  identifiers and units.

### Gate E: controller-refinement debugging

- Trace one command from route localization through front-coupler state,
  allocation, normalization, the IR command path, and the next plant state.
- Inspect throttle, train brake, independent brake, emergency brake,
  saturation, slew, anti-windup, and controller memory separately.
- Mutate each command field and verify the plant transition changes where IR
  semantics require it.
- Search for identical duplicate definitions or `rfl` aliases at the API
  boundary.
- Test simultaneous positive throttle and braking, route invalidation, and
  profile mismatch.

### Gate F: objective debugging

- Define the admissible controller class independently of the selected policy.
- Evaluate the objective for the proposed controller and a competing
  admissible controller.
- Mutate the selected gains or command policy and check that the objective is
  independent of the answer being evaluated.
- Withdraw optimality if no independent objective and competitor exist.

### Gate G: runtime-boundary debugging

- Separate deterministic jar timing from Lua, detector, radio, scheduler,
  server-lag, and wall-clock timing.
- List the source of every sample-age, command-delay, pressure-delay, and
  route-change bound.
- Inject stale, missing, NaN, infinite, out-of-range, and delayed inputs.
- Mutate the active route revision and verify route-local invalidation.
- Reduce a timing bound until the terminal guard fails and verify fail-closed
  behavior.
- Keep nominal jar substep timing separate from measured external latency.

### Gate H: adversarial-validation debugging

- Run a valid baseline through the actual source adapter, geometry mapper,
  profile builder, controller, and transition.
- Apply one mutation at a time to source fields, definition IDs, coefficients,
  force branches, brake channels, coupler geometry, linkage correction,
  spline splitting, stale-data checks, and timing bounds.
- Use an independent bytecode ledger or reference evaluator.
- Require every mutant to fail validation or change an independently expected
  result.
- Treat any unexpectedly passing mutant as a blocking defect.

### Gate I: readiness debugging

- Build a readiness table with one row for every funnel arrow and every Gate
  A–H result.
- Link each row to its Lean theorem, LaTeX statement, source fact, runtime
  contract, and test evidence.
- Mark each item as proved, assumed, runtime-checked, future work, or
  unsupported.
- Search reports for readiness claims supported only by compilation, copied
  certificates, default values, or disconnected theorems.
- Set `NOT_READY` if any required arrow, source connection, physical bound,
  timing bound, or transition refinement is assumed or disconnected.

## Ordered Ralph implementation tasks

The implementation ledger must execute these tasks in order. A task may not be
marked `verified` until its implementation checks and fresh read-only audit
both pass.

### R0: baseline and provenance freeze

Record jar/version/class hashes, current build/warning/axiom/forbidden-token
state, and current readiness. Set the initial readiness result to `NOT_READY`.
Confirm that production Lua is unchanged.

### R1: source ledger and bytecode equations

Complete bytecode evidence for API, geometry, force, brake, particle, linkage,
and timing facts. Record units, branch order, Lean use, LaTeX citation, and
classification. External bytecode facts must not be misclassified as Lean
theorems.

### R2: geometry and worked arrow

Implement the sound trace-to-centreline certificate, dimensionally valid
residual bound, cubic/orientation/arc/tangent/grade/curvature contracts, and
the compiled spline-to-graph worked theorem with endpoint, orientation,
interval, and mutation tests.

### R3: topology and graph

Implement real continuation, extension, split, overlap, connection, crossing,
overpass, and unresolved transitions. Ensure unresolved geometry is unroutable,
graph intervals are valid, and marker direction and active-route validation are
connected.

### R4: profile and configuration adapter

Implement ordered detector observations, static definition/addon resolution,
configuration/runtime records, brake-efficiency provenance, cogging behavior,
fail-closed unknown data, profile fingerprints, and profile mutations.

### R5: source-derived physical model

Implement the Java-8 force/friction equations, `brakeMultiplier` branches,
separate brake channels, source-derived wheel slip, and non-default grade,
rolling, direct, interference, and near-zero terms. Run equation mutations.

### R6: particle and consist transition

Implement per-particle source configuration, force/friction, direction,
linkage, push/pull, slack, collision, position/velocity, front/rear couplers,
and `SimulationState.next` movement semantics. Prove exact invariants or a
conservative refinement bound.

### R7: coordinate, front coupler, and controller

Implement route-directed coordinates, forward/reverse transformation,
source-derived front-coupler localization, wrong-way/target-crossing
rejection, controller state, throttle, both brake channels, emergency logic,
saturation, slew, anti-windup, and command-to-plant refinement.

### R8: uniform guard and arrival

Prove the delay-plus-stopping bound, envelope preservation, no-crossing,
velocity convergence, actual terminal arrival, stable holding, and fail-closed
invalidation over all certified branches.

### R9: numeric and runtime boundary

Implement finite/NaN/infinity handling, conversion enclosures, sample age,
command delay, pressure delay, route revision, detector timing, runtime failure
states, and the distinction between theoretical and measured bounds.

### R10: adversarial audit and mutations

Audit Classes 1–17 and run source-adapter, geometry, profile/configuration,
force-branch, controller/transition, and timing mutations against an independent
oracle or bytecode ledger.

### R11: LaTeX, reports, and traceability

Map every LaTeX claim to a Lean theorem, bytecode fact, runtime contract,
assumption, or withdrawal. Make audit, implementation, readiness,
traceability, and test-vector reports agree.

### R12: final independent audit

Use a fresh read-only context to rerun Gates A–I, document all blockers, and
emit `DONE` only if every required condition passes.

## LaTeX revisions

Retain the chapter structure, but revise:

- `Geometry: traced centreline to spline`: define every symbol directly in the LaTeX geometry chapter, repair the dimensional residual bound, and classify all fit/arc/curvature statements.
- `Graph, markers, and route locality`: describe actual split/extension/connection semantics and route constraints.
- `Detector profile`: separate `info()` fields, definition-catalogue fields, configuration fields, and runtime measurements.
- `Directed stopping coordinate`: include orientation transformation and front-coupler derivation.
- `IR physics derivation`: reproduce the exact source equations and branch order from `SimulationState`, `Configuration`, `EntityMoveableRollingStock`, and `Consist$Particle`.
- `Combined command and plant transition`: replace the abstract Euler plant with the source-connected transition or an explicitly proven conservative refinement.
- `Uniform guard and safety envelope`: use dimensionally valid delay/adverse-motion terms and explicitly derived force bounds.
- `Arrival, holding, and failure states`: prove actual target arrival separately from no-crossing.
- `Claim inventory`: classify every result honestly as Lean-proved, bytecode-derived, certified assumption, runtime contract, future obligation, or withdrawn.
- `Readiness`: remove `READY_FOR_USER_APPROVAL` while any source adapter, geometry certificate, timing bound, plant refinement, or mutation gate remains only assumed or disconnected.

## Deliverables and acceptance

Update:

- `pid-formal-proof.tex`;
- Lean sources under `pid-proof-lean/`;
- `pid-audit-report.md`;
- `pid-readiness-report.md`;
- `pid-implementation-plan.md`;
- `pid-bytecode-traceability.md`;
- `pid-test-vectors.md`;
- addon/profile compatibility instructions.

Do not modify production Lua.

Acceptance requires:

- `lake build` with no warnings;
- `lake env lean Axioms.lean`;
- complete axiom audit for every major theorem;
- forbidden-mechanism scan;
- forced fresh LaTeX rebuild;
- source-connected mutation suite;
- independent bytecode/model comparison vectors;
- no tautological certificate or invalid-boundary theorem;
- no optimistic zero defaults;
- no `rfl` theorem presented as source refinement;
- honest readiness classification.

The result must be:

- `NOT_READY` if any required source connection, physical bound, timing bound, or transition refinement is absent;
- `CONDITIONALLY_READY` only when the proof is complete but named runtime measurement contracts remain;
- `READY_FOR_USER_APPROVAL` only when every required proof connection is established, every remaining runtime contract is explicit and bounded, and no required claim is merely assumed, defaulted, or disconnected.

The current implementation should therefore be treated as a substantially improved scaffold, but the next agent must perform a substantive proof-core rewrite rather than a cosmetic refinement.
