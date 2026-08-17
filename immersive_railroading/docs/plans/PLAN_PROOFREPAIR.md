# Handoff: Repair and Verify the PID Proof

## Scope

Repair and peer-review only:

- `immersive_railroading/docs/plans/pid-formal-proof.tex`
- `immersive_railroading/docs/plans/pid-proof-lean/`
- `immersive_railroading/docs/plans/pid-audit-report.md`
- `immersive_railroading/docs/plans/pid-implementation-plan.md`

Do not modify `immersive_railroading/programs/train_controller.lua` or any production Lua file. Lua changes require explicit user approval after the proof and implementation contract are accepted.

## Required Preparation

Read before editing:

- `immersive_railroading/AGENTS.md`
- `README.md`
- `immersive_railroading/README.md`
- `immersive_railroading/docs/README.md`
- `.kilo/session_transcripts/session-ses_0077.md`, lines 3312–EOF
- `.kilo/plans/1786581005158-pid-formal-proof-fixes.md`
- `immersive_railroading/docs/plans/pid-formal-proof-checkpoint.md`
- `immersive_railroading/docs/plans/Notizen_Unverständlichkeiten bei dem Beweis`
- `immersive_railroading/docs/runtime.md`
- `immersive_railroading/programs/train_controller.lua`
- `immersive_railroading/docs/plans/pid-implementation-plan.md`

Preserve all unrelated dirty-worktree changes.

Revalidate the extracted jar:

- Minecraft 1.7.10
- IR 1.11.0
- Java-8 root classes, not `META-INF/versions/16`

Use complete decompiled files and `javap -p -c` for the relevant physics and OpenComputers classes. Distinguish bytecode facts, assumptions, and unverified runtime behavior.

## Mandatory Proof Repairs

1. Define the coordinate and sign conventions unambiguously.

   Define a route-side-independent, target-directed along-track coordinate. Explain
   whether position error is signed world position or remaining target distance, and
   do not rely on locomotive orientation as the direction authority. Derive the
   correct sign of:

   - $\dot x$;
   - velocity;
   - brake command;
   - PID terms;
   - Lua `speed_error`.

   Prove that the coordinate works when approaching the target from either route
   side, that the stopping phase begins only with positive target-directed velocity,
   and that away-motion cannot silently enter the stopping theorem. On curves, use
   along-track distance rather than an unproved Euclidean-distance substitute.

2. Repair the IR force model.

   Ensure Lean and LaTeX agree on:

   - steel static friction `0.70`;
   - steel kinetic friction `0.42`;
   - brake-shoe friction;
   - brake-system efficiency;
   - design/current mass;
   - adhesion branch;
   - wheel-slip branch;
   - `brakeMultiplier`;
   - rolling, grade, direct, and interference forces;
   - consist aggregation.

   In particular, Lean currently omits `brakeMultiplier` on the ordinary desired-force branch.

   Derive the signed longitudinal equation line by line from the Java-8 root
   bytecode, including grade and tractive force, rolling/direct/interference and
   near-zero resistance, braking, adhesion and wheel-slip branches,
   `brakeMultiplier`, particle aggregation, and the treatment of coupler forces.
   Do not introduce the central force equation as an unexplained abstraction.

3. Make the certified brake bound uniform.

   A value computed from the current velocity snapshot is insufficient for a stopping-horizon theorem. Define $\widehat a_\text{brake}$ as a lower bound valid over every permitted speed, branch transition, pressure delay, consist state, and disturbance during the certified horizon.
   Define the exact terminal-entry distance guard, including sampling, actuation
   and observation delay, adverse acceleration, position uncertainty, and the
   computational tolerance. Prove that the cruise-to-stopping transition invokes
   the stopping invariant only when this guard is satisfied, and fails closed when
   the guard is already violated.

4. Prove the stopping invariant, not merely its premise.

   The current Lean theorem only extracts `0 < a` from a structure that already contains `0 < a`. Add an actual Lean state-transition theorem showing that the stopping envelope is preserved until velocity reaches zero.
   Add a separate terminal-arrival/liveness theorem with explicit position,
   velocity, settling, and computational-error tolerances. A no-crossing theorem
   alone is insufficient: prove how the dynamic braking path reaches the accepted
   target interval without throttle, or mark that claim unsupported.

