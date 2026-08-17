# Independent audit of the geometry/IR-physics proof revision

Audit date: 2026-08-16. Authority: `PLAN_NEWPROOF.md` with
`PLAN_NEWPROOF_REVISION.md` overriding it. Previous PID proof and readiness
claims are migration artifacts and are not evidence.

## Overall result

`NOT_READY`

The normative Lean model, exact vectors, provenance ledger, and reports are
source-connected at their stated abstraction boundaries. The unchanged
production Lua does not yet implement those boundaries, and live Java/Lua
floating-point, detector, route-change, pressure, linkage/collision, and
uniform physical-bound measurements are not available in this proof task.
Therefore a passing Lean/LaTeX build is not treated as acceptance.

## Reproducers and baseline results

Run from `immersive_railroading/docs/plans/pid-proof-lean`:

```bash
lake build
lake env lean Axioms.lean
lake env lean IRRevisionTestVectors.lean
rg -n 'sorry|admit|axiom|opaque|unsafe|cast|ofReduceBool' .
```

Run from the repository root:

```bash
sha256sum -c immersive_railroading/docs/plans/pid-physics-contract-manifest.sha256
latexmk -gg -pdf -interaction=nonstopmode docs/plans/pid-formal-proof.tex
```

Final rerun results on 2026-08-16:

```text
lake build                         PASS (9 jobs, no Lean warnings)
lake env lean Axioms.lean          PASS
lake env lean IRRevisionTestVectors.lean PASS
sha256sum manifest                 PASS (6/6 inputs)
latexmk -gg ... pid-formal-proof.tex PASS (3 pdflatex passes)
git diff --check (scoped proof paths) PASS; global check reports one pre-existing
                                      trailing-space line in `Notizen`, untouched
production Lua scope               PASS: no train_controller.lua change
```

The final LaTeX log contains no TeX errors, unresolved references, or
`Overfull`/`Underfull \hbox` diagnostics.

| Check | Expected | Actual classification |
|---|---|---|
| Lean build | clean build | PASS; 9 jobs, no Lean warnings |
| `Axioms.lean` | theorem inventory with no project escape axiom | PASS; normative revision theorems have only foundational `propext`, `Classical.choice`, `Quot.sound` |
| vectors | source-connected positive/negative cases compile | PASS; exact-rational executable tests |
| forbidden scan | no declaration using forbidden mechanisms | textual hits in the intentional audit command/`#print axioms` inventory are not declarations |
| hash manifest | all six inputs match | PASS; six inputs match |
| LaTeX | clean document build | PASS exit status; final log has no TeX/layout diagnostics |
| production scope | no Lua controller change | PASS; no `train_controller.lua` change |

## Gate audit

Each row records the required gate boundary, reproducer, expected/actual
result, premise-removal or mutation result, and classification/remediation.

| Gate | Reproducer and producer → consumer boundary | Expected / actual | Premise removal or mutation | Classification and remediation |
|---|---|---|---|---|
| A — artifacts/provenance | `lake build`, `Axioms.lean`, forbidden scan, SHA check, LaTeX, scoped diff; source files/hash manifest → artifacts | expected clean evidence and no forbidden mechanism; Lean/source checks are clean when final rerun passes | version-16 class substitution is rejected by root-major/hash ledger; inherited READY label is withdrawn | artifact/provenance gate passes only for checked-in proof; no production acceptance; preserve root Java-8 manifest |
| B — claim separation | `IRRevision` definitions/theorem inventory; spline producer → graph producer, profile → physics, controller → plant, safety → arrival | expected separate claims; actual models and theorem names are separate, with old PID claims withdrawn | deleting a producer relation leaves no valid consumer theorem; optimality is explicitly withdrawn | model-separation pass; remaining Java/Lua source refinement is recorded, not hidden |
| C — required connections | trace fit → validated spline → directed edge; source fields → exact ledger; localization → combined command → plant; guard → terminal acceptance | expected explicit coordinates, front coupler, bytecode branches, positive-throttle guard, and separate arrival; actual all are represented and tested in Lean at model boundary | invalid trace row, reverse/interval mutation, missing source field, wrong-way/crossed target, invalid command fail | conditional proof pass; full runtime source adapters and branch-uniform bound remain implementation obligations |
| D — cross-artifact consistency | `pid-bytecode-traceability.md`, Lean, LaTeX, vectors, source refs; bytecode ledger → theorem/model/docs | expected same constants, orientation, IDs, markers, particle fields, force branches; actual checked after final build/doc audit | material and wheel-slip mutation; graph crossing/overpass mutation; stale theorem-name scan | consistency pass for artifacts; live Java/Lua adapter comparison remains required |
| E — controller/plant refinement | `apiCommandProducer` → `exactCommandPhysics`/`exactPlantTransition` → next particle state | expected throttle and both brakes survive to source-shaped transition; actual exact model does so and rejects invalid commands | positive throttle is not zeroed; invalid command and bad linkage return `none` | conditional: exact Java `SimulationState.next`/all `Consist` branches are not identity-refined; implement/audit adapter |
| F — arrival/optimality | `BrakingBound` → `terminalGuard` → `arrivalStep`/stable observations/holding | expected meaningful robust-arrival objective and no unsupported optimality; actual safety/arrival contract exists, formal optimality withdrawn | mass, brake, multiplier, grade, delay, throttle, curvature/slack/push-pull mutations alter/reject guard; no controller-shaped optimality theorem retained | conditional arrival pass; runtime uniform bound and live mutation harness required |
| G — runtime/fail closed | numeric/timing/profile/route producers → command/route decisions | expected missing/nonfinite/stale/profile/route data fails closed; actual producer theorems and vectors do so | NaN, missing info/timing, wrong route revision/orientation, profile mutation return `none`/fail closed | contract pass at Lean boundary; measured detector/radio/scheduler/route latency and diagnostics remain Lua obligations |
| H — adversarial/mutation | `IRRevisionTestVectors`, source-adapter/geometry/controller/transition/timing matrix | expected mutations are observed by connected tests; exact-rational suite covers all listed families | direction, target crossing, mass, brake, multiplier, grade, delay, throttle, geometry, topology, curvature/slack, profile mutations change/reject | proof-vector pass; external Java/Lua mutation harness not yet executed |
| I — handoff readiness | fresh read-only audit of all gates and required source arrows | expected `DONE` only if no source connection/bound/refinement remains assumed; actual required runtime/refinement connections remain future obligations | removing those premises would make the implementation claim unsound; no convenient neutral defaults are used | `NOT_READY`; do not emit `READY_FOR_USER_APPROVAL` or `DONE` |

