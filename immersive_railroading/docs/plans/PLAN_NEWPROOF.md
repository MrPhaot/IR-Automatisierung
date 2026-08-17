# Handoff Plan: Geometry- and Physics-Guided IR Train Proof

## Objective and boundaries

Replace the PID-centered proof with a proof-guided contract for:

```text
IR source physics
→ traced track-center spline model
→ directed routing graph
→ detected consist profile
→ front-coupler stopping reference
→ combined throttle/brake controller
→ IR plant transition
→ robust terminal arrival
```

The proof target is robust arrival within a derived computational tolerance. Formal optimality is not required unless it is genuinely established.

Do not modify:

- `immersive_railroading/programs/train_controller.lua`;
- any production Lua file;
- unrelated dirty-worktree files;
- `PLAN_PROOFREPAIR.md` as part of the implementation.

The agent may inspect Lua and specify the exact future changes required.

## Required Preparation and Authority Order

`PLAN_NEWPROOF.md` is the sole authoritative specification for this task.

If any other plan, proof, transcript, or existing theorem conflicts with this
document or with verified Java-8 root-bytecode behavior, discard it.

### Read first, before inspecting existing proofs

Read:

- `immersive_railroading/AGENTS.md`;
- `README.md`;
- `immersive_railroading/README.md`;
- `immersive_railroading/docs/README.md`;
- `immersive_railroading/docs/runtime.md`;
- `immersive_railroading/docs/control-model.md`;
- this `PLAN_NEWPROOF.md`;
- the extracted jar manifest and relevant Java-8 root classes under
  `immersive_railroading/.cache/jar/`.

Verify the Minecraft/IR versions, Java-8 root class selection, relevant class
hashes, and all physical/API facts listed in this plan.

First establish independently:

- the spline and track-centre model;
- the separation between spline geometry and routing graph;
- detector-based consist profiling;
- the directed stopping coordinate;
- the front-coupler target;
- the combined throttle/brake plant transition;
- the runtime contracts and failure states.

### Existing proof artifacts

The following are deliverables to replace or update, not sources of truth:

- `immersive_railroading/docs/plans/pid-formal-proof.tex`;
- `immersive_railroading/docs/plans/pid-proof-lean/`;
- `immersive_railroading/docs/plans/pid-audit-report.md`;
- `immersive_railroading/docs/plans/pid-implementation-plan.md`.

Inspect them only after independently establishing the new model. Use them for:

- file and build structure;
- migration inventory;
- identifying obsolete claims;
- preserving useful tests or tooling;
- verifying that the final deliverables compile.

Do not copy their equations, assumptions, theorem statements, or readiness
claims without re-deriving and re-validating them.

### Omitted historical context

Do not include these in the initial proof-authoring context:

- `PLAN_PROOFREPAIR.md`;
- `HANDOFF_PROOFREWRITE.md`;
- older proof plans;
- historical session transcripts;
- previous proof arguments.

They are non-authoritative and may contaminate the new geometry-based proof with
obsolete PID assumptions. Consult them only if a later file-migration question
cannot be resolved from the authoritative sources.

## 1. Track-centre spline model

The spline model is the authoritative geometric representation. Do not conflate it with the routing graph.

Represent every physical track section as a 3D cubic Bézier spline with:

- four control points;
- directed and reverse traversal orientations;
- arc-length representation or certified arc-length approximation;
- tangent, grade, and curvature information;
- fitting error;
- source trace metadata;
- optional IR builder metadata;
- stable spline identifier.

Straight track is represented as a degenerate cubic Bézier. IR turn segments must not be treated as exact circles unless justified; `CubicCurve.circle()` generates a cubic approximation.

### Tracer reference

The tracer does not use the front coupler as its geometric reference.

The front coupler is used only by the stopping controller.

The tracer uses a compact locomotive and derives the most accurate possible track-centre estimate from:

- remote `getPos()`;
- the compact tracer’s stock definition;
- its bogey/front/rear offsets;
- its yaw/direction;
- successive samples;
- the exact IR movement semantics;
- a documented correction or residual bound.

The proof must distinguish:

```text
raw IR entity position
→ estimated track-centre path
→ front-coupler position for stopping
```