5. Generalize the stability proof.

   The current Lean theorem proves only the special normalized case:

   - $h=1$;
   - $a=1$;
   - $\rho=0$;
   - gains $(3,3,1)$.

   Either prove the LaTeX claim for arbitrary admissible $h$, $a$, and $0<\rho<1$, or narrow the LaTeX claim to exactly what Lean proves.

   Connect the characteristic polynomial to the actual closed-loop state matrix.

6. Remove the fake optimality argument.

   The current cost is defined as squared distance from the already selected gains, making those gains optimal by construction. Replace it with a meaningful declared cost involving tracking error, control effort, settling behavior, or pole-placement constraints. If meaningful optimality cannot be proven, remove the optimality claim and state the exact weaker result.

7. Model the real controller boundary.

   The Lean controller must correspond to the eventual Lua interface:

   - position/speed error;
   - integral state;
   - derivative or measured-deceleration term;
   - saturation;
   - anti-windup;
   - slew limits if retained;
   - train-brake/independent-brake allocation;
   - throttle-zero supervisor;
   - emergency full-brake branch.

   The Lean model must connect the PID state update to dynamic brake allocation,
   the zero-throttle supervisor, the IR plant transition, and the next state. An
   isolated `rawPID` definition, alias theorem, saturation lemma, or nominal
   equation is not an implementation refinement.

   It is acceptable to leave the production Lua unchanged, but the proof must clearly specify the exact changes Lua would require.

8. Address curved and non-rigid consists.

   The stated target includes wagons that may still be curving and introduce
   additional deceleration. Formalize a conservative bound for normal game-valid
   curves, coupler slack, push/pull interaction subsets, and their effect on the
   braking lower bound. The Lean, LaTeX, and IR particle/aggregation models must
   agree on this bound.

   Only explicitly impossible or unobservable runtime states may be excluded. Such
   states must produce `NOT_READY` or an explicit runtime guarantee-unavailable
   result; they may not be silently treated as covered by the scalar proof.

## Lean Anti-Cheating Audit

The audit is divided into general proof-integrity classes. A passing Lean build is
necessary but never sufficient: each class requires the corresponding structural,
semantic, and adversarial checks.

### Class 1: prohibited proof mechanisms

Examples:

- `sorry`;
- `admit`;
- custom axioms;
- unreviewed `opaque` declarations;
- unsafe escape hatches;
- imported theorems whose axioms are not audited.

Required gates:

- Search all Lean sources for `sorry`, `admit`, `axiom`, `opaque`, `unsafe`,
  `cast`, `ofReduceBool`, and equivalent escape mechanisms.
- Run `#print axioms` for every safety, stability, stopping, refinement, and
  optimality theorem.
- Accept only standard foundational dependencies that are explicitly documented.
- Reject any theorem whose result depends on an undeclared project-specific axiom.

Commands:

```bash
lake build
lake env lean Axioms.lean
rg -n 'sorry|admit|axiom|opaque|unsafe|cast|ofReduceBool' .
```

### Class 2: vacuous or assumption-leaking theorems

Examples:

- a theorem concludes a fact already stored in its premises;
- a stopping invariant merely contains the desired invariant as a field;
- positivity is extracted from an assumption instead of derived from the model.

Required gates:

- For every safety theorem, identify the state-transition relation used to
  preserve the property.
- Reject a theorem whose conclusion is syntactically or semantically one of its
  assumptions unless it is explicitly labeled as a helper lemma.
- Require at least one theorem showing preservation from state `k` to state `k+1`.
- Perturb or remove each essential premise and confirm that the theorem no longer
  proves the same conclusion.

### Class 3: specialization presented as generality

Examples:

- Lean proves only `h = 1`, `a = 1`, `rho = 0`, while LaTeX claims arbitrary
  positive parameters;
- a numerical example is presented as a parameterized theorem.

Required gates:

- Compare every quantified variable in LaTeX with the Lean theorem type.
- General claims must quantify over the complete advertised parameter range.
- Hard-coded constants may appear only in explicitly labeled examples or
  regression tests.
- The theorem must fail to type-check if a claimed essential parameter is
  removed from the model.

### Class 4: model-equation mismatch

Examples:

- Lean omits `brakeMultiplier` from one force branch;
- Lean and LaTeX use different mass, friction, slip, or resistance equations;
- a coefficient is defined per stock in one artifact and globally in another.

Required gates:

- Maintain one equation-to-definition mapping for every physical equation.
- Prove model-consistency lemmas for all force branches and command paths.
- Include branch tests for ordinary braking, adhesion-limited braking, wheel slip,
  near-zero velocity, and both brake channels.
- Apply mutation tests: changing a physical coefficient in the model must change
  the corresponding theorem/test result.

### Class 5: disconnected definitions and theorems

Examples:

- `Stock` and `Consist` exist but are not used by the lower-bound theorem;
- `rawPID` exists but no theorem uses it to define a closed-loop transition;
- the proof theorem is valid only for an unrelated abstract function.

Required gates:

- Build a theorem dependency graph for every major claim.
- Every safety/stability theorem must depend on the actual model definitions,
  controller definition, and transition relation.
- Reject unused “proof-looking” definitions that are not connected to the
  conclusion.
- Require a traceability table:

  | Claim | Lean theorem | Model definitions | Transition used | Future Lua symbol |
  |---|---|---|---|---|

### Class 6: tautological or answer-shaped optimality

Examples:

- the cost is squared distance from the already selected gains;
- the objective is constructed so the proposed controller wins by definition.

Required gates:

- The objective must be independent of the proposed answer.
- The objective must measure declared behavior: tracking error, control effort,
  settling, robustness, pole placement, or another meaningful criterion.
- Prove both feasibility and optimality.
- Include at least one competing admissible controller in a regression example.
- If meaningful optimality cannot be proven, withdraw the optimality claim rather
  than weakening the objective.

### Class 7: algebraic, sign, dimensional, or derivation errors

Examples:

- remaining-distance and signed-position coordinates use opposite derivatives;
- brake signs disagree between equations and Lua;
- Newton's law is asserted without deriving the force sign;
- units do not match.

Required gates:

- State every coordinate and sign convention before the first equation.
- Derive each central equation from the preceding definitions or bytecode fact.
- Check dimensions of every gain, force, acceleration, distance, and time term.
- Add symbolic sign tests for forward motion, braking, overspeed, and target crossing.
- Reject equations that are merely introduced as assumptions when they are claimed
  to follow from IR physics.

### Class 8: temporal, hybrid, or branch under-approximation

Examples:

- a lower bound is computed at one velocity but claimed for a full stopping horizon;
- slip/no-slip transitions are omitted;
- the proof uses continuous dynamics while IR uses discrete substeps;
- saturation is analyzed separately but not in the actual transition system.

Required gates:

- Define the complete discrete transition relation used by the proof.
- Prove bounds uniformly over the entire certified horizon.
- Enumerate every branch that can affect force, command, or state evolution.
- Prove invariant preservation through branch transitions and saturation.
- Distinguish nominal linear stability from nonlinear saturated safety.

### Class 9: API and implementation-refinement failure

Examples:

- a `setBrake` alias theorem is `rfl` because both sides were defined identically;
- Lean models `Option Rat` but does not model NaN normalization;
- the abstract PID differs from Lua's actual error, derivative, integral, slew, or
  brake-allocation logic.

Required gates:

- Model the actual API call path as an explicit sequence of transformations.
- Prove normalization, clamping, channel separation, and state update behavior.
- A syntactic alias theorem is insufficient without a source-path refinement lemma.
- Maintain a theorem-to-Lua correspondence table.
- If production Lua is unchanged, state explicitly that the proof is not yet
  executable by the current program.

### Class 10: environment, version, and provenance drift

Examples:

- analyzing `META-INF/versions/16` instead of Java-8 root classes;
- using constants from a different jar/configuration;
- failing to identify the source of a hard-coded coefficient.

Required gates:

- Record Minecraft/IR versions and target Java runtime.
- Hash all authoritative class files and decompiled inputs.
- Verify the selected class variant.
- Label every value as bytecode-derived, configuration-derived, observed, or assumed.
- Re-run the manifest check before accepting the proof.

### Class 11: numerical and representation unsoundness

Examples:

- proving exact rational arithmetic while Lua uses unchecked IEEE floats;
- division by an unproved-positive value;
- NaN, overflow, rounding, or stale observations crossing the proof boundary.

Required gates:

- Prove positivity before every certified division.
- Define the conversion from runtime values to proof values.
- Use explicit error enclosures or outward rounding for proof-relevant Lua values.
- Test NaN, infinity, stale samples, zero mass, zero brake margin, and invalid
  configuration.
- Do not treat an exact-Rat theorem as an automatic proof of floating-point code.

