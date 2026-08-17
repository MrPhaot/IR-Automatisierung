# Agent Handoff: IR 1.11.0 Formal PID Controller

## Mission

Prepare and execute a Lean-checkable, conditional proof of a complete terminal-stopping PID controller for:

- Minecraft 1.7.10
- Immersive Railroading 1.11.0
- The OpenComputers `ir_remote_control` API
- The exact extracted jar in `immersive_railroading/.cache/jar/`

The proof must use the jar as the physics source of truth. It must not treat the current `train_controller.lua` implementation as authoritative.

The proof is exact relative to explicit IR/runtime contracts. It must not claim universal correctness for future IR versions or for runtime conditions outside those contracts.

## Phase 1: Prepare Context

Before editing anything, read:

1. Repository instructions:

   - `immersive_railroading/AGENTS.md`
   - `README.md`
   - `immersive_railroading/README.md`
   - `immersive_railroading/docs/README.md`

2. Session and planning context:

   - `.kilo/session_transcripts/session-ses_0077.md`, lines 3312 through EOF
   - `.kilo/plans/1786581005158-pid-formal-proof-fixes.md`
   - `immersive_railroading/docs/plans/pid-formal-proof-checkpoint.md`

3. Runtime and implementation context:

   - `immersive_railroading/docs/runtime.md`
   - `immersive_railroading/programs/train_controller.lua`
   - `immersive_railroading/tests/previews/controller_preview.lua`
   - terminal-stop preview tests under `immersive_railroading/tests/previews/`

Preserve the existing dirty worktree. Do not reset, checkout, delete, or overwrite unrelated changes.

Record the current repository state with:

```bash
git status --short
git log --oneline -12
```

Do not assume every existing generated proof artifact is correct. The current LaTeX document and checkpoint contain mathematically unsupported claims and must be audited critically.

## Phase 2: Verify the Jar

Confirm the jar identity from:

```text
immersive_railroading/.cache/jar/mcmod.info
```

Expected identity:

```text
modid: immersiverailroading
version: 1.11.0
mcversion: 1.7.10
```

Create a manifest of relevant class hashes and compare duplicate classes under:

```text
immersive_railroading/.cache/jar/cam72cam/...
immersive_railroading/.cache/jar/META-INF/versions/16/cam72cam/...
```

Determine which class set is actually used by the target Java runtime. Do not accidentally analyze the Java 16 variant if the Minecraft 1.7.10 installation runs the root classes under Java 8.

Read the complete relevant decompiled files, not only search hits:

- `Configuration_decompiled.txt`
- `SimulationState_decompiled.txt`
- `Particle_decompiled.txt`
- `LocomotiveDefinition_decompiled.txt`

Then inspect bytecode with `javap -p -c` for the classes whose complete decompilation is missing or ambiguous:

- `PhysicalMaterials`
- `Config$ConfigBalance`
- `SimulationState`
- `SimulationState$Configuration`
- `EntityMoveableRollingStock`
- `Locomotive`
- `EntityRollingStockDefinition`
- `CommonAPI`
- `RadioCtrlCardDriver$RadioCtrlCardManager`
- `Consist`
- `Consist$Particle`

The report must distinguish:

- facts directly visible in bytecode;
- facts inferred from call structure;
- facts still requiring an explicit assumption or runtime test.

## Phase 3: Establish the Exact Physics Contract

The agent must document the actual force path.

Known values and behaviors already established:

- `PhysicalMaterials.STEEL.staticFriction(STEEL) = 0.70`.
- `PhysicalMaterials.STEEL.kineticFriction(STEEL) = 0.42`.
- `Config$ConfigBalance.brakeMultiplier` defaults to `1.0`.
- Base `getBrakeSystemEfficiency()` returns `EntityRollingStockDefinition.getBrakeShoeFriction()`.
- Default brake shoe material is `CAST_IRON`.
- Steel–cast-iron kinetic friction is `0.25`.
- Locomotive cogging mode overrides brake-system and adhesion efficiency to `10.0`.
- `remote.setBrake()` aliases `setTrainBrake()`.
- The OpenComputers adapter normalizes NaN to `0`, clamps command inputs to `[-1,1]`, and the locomotive train-brake setter clamps to `[0,1]`.
- Train brake pressure and independent brake position are separate state variables.
- IR uses `max(brakePressure, independentBrakePosition)`.
- Wheel-slip force uses steel kinetic friction and is then multiplied by `brakeMultiplier`.