Do not claim that `getPos()` is literally the F3 hitbox or automatically the exact rail centreline. Prove or bound the centreline estimator’s deviation.

The trace record must contain at least:

- timestamp or tick;
- raw position;
- speed;
- heading/direction;
- tracer stock definition ID;
- stock UUID;
- sampling validity;
- tracer configuration;
- estimated centreline point and error bound.

The centreline error bound must include:

- sampling spacing;
- route curvature;
- model/reference offset;
- floating-point and fitting error;
- missing or delayed observations.

## 2. Spline operations and incremental reconstruction

New traces are added to the spline model, not directly to the graph.

The mapper must support repeated runs and compare each new trace with existing splines. It must be able to:

- extend an existing spline;
- continue an existing spline;
- fit a new spline;
- split a spline geometrically where required;
- identify overlap;
- identify intersections;
- preserve separate paths;
- delete or rebuild spline sections;
- attach stable metadata and source traces.

Use 3D distance, tangent, curvature, and arc-length matching. Do not merge paths merely because their 2D projections intersect.

Automatic geometric classification should distinguish:

- same spline continuation;
- spline extension;
- genuine shared geometric connection;
- isolated same-level intersection;
- overpass with height separation;
- unresolved ambiguity.

“Ordinary continuation” means that the new trace maps to the same spline interval or extends it without creating a new geometric node.

A crossing is not an ordinary continuation. If two independent spline paths cross at one point but both continue along their own paths, preserve them as separate paths and do not create a shared physical connection.

An overpass is automatically separate when 3D separation exceeds the certified tolerance, even if the 2D projections overlap.

Manual input is permitted only when geometry and already-observed traces cannot determine topology, for example:

- an untraced branch;
- coincident same-level paths with indistinguishable geometry;
- hidden connectivity not exposed by the runtime.

Such cases must be marked unresolved until classified. They must not silently become connected.

## 3. Graph derived from splines

The graph is a routing abstraction built from the validated spline model. It is not the source of geometric truth and is not used to fit or alter splines.

Graph edges reference spline IDs and arc-length intervals. Graph vertices are derived from:

- actual spline endpoints;
- validated geometric junctions;
- user-approved switch/merger nodes;
- station/signal markers;
- other routing-relevant markers.

Normally each physical spline has symmetric bidirectional routing edges.

Stations and signals impose directed approach constraints. The editor stores:

- the selected spline;
- the mapped arc-length point;
- the permitted approach orientation;
- the station/signal type and metadata.

The editor maps a station/signal point to the closest spline only within an explicit tolerance. If the player places it too far from the intended track or position, the editor rejects it or reports player error; the proof does not silently correct it.

At a configured station or signal, the corresponding graph edge or spline interval becomes direction-constrained according to the stored approach orientation. The same physical network may still support the opposite direction elsewhere.

The train must validate only the spline sections, graph vertices, and graph edges of its active route. It must not scan the entire graph during operation.

If an active route section changes:

1. invalidate the current route;
2. invoke the standard route-finding procedure against the latest graph;
3. stop and report the problem if no valid route exists.

Physical geometry changes belong to spline/network rebuilds. Train occupancy is a separate dynamic routing state and must not trigger spline reconstruction.

## 4. Train profile and detector catalogue

Use the detector-based semi-automatic catalogue process.

For every stock passing a detector:

- consume `ir_train_overhead`;
- record the `stock_uuid`;
- immediately call detector `info()`;
- record the stock definition ID;
- record weight, direction, speed, and available brake/locomotive data;
- preserve passage order.

The detector event identifies the individual stock instance. `info()` supplies the stock definition and current data. `consist()` remains an aggregate validation source.

Catalogue speed must be conservative, initially no greater than approximately 10 km/h unless a derived detector-spacing bound permits more. Derive the bound from:

- detector effective length;
- event/response latency;
- minimum stock spacing;
- required `info()` response time.

The resulting profile must contain the ordered per-stock definitions and all geometry/physics data required by the stopping proof.

The profile is immutable during a run. A changed consist is a player-managed configuration error:

- report profile mismatch;
- stop the program;
- require the player to update and recatalogue the profile.

## 5. Directed stopping coordinate and front-coupler target