### Class 12: safety, liveness, and scope confusion

Examples:

- proving “does not cross the target” but claiming “stops successfully”;
- proving local nominal stability but claiming global nonlinear stability;
- excluding curved/slack consists while claiming coverage of them.

Required gates:

- Separate safety, stability, termination, feasibility, and optimality claims.
- Each claim must have its own theorem or explicit assumption.
- State all excluded runtime cases.
- Require a counterexample or infeasibility result for cases outside the theorem.
- Ensure theorem statements are no stronger than their assumptions.

### Class 13: insufficient negative or mutation testing

Examples:

- only valid positive cases are tested;
- a disconnected model still passes all tests;
- changing a physical constant does not invalidate any result.

Required gates:

- Test valid and invalid certificates.
- Test positive and negative command values.
- Test both force branches and all channel combinations.
- Mutate signs, coefficients, gains, mass, delay, and disturbance bounds.
- Confirm that relevant theorem checks or model-consistency tests fail after each
  mutation.

### Audit output

The final audit report must classify every major result as:

- mechanically checked;
- mathematically proved;
- model assumption;
- runtime assumption;
- implementation obligation;
- unsupported or withdrawn claim.

A successful `lake build` alone is never an acceptance result.

## Required Deliverables

1. Corrected `pid-formal-proof.tex`.
2. Lean project that builds without placeholders.
3. Updated `pid-audit-report.md` listing:

   - proven facts;
   - assumptions;
   - unproved runtime obligations;
   - remaining limitations;
   - exact theorem-to-Lua correspondence.

4. Updated `pid-implementation-plan.md` describing the required future Lua adapter and controller changes without implementing them.
5. A final review summary stating clearly whether the proof is ready to serve as the implementation funnel.

## Acceptance Gate

The proof repair is accepted only if all applicable gates below pass. Compilation is
only the first gate.

### Gate A: artifact and provenance integrity

Pass only if:

- the LaTeX document compiles;
- the Lean project builds from a clean project directory;
- no forbidden proof mechanisms are present;
- theorem axiom dependencies are audited;
- the jar version, Java runtime, class variant, and hashes are recorded;
- unrelated worktree changes remain untouched.

### Gate B: claim and scope integrity

Pass only if:

- every major LaTeX claim is labeled as proved, assumed, runtime-checked, or
  withdrawn;
- no claim is stronger than its hypotheses;
- safety, stability, termination, feasibility, and optimality are separated;
- nonlinear/saturated/hybrid IR behavior is not described as covered by a nominal
  linear theorem;
- normal curved/slack operation is not excluded while the claim suggests it is
  covered;
- route-side-independent target coordinates and positive target-directed velocity
  at stopping-phase entry are proved;
- curved, slack, colliding, unknown, or changing consists are explicitly covered
  by bounds or explicitly excluded.

### Gate C: mathematical integrity

Pass only if:

- coordinate and sign conventions are explicit;
- force equations are derived rather than merely asserted;
- units and parameter domains are correct;
- lower bounds are uniform over the certified horizon;
- every safety theorem uses an actual state transition;
- the terminal-entry distance guard is proved;
- terminal arrival/liveness is proved separately from no-crossing safety, with
  explicit position, velocity, settling, and computational-error tolerances;
- the central force equations are derived from the authoritative IR bytecode;
- stability is proved for the parameter range claimed in LaTeX;
- no theorem is vacuous or merely repeats an assumption.

### Gate D: model-consistency integrity

Pass only if:

- Lean and LaTeX contain the same physical constants and force branches;
- `brakeMultiplier` appears consistently;
- mass, brake-shoe friction, adhesion, wheel slip, rolling resistance, grade,
  direct resistance, and consist aggregation agree;
- curvature, coupler slack, push/pull particle subsets, and their braking bound
  agree between Lean, LaTeX, and the IR particle implementation;
- command normalization and the two brake channels agree with the jar model;
- mutation tests demonstrate that changing a physical coefficient changes the
  relevant result.

### Gate E: controller-refinement integrity

Pass only if:

- the Lean controller has an explicit state transition;
- the transition includes the intended position/speed error, integral, derivative or
  measured-deceleration term, saturation, anti-windup, and supervisor;
- the transition connects PID state, dynamic brake allocation, zero throttle, the
  IR plant transition, and the next state;
