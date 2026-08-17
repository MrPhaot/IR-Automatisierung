# Final proof-revision readiness report

Date: 2026-08-16
Status: **NOT_READY**

This is the final artifact classification for the current task. It is not
approval to deploy or modify the production Lua. `programs/train_controller.lua`
and all other production Lua files were left unchanged. The authoritative
plans and prompts were not modified.

## Completed proof artifacts

- `pid-proof-lean/IRRevision.lean`: normative source-connected geometry,
  topology, graph, marker, detector profile, exact force ledger, coupler,
  combined command, source-shaped particle transition, numeric/timing
  boundary, robust guard, arrival, holding, and route fail-closed model.
- `pid-proof-lean/IRRevisionTestVectors.lean`: exact positive and negative
  vectors for every connected boundary.
- `pid-proof-lean/Axioms.lean`: theorem axiom inventory.
- `pid-formal-proof.tex`: complete variable definitions and theoretical models
  for spline reconstruction, graph building, stations/routes, profile,
  physics, controller/plant, arrival, timing, and failure states.
- `pid-bytecode-traceability.md`: root Java-8 provenance, branch offsets,
  hashes, and theorem-to-source mapping.
- `pid-test-vectors.md`: reproducible geometry, source-adapter, physics,
  controller, transition, timing, arrival, and mutation suite.
- `pid-audit-report.md`: Gates A--I, anti-cheating, classification, and
  remediation record.
- `pid-implementation-plan.md`: connected implementation contract and ledger.

## Required worked theorem

The required theorem is:

```text
IRRevision.validated_spline_to_directed_routing_edge
```

Location: `pid-proof-lean/IRRevision.lean`, geometry producer section.

Producer/consumer path:

```text
TraceObservation
 -> traceCentre / traceResidualBound / traceFitRowsValid
 -> splineCandidateValid / validatedSplineProducer
 -> cubicPosition / cubicReverse / cubic_reverse_position
 -> directedCoordinateOfParameter / edgePointAt / directedEdge
```

The theorem consumes the checked producer equality
`validatedSplineProducer c = some v`, not an arbitrary caller-supplied
certificate. It proves:

- same stable spline ID and source trace IDs;
- forward and reverse orientation;
- forward/reverse endpoint correspondence;
- directed interval-coordinate mapping for every parameter in `[0,1]`;
- point correspondence through the reversed cubic;
- preservation of an arbitrary pointwise localization inequality and the
  producer’s localization error.

`#print axioms` output is only:

```text
[propext, Classical.choice, Quot.sound]
```

The LaTeX citation is the “Required spline-to-edge proof” subsection in
`pid-formal-proof.tex`. Mutation vectors reverse orientation, alter interval
mapping, remove/alter fitting validity, and use a different spline ID; the
dependent result changes or fails.

The graph-network consumer theorem
`IRRevision.graph_network_consumes_only_source_validated_splines` applies the
same producer/consumer check to multi-spline assembly. It proves every emitted
edge comes from a candidate whose `validatedSplineProducer` output supplies the
`ValidatedSpline`; duplicate and empty stable IDs are rejected. Its transitive
axiom set is `[propext, Classical.choice, Quot.sound]`.

## Gate status

| Gate | Status | Honest result |
|---|---|---|
| A | conditional pass | artifacts, root-Java-8 hashes, Lean theorem inventory, forbidden scan, and clean LaTeX build are present; no live runtime approval remains |
| B | pass at model boundary | spline/graph/profile/controller/safety/arrival/feasibility/optimality claims are separate; optimality is withdrawn |
| C | conditional pass | explicit coordinates, front coupler, source force ledger, combined command, uniform guard, and separate arrival theorem are present; live source refinement remains |
| D | conditional pass | Lean, LaTeX, traceability, vectors, IDs, markers, particles, and force branches are aligned; external adapter comparison remains |
| E | not fully passed | source-shaped command-to-next-state model exists, but complete Java `SimulationState.next` and all `Consist` linkage/collision branches are not identity-refined |
| F | conditional pass | robust-arrival safety objective exists; unsupported formal optimality is withdrawn; uniform physical bound still needs runtime certification |
| G | conditional pass | numeric/profile/timing/route fail-closed producers exist; external detector, radio, scheduler, pressure, and route-change measurements remain |
| H | conditional pass | exact-rational adversarial suite covers required mutation families; live Java/Lua mutation harness is not yet run |
| I | **not passed** | required runtime/source/refinement connections remain future obligations; `READY_FOR_USER_APPROVAL` is forbidden |

Because Gate I is not passed, the overall status is `NOT_READY`. This is not a
compilation failure; it is the required scope/readiness distinction.

## Result classification

### Proved by Lean

The exact-rational model proves trace-fit checking, cubic orientation and the
validated-spline-to-directed-edge theorem, topology separation predicates,
marker interval/approach mapping, ordered catalogue/fingerprint predicates,
source-field preservation, exact force-ledger identities and wheel-slip branch,
front-coupler localization relation, invalid numeric/API rejection, source
command/particle next-state existence, timing fail-closed predicates, guard
rejection, one-step no-crossing, terminal zero state, velocity monotonicity,
stable-window rejection, IR rest holding, and invalid-route fail closed—under
the premises shown in `IRRevision.lean`.

### Derived from bytecode

The root force branches, signed grade/traction, constants `0.70`, `0.42`, and
`0.25`, brake channels, `brakeMultiplier`, wheel-slip threshold, movement
direction, unchanged-position branch, coupler geometry inputs, cubic
Bernstein/derivative, sampled arc length, detector event, CommonAPI fields,
normalization, locomotive overrides, and particle/linkage order are recorded
from Java-8 root bytecode and complete decompiler inputs.

### Certified model assumptions

The tracer offset/residual, spline fitting and arc-length error, topology
observations, runtime force lower bound, positive traction upper bound,
curvature/slack/push-pull bounds, numeric enclosure, and exact source-field
completeness are assumptions that must be supplied by checked producers.

### Runtime contracts

The detector must deliver ordered UUID events and immediate `info()`, the
profile must remain immutable, command/sample/pressure/detector/route timing
must be bounded, radio/API values must be finite, route revisions must be
observed, and all missing/mutated values must report and fail closed.

### Future Lua implementation obligations

The production implementation must persist/reconstruct spline geometry and
topology, derive the graph and directed markers, catalogue and freeze the
profile, localize the front coupler, send all command channels together,
measure/certify the full force and delay bound, implement stable holding, and
run the vectors against actual curved/slack/push-pull, adhesion, wheel-slip,
detector-delay, route-mutation, and profile-mutation cases.

### Unsupported or withdrawn

The old PID proof, any theorem disconnected from `IRRevision`, formal
time/energy/jerk optimality, exact Java floating-point correctness, complete
Java linkage/collision identity, hidden track topology, and deployment approval
are unsupported or withdrawn.

## Handoff decision

`NOT_READY` is the honest handoff state. The proof artifacts are substantially
more implementation-ready than the obsolete PID proof, but a user-approval
or deployment claim would still rely on the unimplemented and unmeasured
obligations above. No production Lua was modified to conceal those gaps.