Define a route-directed coordinate \(s\) that increases along the selected directed route.

The spline model supplies the track coordinate. The front coupler is used only for stopping.

Define:

\[
x = s_{\mathrm{target}} - s_{\mathrm{front\ coupler}}
\]

and:

\[
v_s = \frac{d s_{\mathrm{front\ coupler}}}{dt}.
\]

The configured station or signal has one permitted approach direction. The theorem is parameterized by that directed approach. It must support either physical/world orientation by selecting the appropriate directed spline orientation, but it must not claim that an incorrectly oriented station is valid.

The stopping theorem applies only when:

\[
x > 0 \quad\text{and}\quad v_s > 0.
\]

Away-motion, wrong-way motion, target crossing, or unavailable route direction must enter route recovery or fail-closed behavior.

The front coupler position must be derived from the stock definition and IR coupler semantics, not from the visible model center.

## 6. Exact IR physics

Derive the signed force equation line by line from the Java-8 root bytecode.

The proof must include:

- steel/steel static friction `0.70`;
- steel/steel kinetic friction `0.42`;
- steel/cast-iron kinetic brake-shoe friction `0.25`;
- brake-system efficiency;
- locomotive cogging overrides;
- current and design mass;
- grade force;
- tractive force;
- rolling resistance;
- direct resistance;
- interference resistance;
- train-brake channel;
- independent-brake channel;
- input normalization and clamping;
- adhesion limitation;
- wheel-slip transition;
- `brakeMultiplier`;
- coupler slack;
- push/pull interactions;
- per-particle consist aggregation;
- discrete simulation updates.

Record that:

- base `getBrakeSystemEfficiency()` derives from configured brake-shoe friction;
- cogging locomotives can override brake-system and adhesion efficiency;
- base brake adhesion efficiency is distinct from brake-system efficiency;
- `brakeMultiplier` defaults to `1.0` but deployed configuration is authoritative.

Lean and LaTeX must use the same constants, signs, branches, and aggregation semantics.

## 7. Combined throttle-and-brake controller

The proof must not assume zero throttle after stopping commitment.

It must model and prove the actual intended command policy with simultaneous:

- throttle;
- train brake;
- independent brake;
- emergency braking where applicable.

The controller transition must include:

```text
spline localization
→ front-coupler target error
→ consist/length/curvature state
→ throttle allocation
→ brake allocation
→ combined IR force
→ plant state transition
→ next controller state
```

The stopping proof must account for the fact that positive throttle reduces net braking. The certified stopping bound must use either:

- the exact commanded throttle/brake policy; or
- a conservative upper bound on positive tractive force over the complete horizon.

It is not acceptable to prove a brake-only plant while the implementation is allowed to apply throttle simultaneously.

The proof must cover:

- cruise-to-stopping transition;
- throttle/brake coexistence;
- station geometry and approach orientation;
- consist length;
- curved/slack consist effects;
- terminal speed regulation;
- terminal braking/holding;
- command saturation and slew behavior;
- route invalidation;
- profile mismatch.

If the controller intentionally forces throttle to zero in a particular certified branch, that must be proved as an output of the supervisor and not silently assumed.

## 8. Uniform stopping bound and arrival

Derive a braking lower bound valid across the complete delay-plus-stopping horizon.

Include:

- all physical force branches;
- grade;
- speed changes;
- wheel slip;
- pressure delay;
- observation age;
- command delay;
- curvature;
- slack;
- push/pull interactions;
- consist-specific braking;
- localization and computation error;
- positive tractive force when throttle is allowed.

The terminal-entry guard must contain:

```text
observation/actuation distance
+ adverse motion during delay
+ certified stopping distance
+ geometry/localization error
+ terminal tolerance
```

Prove that the stopping transition is entered only when the guard is satisfied. If it is already violated, return an explicit unavailable/fail-closed result.

Separate the following theorems:

- stopping-envelope preservation;
- no-crossing safety;
- velocity convergence;
- terminal arrival;
- settling/holding;
- route feasibility.

The mathematical terminal state is \(v_s=0\). Runtime acceptance requires:

- speed within a derived deadband;
- front-coupler position within \(\varepsilon_{\mathrm{stop}}\);
- stability for the required number of samples.