- every major theorem has a theorem-to-Lua correspondence;
- differences between the proof controller and current Lua implementation are
  documented precisely;
- no production Lua file is modified before explicit user approval.

### Gate F: optimality integrity

Pass only if:

- the cost is independent of the proposed gains;
- the cost represents a meaningful declared performance objective;
- the admissible controller class is explicit;
- feasibility and uniqueness/minimality are proved where claimed.

If this cannot be established, the optimality claim must be removed or weakened.

### Gate G: runtime-boundary integrity

Pass only if:

- the certified brake bound is derived from a verified configuration/consist
  contract or a formally bounded observation estimator;
- delay, sampling, measurement error, grade, throttle state, and command
  acknowledgement are bounded;
- route coordinates, motion samples, curvature/slack effects, and the terminal-entry
  distance guard are runtime contracts;
- invalid or unavailable data force the guarantee into an explicit unavailable or
  fail-closed state;
- floating-point conversion and NaN behavior are covered.

### Gate H: adversarial validation

Pass only if:

- valid and invalid certificate cases are tested;
- no-slip and wheel-slip cases are tested;
- both train-brake and independent-brake paths are tested;
- zero, negative, NaN, stale, and out-of-range inputs are tested;
- mass, brake coefficient, multiplier, delay, sign, and disturbance mutations are
  tested;
- relevant checks fail when the model is intentionally changed.

### Gate I: implementation-funnel readiness

The proof is ready to guide Lua implementation only when:

- the Lean model matches the declared future controller interface;
- the safety supervisor and PID responsibilities are separated;
- route-side-independent coordinates, terminal-entry, terminal-arrival, force
  derivation, curved/slack bounds, and closed-loop controller refinement are all
  proved rather than merely assumed, excluded, unsupported, or withdrawn;
- the exact required Lua changes are listed;
- the current Lua mismatch is documented;
- no production Lua implementation has been approved or changed yet;
- the final report contains no unexplained “pass” based solely on compilation.

Neither `READY_FOR_USER_APPROVAL` nor `CONDITIONALLY_READY` is permitted if
terminal arrival, normal curved/slack coverage, or closed-loop controller
refinement is unsupported or withdrawn. Those outcomes require `NOT_READY` with
the missing proof obligation named explicitly. `CONDITIONALLY_READY` is reserved
for named external runtime checks after all six mandatory proof requirements have
been proved.

The final readiness result must be one of:

- `READY_FOR_USER_APPROVAL`;
- `CONDITIONALLY_READY`, with named runtime gates outstanding;
- `NOT_READY`, with blocking proof or refinement failures listed.

A passing build without passing Gates B–I is not acceptance.

## Context-Engineered Prompt