The formal model must include, per stock:

- current mass;
- maximum/design mass;
- brake-shoe friction coefficient;
- brake-system efficiency;
- brake-adhesion efficiency;
- rolling resistance;
- pressure-brake availability;
- independent-brake availability;
- relevant locomotive overrides.

It must include the exact branches:

1. Desired brake force.
2. Adhesion comparison.
3. Wheel-slip fallback.
4. Brake multiplier.
5. Grade force.
6. Rolling resistance.
7. Interference/collision resistance where relevant.
8. Consist aggregation.
9. Discrete physics update.
10. Controller sampling and command delay.

The proof must not conflate:

- steel rail static friction;
- steel rail kinetic friction;
- brake-shoe friction;
- brake-system efficiency;
- the learned `full_service_mps2` value.

## Phase 4: Resolve $\hat a_\text{brake}$ Correctly

The current brake learner is not automatically a proof-valid estimate.

Audit both learner implementations in `train_controller.lua`, including:

- command gating;
- throttle gating;
- minimum-speed gating;
- partial-command exponent;
- floor value;
- EMA memory;
- terminal-learning suppression;
- terminal PID snapshot behavior.

Prove one of the following, explicitly:

1. A model-derived lower bound is available from a supplied physics contract; or
2. An observation-derived lower bound is available under formally bounded disturbance, grade, delay, and measurement error.

If neither is available, the controller must not claim a stopping guarantee. It must enter a degraded mode and report that the formal precondition is unavailable.

The preferred design is:

- derive a certified lower bound from exact IR physics/configuration data;
- use the learner only as calibration/diagnostic data;
- allow learned data to replace the model bound only after it passes a certified lower-bound rule;
- never use raw EMA output as an assumed lower or upper bound.

The resulting $\hat a_\text{brake}$ must be a documented certified lower bound, not merely an estimate with a positive value.

## Phase 5: Replace the Existing Mathematical Proof

Treat `immersive_railroading/docs/plans/pid-formal-proof.tex` as an invalid draft, not as an established proof.

Remove or rewrite:

- the claimed closed-form Riccati solution;
- the unsupported LQR-to-PID equivalence;
- the two-state stability proof that ignores the integrator;
- the incorrect pole-sign derivation;
- the unsupported stopping-distance “if and only if” claim;
- the claim that the learner is automatically conservative;
- the comparison section.

The proof must define:

- target-distance coordinate and sign conventions;
- measured speed and velocity-error convention;
- the terminal context and its origin;
- train-brake and independent-brake control variables;
- the exact physics-contract parameters;
- sampling period and command delay;
- the augmented PID state;
- saturation and anti-windup behavior;
- admissible grades and disturbances;
- feasibility conditions.

Use a three-state augmented model including the integral state. If using a moving reference speed envelope, distinguish clearly between:

- global stopping safety;
- local reference tracking;
- nominal controller optimality.

Optimality must be scoped precisely. The agent may claim optimality only for the declared sampled nominal model, cost function, and controller class. It must not claim that a PID is globally optimal for the full nonlinear, saturated, hybrid IR plant unless that theorem is actually proven.

The stopping theorem must include:

- certified brake lower bound;
- worst-case grade;
- rolling resistance;
- command delay;
- sampling error;
- speed and distance measurement errors;
- saturation;
- infeasible-entry behavior.

`stop_buffer_m` is a target-placement preference. It must not be used as a hidden brake-performance parameter.

## Phase 6: Lean Verification