Derive:

\[
\varepsilon_{\mathrm{stop}}
\ge
\varepsilon_{\mathrm{trace}}
+\varepsilon_{\mathrm{fit}}
+\varepsilon_{\mathrm{coupler}}
+\varepsilon_{\mathrm{sample-age}}
+\varepsilon_{\mathrm{command-delay}}
+\varepsilon_{\mathrm{numeric}}.
\]

Do not choose a tolerance merely because it has one or two decimal places.

## 9. Runtime contracts

Document and, where possible, prove or test:

- maximum accepted sample age;
- maximum command delay;
- route spline/vertex validation interval;
- detector catalogue speed;
- spline fitting tolerance;
- front-coupler localization tolerance;
- terminal position tolerance;
- terminal speed tolerance;
- profile validity;
- route-change behavior;
- unavailable-data behavior.

A large configured radio range may remove ordinary distance failures, but it does not eliminate stale, unavailable, or delayed observations.

Persistent geometry, profile, route, or state errors must:

1. emit an in-game message;
2. stop the controller;
3. require player resolution.

Do not impose a separate universal operational speed theorem. The stopping guard must be evaluated at the current measured speed and fail closed if its assumptions are not satisfied.

## 10. Lean anti-cheating audit

Apply all of these proof-integrity classes.

### Class 1: prohibited mechanisms

Search for:

- `sorry`;
- `admit`;
- project-specific axioms;
- unreviewed `opaque`;
- `unsafe`;
- `cast`;
- `ofReduceBool`;
- equivalent escapes.

Run `#print axioms` for every geometry, physics, safety, stopping, refinement, stability, and optimality theorem.

### Class 2: vacuous or assumption-leaking theorems

Reject conclusions already stored in premises. Every safety result must reference an actual transition relation. Perturb essential premises and confirm the result fails.

### Class 3: specialization presented as generality

Compare every quantified LaTeX parameter with the Lean theorem type. Numerical cases must be labeled examples, not general results.

### Class 4: model-equation mismatch

Maintain an equation-to-bytecode-to-Lean mapping. Mutation of a physical coefficient must alter the relevant result.

### Class 5: disconnected definitions

Build a dependency graph. Theorems must depend on the actual spline, stock profile, physics, controller, transition, and runtime-contract definitions.

### Class 6: tautological optimality

The objective must be independent of the selected controller. If robust arrival is the only established result, withdraw optimality claims.

### Class 7: sign, algebra, and dimensional errors

State coordinate, route orientation, units, and force signs before deriving equations. Test both permitted approach orientations and wrong-way motion.

### Class 8: temporal/hybrid under-approximation

Include branch transitions, saturation, throttle/brake coexistence, delay, sampling, wheel slip, curved/slack behavior, and discrete plant updates.

### Class 9: API/refinement failure

Model the actual detector, radio, normalization, command, observation, front-coupler, and next-state path. Alias theorems are insufficient.

### Class 10: provenance drift

Record jar version, Java target, root class selection, hashes, configuration source, and every bytecode-derived value.

### Class 11: numerical unsoundness

Prove conversion bounds from runtime doubles/floats to proof values. Cover NaN, stale data, rounding, overflow, and invalid configuration.

### Class 12: scope confusion

Separate geometry reconstruction, routing, safety, arrival, feasibility, and optimality. Do not claim complete network or addon coverage unless actually established.

### Class 13: insufficient negative/mutation testing

Test:

- wrong route direction;
- target crossing;
- away-motion;
- invalid station mapping;
- wrong graph edge;
- changed spline;
- overpass/crossing mutations;
- changed mass;
- changed brake coefficient;
- changed `brakeMultiplier`;
- changed grade;
- changed delay;
- changed throttle;
- changed slack/curvature bounds;
- invalid or mismatched consist profile.

Run:

```bash
lake build
lake env lean Axioms.lean
rg -n 'sorry|admit|axiom|opaque|unsafe|cast|ofReduceBool' immersive_railroading/docs/plans/pid-proof-lean
```

## 11. Acceptance gates

### Gate A: artifact and provenance integrity

Pass only if:

- LaTeX compiles;
- Lean builds cleanly;
- forbidden mechanisms are absent;
- theorem axioms are audited;
- jar version, Java target, class variant, and hashes are recorded;
- unrelated worktree changes remain untouched.

### Gate B: claim and scope integrity

Pass only if:

- spline geometry, graph routing, and controller physics are explicitly separated;
- station/signal approach orientation is explicit;
- normal curved/slack operation is covered or explicitly unavailable;
- claims do not silently assume the opposite station approach;
- safety, arrival, feasibility, and optimality are separated.

### Gate C: mathematical integrity

Pass only if:

- directed coordinates and signs are explicit;
- front-coupler localization is defined;
- force equations are bytecode-derived;
- units and parameter domains are correct;
- the stopping guard is uniform over the horizon;
- the combined throttle/brake transition is proved;
- arrival is separately proved from no-crossing safety.

### Gate D: model-consistency integrity

Pass only if:

- Lean, LaTeX, and IR agree on spline geometry;
- spline-to-graph references are consistent;
- station/signal markers map to explicit spline coordinates;
- curvature, slack, particle aggregation, brake channels, and force branches agree;
- mutation tests change the expected results.

### Gate E: controller-refinement integrity

Pass only if:

- Lean connects spline localization, front-coupler target, controller state, throttle, both brake channels, allocation, saturation, IR plant transition, and next state;
- station geometry and consist length are represented;
- future Lua changes are listed precisely;
- production Lua remains unchanged.

### Gate F: objective integrity

Pass only if:

- robust arrival is proved with a meaningful tolerance;
- any efficiency claim has an independent metric;
- optimality is proved independently or withdrawn.

### Gate G: runtime-boundary integrity

Pass only if:

- route-local spline/vertex validation is specified;
- route-change detection latency is bounded;
- front-coupler, sample-age, command-delay, detector, and profile contracts are explicit;
- invalid data leads to an explicit fail-closed state.

### Gate H: adversarial validation

Pass only if:

- valid and invalid traces are tested;
- both route orientations are tested;
- overpass and crossing cases are tested;
- station/signal misplacement is rejected;
- throttle/brake combinations are tested;
- wheel slip, grade, slack, curvature, delay, stale data, and profile mismatch are tested;
- relevant mutations fail the checks.

### Gate I: implementation-funnel readiness

`READY_FOR_USER_APPROVAL` is allowed only when:

- the spline model is the geometric source of truth;
- the routing graph is derived from, but not conflated with, the spline model;
- the front-coupler target is connected to the stopping proof;
- the detector-based profile is connected to the physics;
- simultaneous throttle/brake behavior is proved;
- route-local validation and replanning are specified;
- the IR plant transition is connected to the controller;
- no required item is merely assumed, silently excluded, or disconnected from Lean.

Otherwise report:

- `CONDITIONALLY_READY`, with named runtime gates outstanding; or
- `NOT_READY`, with blocking proof/refinement failures.

## 12. Deliverables and tests

Update only proof and planning artifacts:

1. corrected or rewritten `pid-formal-proof.tex`;
2. Lean proof under `pid-proof-lean/`;
3. updated `pid-audit-report.md`;
4. updated `pid-implementation-plan.md`;
5. final readiness report;
6. jar manifest and theorem-to-bytecode traceability;
7. reproducible geometry, physics, controller, and arrival test vectors.

Test at minimum:

- straight, turn, slope, and cubic Bézier spline reconstruction;
- compact-tracer centreline estimation;
- repeated traces extending existing splines;
- continuation, overlap, connection, crossing, and overpass;
- switch and merger inference;
- bidirectional spline traversal;
- station/signal marker mapping and orientation;
- detector order and repeated stock types;
- profile mismatch;
- normal curved/slack/push-pull consists;
- train-brake and independent-brake paths;
- simultaneous throttle and braking;
- adhesion-limited braking and wheel slip;
- grade and direct resistance;
- stale observations and command delay;
- active-route spline/vertex mutation;
- route invalidation and replanning;
- target crossing and away-motion;
- robust arrival within the derived position and speed tolerances.

The final report must classify every result as:

- proved by Lean;
- derived from bytecode;
- certified model assumption;
- runtime contract;
- future Lua implementation obligation;
- unsupported or withdrawn.