```text
You are the proof-repair agent for the repository
/home/mrphaot/Dokumente/lua/minecraft.

Your task is to repair and peer-review the formal PID proof for Minecraft 1.7.10
with Immersive Railroading 1.11.0.

IMPORTANT SCOPE RULE:
Do not modify train_controller.lua or any production Lua file.
The user will approve or reject the implementation decision after reviewing the
proof. You may inspect Lua and describe required changes, but you must not implement
them.

Read these files first:

- immersive_railroading/AGENTS.md
- README.md
- immersive_railroading/README.md
- immersive_railroading/docs/README.md
- .kilo/session_transcripts/session-ses_0077.md, lines 3312 through EOF
- .kilo/plans/1786581005158-pid-formal-proof-fixes.md
- immersive_railroading/docs/plans/pid-formal-proof-checkpoint.md
- immersive_railroading/docs/plans/Notizen_Unverständlichkeiten bei dem Beweis
- immersive_railroading/docs/runtime.md
- immersive_railroading/programs/train_controller.lua
- immersive_railroading/docs/plans/pid-formal-proof.tex
- immersive_railroading/docs/plans/pid-proof-lean/
- immersive_railroading/docs/plans/pid-implementation-plan.md
- immersive_railroading/docs/plans/pid-audit-report.md

Preserve unrelated dirty-worktree changes. Do not use git reset, git checkout,
destructive cleanup, or broad overwrites.

The extracted jar under immersive_railroading/.cache/jar/ is authoritative for IR
physics. Confirm:

- IR version 1.11.0;
- Minecraft version 1.7.10;
- Java-8 root class files are the target;
- META-INF/versions/16 classes are not silently used.

Read the complete decompiled physics files and inspect relevant root bytecode with
javap. Verify, rather than assume:

- PhysicalMaterials steel/steel static friction = 0.70;
- steel/steel kinetic friction = 0.42;
- steel/cast-iron kinetic brake-shoe friction = 0.25;
- brakeMultiplier default = 1.0;
- getBrakeSystemEfficiency() behavior;
- locomotive cogging overrides;
- train-brake and independent-brake channel separation;
- CommonAPI normalization and clamping;
- SimulationState force and wheel-slip branches;
- Consist particle integration and aggregation.

The current artifacts compile but are not yet accepted as correct. Audit them
adversarially.

Known defects to repair:

1. The coordinate/sign convention in the LaTeX model is ambiguous and may conflict
   with remaining-distance coordinates and Lua speed_error. Define a route-side-
   independent target-directed along-track coordinate, prove both approach sides,
   and prove positive target-directed velocity at stopping-phase entry.

2. Lean's brakeForce omits brakeMultiplier on the ordinary desired-force branch.
   Derive the complete signed force equation line by line from the Java-8 root
   bytecode instead of treating it as an unexplained abstraction.

3. The LaTeX certified brake bound is computed from a current snapshot but claimed
   over a full stopping horizon. Make the bound uniform over all allowed branch and
   state changes, and prove the terminal-entry distance guard including delay,
   sampling, uncertainty, and computational tolerance.

4. Lean's stoppingInvariant theorem only extracts positivity from an assumption.
   It does not prove invariant preservation by a plant/controller transition or
   actual terminal arrival. Add both the stopping-envelope transition theorem and
   a separate arrival/liveness theorem with explicit tolerances.

5. Lean's nominal stability theorem proves only h=a=1, rho=0, gains=(3,3,1).
   It does not prove the general LaTeX theorem for h>0, a>0, 0<rho<1, and it is
   not connected to an actual closed-loop matrix transition.

6. The nominal cost is squared distance from the selected gains, so the claimed
   optimality is tautological. Replace it with a meaningful cost or withdraw the
   optimality claim.

7. Lean's abstract Stock/Consist model is not connected to the certified lower-bound
   theorem or to a state-transition model. Connect the force derivation, particle
   aggregation, curvature/slack bound, and closed-loop plant transition.

8. The Lean command alias is mostly rfl because both functions were defined
   identically. Distinguish abstraction from genuine refinement of the jar/API path.

9. The proof assumes zero throttle and coherent consists, while the existing Lua
   terminal/recovery logic can apply throttle and can encounter slack/curve behavior.
   Require a conservative bound for normal game-valid curved/slack/push-pull
   consists. Connect the Lean PID state, dynamic brake allocation, zero-throttle
   supervisor, IR transition, and next state. Since Lua must remain unchanged,
   document the exact required future guards and any genuinely unobservable states
   that must fail closed.

10. The Lean model must correspond to the intended eventual Lua controller, including
    error sign, integral, derivative/measured deceleration, saturation, anti-windup,
    slew limits, brake allocation, and emergency supervisor.

Do not hide gaps by weakening theorem names or by introducing hard-coded examples as
general results. Do not call the proof ready when route-side symmetry, the
terminal-entry guard, terminal arrival, bytecode force derivation, curved/slack
coverage, or closed-loop Lean refinement is merely assumed, excluded, unsupported,
withdrawn, or disconnected from the theorem. Neither READY_FOR_USER_APPROVAL nor
CONDITIONALLY_READY is permitted in that situation; the agent must report NOT_READY
and name the missing proof obligation. CONDITIONALLY_READY is reserved for named
external runtime checks after all six mandatory proof requirements have been proved.

Run:

    lake build
    lake env lean Axioms.lean
    rg -n 'axiom|sorry|admit|opaque|unsafe' immersive_railroading/docs/plans/pid-proof-lean

Inspect #print axioms for every safety, stability, and optimality theorem. A build
passing is necessary but not sufficient.

Deliver:

1. corrected pid-formal-proof.tex;
2. Lean proof with no sorry/admit/custom axioms;
3. updated pid-audit-report.md;
4. updated pid-implementation-plan.md;
5. a final readiness report separating:
   - genuinely proven statements;
   - assumptions;
   - runtime checks;
   - Lua changes required later;
   - unsupported or withdrawn claims.

Do not modify train_controller.lua. Stop after the proof documents and implementation
plan are ready for user approval.
```