The existing `/tmp/pid_proof` project contains a placeholder proof using `Float` and `admit`. It is not an acceptable final artifact.

Create a durable repository-contained Lean project, for example under:

```text
immersive_railroading/docs/plans/pid-proof-lean/
```

Requirements:

- no `sorry`;
- no `admit`;
- no unreviewed axioms;
- exact rational or real arithmetic;
- explicit theorem assumptions;
- executable/reference definitions for the controller;
- proofs of saturation and anti-windup invariants;
- proofs of positivity and lower-bound preservation;
- proofs of nominal stability;
- proofs of the conditional stopping invariant;
- proofs connecting the abstract command to the normalized IR command range.

Do not use Lean `Float` as the mathematical foundation. Use exact arithmetic for the model and separately document the floating-point refinement/error boundary.

Include:

- `lakefile.toml`;
- `lean-toolchain`;
- all Lean source;
- a README describing every theorem and assumption;
- a proof manifest recording the jar version and hashes;
- a command that builds the project from a clean checkout.

## Phase 7: Implementation Plan

Only after the proof model and contracts are stable, prepare the Lua implementation plan.

The implementation should isolate a physics adapter with:

- contract/version identifier;
- physics constants;
- consist-level brake parameters;
- certified $\hat a_\text{brake}$ calculation;
- explicit “guarantee unavailable” state.

Replace the current cruise-based `derive_pid` with the formally specified terminal controller.

Keep unrelated route, schedule, redstone, and guardrail changes out of scope.

The controller must:

- use terminal distance and speed state;
- keep train brake and independent brake semantics distinct;
- keep throttle at zero during committed terminal stopping;
- apply command saturation explicitly;
- use formally justified anti-windup;
- handle infeasible stopping entry deterministically;
- fail closed when the physics contract is missing or incompatible;
- expose contract status and controller state in diagnostics.

## Validation

The next agent must run and document:

- LaTeX compilation;
- Lean compilation with no placeholders;
- Lua syntax checks;
- existing controller preview tests;
- pure mathematical model tests;
- command-mapping tests;
- no-slip and wheel-slip tests;
- learner/estimator invariant tests;
- infeasible-distance tests;
- replay of existing terminal-stall logs;
- comparison against the pre-`a67fcee` and post-`a67fcee` controller behavior;
- in-game tests on the pinned Minecraft 1.7.10 / IR 1.11.0 installation.

The final report must separate:

1. proven statements;
2. assumptions;
3. implementation obligations;
4. runtime observations;
5. unresolved limitations.

## Copy-Paste Prompt for the Next Codex Agent