Gate rows marked conditional are not silently promoted by compilation. Gate I
is intentionally not passed because the task is prohibited from modifying the
runtime controller and cannot measure the external runtime contracts.

## Anti-cheating audit

| Class | Finding |
|---|---|
| 1. prohibited mechanisms | no project-specific `axiom`, `sorry`, `admit`, `unsafe`, `cast`, or `ofReduceBool` proof escape found; intentional audit text is not a declaration |
| 2. vacuity/assumption leakage | producer equalities such as `validatedSplineProducer c = some v` are required; arbitrary caller certificates are not accepted as validity proof |
| 3. specialization as generality | vectors are labelled examples; quantified relations state their exact premises and do not generalize a single train |
| 4. equation mismatch | exact force ledger follows the root branch order; legacy PID equations are withdrawn |
| 5. disconnected definitions | each required funnel arrow has a producer, consumer, relation theorem, and vector; remaining live arrows are explicitly open |
| 6. tautological optimality | no optimality theorem is claimed; old controller-shaped optimality is withdrawn |
| 7. sign/algebra/dimensions | directed error, reverse velocity, signed grade/traction, rational units, and negative/positive guards are explicit; exact force vector is `-10823` |
| 8. temporal/hybrid under-approximation | delay, sample age, pressure age, detector and route-change fields exist; external timing remains a measured contract, not a zero default |
| 9. API/refinement | detector `info`, source fields, numeric conversion, command channels, and route revision are represented; full Java/Lua refinement remains open |
| 10. provenance/version drift | root major 52 and version-16 major 60 are recorded; hashes and root-only `javap` are required |
| 11. numerical/representation unsoundness | exact rational tests are labelled as model tests; NaN/infinity are rejected; floating and arc-length errors are explicit budgets |
| 12. safety/liveness/scope confusion | no-crossing, terminal arrival, holding, route feasibility, and production deployment are separate claims |
| 13. negative/mutation insufficiency | exact suite includes geometry, source adapter, physics, controller, transition, timing, route, profile, and topology mutations; live harness remains required |
| 14. optimistic physical defaults | no missing mass, grade sine, resistance, timing, profile, or brake field defaults to zero/neutral in the normative source adapter |
| 15. fake source certificates | source refs identify bytecode evidence but do not certify unobserved runtime values; producers return `none` when fields are absent |
| 16. transition aliasing | `exactPlantTransition` and `sourceParticleTransition` construct a next state with command/force/linkage fields; `rfl` aliases are not used as full Java refinement |
| 17. unsupported readiness | reports say `NOT_READY`; no passing-build-only readiness claim remains |

## The required spline-to-graph theorem

The theorem is `IRRevision.validated_spline_to_directed_routing_edge` in
`pid-proof-lean/IRRevision.lean`. Its dependency path is:

```text
TraceObservation
 -> traceCentre / traceResidualBound / traceFitRowsValid
 -> splineCandidateValid / validatedSplineProducer
 -> cubicPosition / cubicReverse / cubic_reverse_position
 -> directedCoordinateOfParameter / edgePointAt / directedEdge
```

It proves both orientations, endpoint correspondence, parameter-to-interval
coordinate mapping, stable spline ID/source trace preservation, and transfer
of `distance3L1 q (cubicPosition curve t) ≤ eps`. `Axioms.lean` reports only
`[propext, Classical.choice, Quot.sound]` transitively. The LaTeX statement is
the “Validated spline to directed edge” claim in `pid-formal-proof.tex`.
The vectors mutate orientation, interval mapping, fit validity, and spline ID.

The network-level consumer theorem
`IRRevision.graph_network_consumes_only_source_validated_splines` extends this
check to the list-producing graph builder: each emitted edge comes from a
candidate whose `validatedSplineProducer` output supplies the validated spline,
and duplicate/empty stable IDs fail closed. Its `#print axioms` output is the
same foundational Lean set.

## Classification of final results

- `IRRevision` theorem results: **proved by Lean**, subject to explicit exact-
  rational model premises.
- Root branch equations, constants, methods, class/version/hash facts:
  **derived from bytecode** or directly observed bytecode facts as labelled in
  `pid-bytecode-traceability.md`.
- Cubic residual, arc-length approximation, uniform lower-braking bound,
  curvature/slack/push-pull envelope, and exact source adapter completeness:
  **certified model assumptions** until measured/derived at runtime.
- Detector delivery, immediate `info()`, profile immutability, numeric
  finiteness, timing, radio, route revision, diagnostics, and fail-closed
  behavior: **runtime contracts**.
- Persistent spline/graph/profile/controller/plant/arrival integration and
  live mutation harness: **future Lua implementation obligations**.
- PID optimality, old disconnected theorem claims, exact floating-point
  correctness, complete Java linkage/collision identity, and deployment
  approval: **unsupported or withdrawn**.