```text
You are continuing a formal-control task in the repository
/home/mrphaot/Dokumente/lua/minecraft.

Your mission is to prepare and execute a Lean-checkable conditional proof of a complete,
implementable terminal-stopping PID controller for Minecraft 1.7.10 with Immersive
Railroading 1.11.0.

Do not trust the existing PID proof. It is an invalid draft containing unsupported
Riccati, LQR-to-PID, stability, and stopping-distance claims. Treat it as material to
audit and replace.

Before editing anything:

1. Read:
   - immersive_railroading/AGENTS.md
   - README.md
   - immersive_railroading/README.md
   - immersive_railroading/docs/README.md
   - .kilo/session_transcripts/session-ses_0077.md, lines 3312 through EOF
   - .kilo/plans/1786581005158-pid-formal-proof-fixes.md
   - immersive_railroading/docs/plans/pid-formal-proof-checkpoint.md
   - immersive_railroading/docs/runtime.md
   - immersive_railroading/programs/train_controller.lua
   - relevant controller preview tests

2. Preserve the dirty worktree. Do not run git reset, git checkout, destructive cleanup,
   or overwrite unrelated user changes.

3. Verify the extracted jar identity from:
   immersive_railroading/.cache/jar/mcmod.info

   Expected:
   - modid: immersiverailroading
   - version: 1.11.0
   - mcversion: 1.7.10

4. Compare root classes with META-INF/versions/16 classes and determine which class set
   applies to the target Java runtime. Do not silently analyze the wrong variant.

5. Read the complete relevant decompiled files:
   - Configuration_decompiled.txt
   - SimulationState_decompiled.txt
   - Particle_decompiled.txt
   - LocomotiveDefinition_decompiled.txt

6. Use javap -p -c on:
   - PhysicalMaterials
   - Config$ConfigBalance
   - SimulationState
   - SimulationState$Configuration
   - EntityMoveableRollingStock
   - Locomotive
   - EntityRollingStockDefinition
   - CommonAPI
   - RadioCtrlCardDriver$RadioCtrlCardManager
   - Consist
   - Consist$Particle

Use the jar bytecode as the physics authority, not train_controller.lua.

Facts already established and requiring verification in your report:

- steel-steel static friction = 0.70;
- steel-steel kinetic friction = 0.42;
- default brakeMultiplier = 1.0;
- base getBrakeSystemEfficiency() returns configured brake-shoe friction;
- default CAST_IRON brake shoe gives steel/cast-iron kinetic friction 0.25;
- locomotive cogging mode overrides efficiency to 10.0;
- setBrake aliases setTrainBrake;
- OpenComputers normalizes NaN to zero and clamps command input;
- locomotive train-brake setter clamps to [0,1];
- train brake pressure and independent brake position are distinct;
- IR applies max(train brake, independent brake);
- wheel-slip force uses steel kinetic friction and brakeMultiplier.

Do not conflate rail friction with brake-shoe friction.

Audit the current learner in train_controller.lua. Raw
brake_model.full_service_mps2 and its EMA are not proof-valid merely because they
are positive. Establish a certified lower bound for braking from exact IR physics and
explicit consist/configuration data, or prove an observation-based lower-bound estimator
under explicit bounded disturbance, grade, delay, and measurement-error assumptions.

If no certified positive lower bound is available, the correct behavior is to mark the
formal guarantee unavailable and fail closed. Do not invent a fallback theorem.

Rewrite the LaTeX proof instead of patching unsupported claims. It must include:

- exact command-to-physics refinement;
- separate train-brake and independent-brake channels;
- exact IR force branches;
- consist aggregation;
- actuation delay and sampling;
- a three-state augmented PID model;
- saturation and anti-windup;
- a certified brake lower bound;
- explicit feasibility conditions;
- nominal optimality scoped to a declared model, cost, and controller class;
- conditional stability and stopping guarantees.

Do not claim global optimality for the full nonlinear saturated hybrid IR plant unless it
is actually proven. Do not include a comparison with the current program inside the proof;
put historical comparison in a separate report if needed. stop_buffer_m is a target
placement preference and must not be used as a brake-performance parameter.

Create a repository-contained Lean project. The old /tmp/pid_proof project contains
Float arithmetic and an admit placeholder and is not acceptable as a final proof.

Lean requirements:

- no sorry;
- no admit;
- no unreviewed axioms;
- exact rational/real model;
- explicit assumptions;
- proofs of estimator positivity/lower-bound preservation;
- command saturation and anti-windup invariants;
- nominal stability;
- conditional stopping invariant;
- command normalization/refinement.

Do not use Lean Float as the mathematical foundation. Use exact arithmetic and document
the floating-point implementation boundary separately.

Do not modify train_controller.lua until the proof model, contracts, and implementation
interface are settled. Then prepare the implementation plan or implement only the
formally specified changes, keeping unrelated route/schedule/redstone work untouched.

At every major phase, report:

- files inspected;
- facts proven from bytecode;
- assumptions still required;
- theorem scope;
- artifacts created;
- tests run;
- blockers.

The final handoff must contain:

1. a corrected LaTeX proof;
2. a Lean project that builds without placeholders;
3. a physics-contract/hash manifest;
4. a precise implementation plan;
5. a list separating proven facts, assumptions, runtime checks, and unresolved limitations.
```
