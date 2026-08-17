# Plan: Fix pid-formal-proof.tex Critical Issues

## Summary
The user review identified 4 critical gaps in `immersive_railroading/docs/plans/pid-formal-proof.tex`:
1. Definition 6 lacks explicit mapping from OC API `u_b` to physics-engine `brakePressure`.
2. Assumption 1 ($\hat{a}_\text{brake}$) is asserted but not justified/established.
3. Definition 8 (Terminal Context) is under-specified: what it contains, where it comes from, and why it exists.
4. Section 2.1 state vector uses $s_\text{target}$ without defining it, making $e_s(k)$ ambiguous.

## Required Changes

### 1. Definition 6 — Brake Force: map $u_b$ to `brakePressure`
**Location:** Lines 110–124 (Brake Force definition)

**Change:** Add a new definition or proposition immediately after Definition 6 that formally establishes the mapping between the OC API control input and the physics engine variables. Include:
- Proposition: $u_b(k) = \texttt{brakePressure} = \texttt{independentBrakePosition}$ (the controller sets both via `remote.setBrake` and `remote.setIndependentBrake`, but for terminal stopping only the brake channel is used).
- Bytecode evidence: `clamp(max(brakePressure, independentBrakePosition), 0, 1)` means the physics engine uses the *maximum* of the two channels.
- Control allocation rule: The terminal PID sets $u_b(k)$ via `remote.setBrake(u_b(k))`; the independent brake is held at 0 during terminal stopping, so $\texttt{brakePressure} = u_b(k)$.
- Consequence: $F_\text{brake} = \text{designAdhesionNewtons} \cdot \text{clamp}(u_b(k), 0, 1)$ (modulo wheel-slip cap).

### 2. Assumption 1 — Justify $\hat{a}_\text{brake}$
**Location:** Lines 151–161 (Available Observable Parameters)

**Change:** Add a justification paragraph or new lemma after Assumption 1 that establishes why $\hat{a}_\text{brake}$ is a valid, bounded estimate:
- Reference the brake learner in `brake_model` (lines 529–530 of `train_controller.lua`): `learned_brake_mps2` is computed from observed deceleration during a test brake application.
- State the bound: $0 < \hat{a}_\text{brake} \leq a_\text{max}$ where $a_\text{max}$ is the physical maximum adhesion-limited deceleration ($g \cdot \mu_\text{steel} \approx 9.81 \cdot 0.3 \approx 2.9$ m/s² for steel-on-steel, or higher if `brakeMultiplier` is applied).
- Note: The learner’s estimate is conservative (it measures actual deceleration, not theoretical maximum), so using it as the nominal deceleration in the LQR design is safe: the controller will not command more braking than the train can physically deliver.
- **Learner update policy:** The brake learner at lines 2541–2561 and 4151–4173 only updates when:
  - `last_control.brake >= brake_learning_min_cmd` (0.2)
  - `last_control.throttle <= throttle_deadband` (≈0)
  - `|speed_toward_target_mps| >= brake_learning_min_speed_mps` (1.0 m/s)
  The update computes `observed_decel / effective_command` where `effective_command = max(brake_command^1.2, 0.05)`, then applies an exponential moving average with 12 s memory.
- **Terminal snapshot:** When terminal PID is first activated (line 3662), it snapshots `brake_model.full_service_mps2` into `state.terminal_pid`, so the PID gains freeze at terminal entry and do not adapt further during the stop.
- **Formal consequence:** In the proof, $\hat{a}_\text{brake}$ is the value of `brake_model.full_service_mps2` at terminal entry. Its bound is $0 < \hat{a}_\text{brake} \leq a_\text{max}$ where $a_\text{max}$ is the adhesion-limited deceleration.
- **Why using `full_service_mps2` directly (without learner) is acceptable for the proof:** The LQR optimality claim is *parametric*: for any given $\hat{a}_\text{brake}$, the derived gains are optimal for that model. Whether $\hat{a}_\text{brake}$ comes from the learner or the config constant does not affect the proof structure. What matters is that the value is a *valid lower bound on achievable deceleration* — the learner is conservative because it measures actual deceleration, not theoretical maximum, so the controller will never command more braking than the train can deliver.
- **Practical impact of learner vs constant:**
  - **Learner benefit:** adapts to actual train characteristics (different locomotives, loads, grades, brake wear). The fallback `fallback_brake_mps2 = 0.9` m/s² is intentionally conservative.
  - **Learner issues:** gated on conditions (needs sufficient brake command and speed); EMA can lag sudden changes (e.g., configuration change); early operation uses fallback until enough samples accumulate.
  - **Constant benefit:** deterministic, available immediately at startup, no warm-up period.
  - **Constant harm:** may be inaccurate for a specific train configuration, leading to suboptimal PID gains (too aggressive or too conservative).
- **Recommendation for the proof:** Use the notation $\hat{a}_\text{brake}$ uniformly. State that it is obtained from `brake_model.full_service_mps2`, which is either the config constant (initial) or the learner's EMA estimate (after operation). The proof treats it as an exogenous parameter; the learner is an *identification module* that produces this parameter.

**Critical constraint:** After checking `docs/runtime.md` and `train_controller.lua`, the IR OC API does **not** currently expose `designAdhesionNewtons`, `brakeMultiplier`, or `PhysicalMaterials.STEEL.kineticFriction` in the `info()` or `consist()` payloads. The observed fields are limited to `max_speed`, `horsepower`, `traction`, `weight`, `speed`, `reverser`, `direction`. Therefore the first-principles formula cannot be implemented in V1. The proof must still include it as a theoretical bound, but the implementation must rely on the learner/fallback.

**Revised bulletproof strategy:**

1. **Parametric LQR proof (core):** Prove that for ANY $\hat{a}_\text{brake} > 0$, the derived PID gains yield a stable, stopping-distance-guaranteed controller. This is the strongest possible claim: it says "however you obtain $\hat{a}_\text{brake}$, as long as it's positive, the controller works." This makes the proof completely independent of the estimation method.

2. **Theoretical upper bound (documentation):** Include the first-principles derivation as a theorem in the proof document. This establishes what the true physical maximum deceleration is, and why the learner/fallback are conservative approximations. Even though it can't be computed from the current API, it provides the theoretical grounding that justifies the bound $0 < \hat{a}_\text{brake} \leq a_\text{max}$.

3. **Implementation validity lemma:** Prove that the actual `brake_model.full_service_mps2` used by the code is always positive. This holds because:
   - It's initialized to `fallback_brake_mps2 = 0.9 > 0`
   - The learner update `ema(old, estimate, ...)` preserves positivity if both inputs are positive
   - `observed_decel >= 0` and `effective_command > 0` (floor of 0.05), so `estimate >= 0`
   - `min_brake_mps2 = 0.2` provides a runtime floor in `derive_pid` and other consumers
   - Therefore `brake_model.full_service_mps2 > 0` always holds

4. **Learner overestimation guard:** The learner's estimate at partial brake commands can theoretically exceed the true maximum deceleration (because `observed_decel / effective_command` scales up when `effective_command < 1`). The code mitigates this via:
   - The EMA smoothing (12 s memory) prevents single outliers from dominating
   - `conservative_stop_brake_mps2` caps at `approach_stop_brake_cap_mps2 = 1.0` m/s²
   - The fallback `0.9` is a reasonable upper bound for most trains
   - The proof's parametric result means even if $\hat{a}_\text{brake}$ is slightly overestimated, the controller remains stable (just slightly more aggressive than intended)

5. **Future-proofing note:** When/if future IR versions expose `designAdhesionNewtons` and `brakeMultiplier` via the OC API, replace the fallback with the first-principles formula and remove the learner's upper-bound concerns.

**Lua implementation changes:**
- Add `derive_brake_deceleration` as a documented function (even if it falls back to `fallback_brake_mps2` for now)
- Add a comment explaining the first-principles formula and why it can't be used yet
- Ensure the learner's estimate is bounded above by `approach_stop_brake_cap_mps2` in terminal stopping contexts

### 2.5 — Fix stability proof errors and add parametric guarantee
**Location:** Lines 376–418 (Stability Guarantee section)

**Critical bugs in the original proof:**
1. The characteristic polynomial is derived from a $2\times2$ state-space, but the PID has an integrator, so the state must be augmented to $3\times3$.
2. Sign convention is inconsistent: Eq. 8 has $u_b^* = -K_p e_s - K_v e_v$, but Eq. 9 has $u_b = K_p I + K_v e_v$ (positive). For braking, $u_b$ must be negative when $e_s > 0$.
3. The "critically damped" design at lines 400-416 is ad-hoc and doesn't follow from the LQR derivation.

**Change:** Rewrite the stability proof from scratch:
- Define augmented state $z(k) = [e_s(k), e_v(k), I(k)]^T$ where $I(k) = \sum_{i=0}^k e_s(i) \cdot dt$.
- Write the augmented state-space: $z(k+1) = A_z z(k) + B_z u_b(k) + w_z(k)$.
- With $u_b(k) = -K_p I(k) - K_v e_v(k)$, compute the closed-loop matrix $A_{cl} = A_z - B_z [0, K_v, K_p]$.
- Derive the characteristic polynomial $\det(\lambda I - A_{cl})$ explicitly.
- Show that for the critically damped design ($K_p = (1-e^{-2})/(\hat{a}\cdot dt)$, $K_v = 2(1-e^{-1})/(\hat{a}\cdot dt)$), all poles are at $\lambda = e^{-1}$ (inside the unit circle).
- **Parametric guarantee:** The proof must hold for ANY $\hat{a}_\text{brake} > 0$. The pole locations depend on $\hat{a}_\text{brake}$ only through the gain formulas; as long as gains are computed from the same $\hat{a}_\text{brake}$, the poles are at the desired location. This makes the stability claim completely independent of how $\hat{a}_\text{brake}$ was obtained.

### 3. Definition 8 — Expand Terminal Context
**Location:** Lines 178–180

**Change:** Replace the one-line definition with a structured description:
```latex
\begin{definition}[Terminal Context]
The \textbf{terminal context} $\mathcal{T}$ is a snapshot of all parameters required
to derive and execute the terminal-stopping PID controller, captured at the moment
the train enters stop guidance. It consists of:
\begin{itemize}
  \item $v_0$: entry speed [m/s], measured by \texttt{train.getCurrentSpeed()}
  \item $s_0$: available stopping distance [m], computed as
    $\texttt{distance\_to\_physical\_target} - \texttt{stop\_buffer}$
  \item $\hat{a}_\text{brake}$: estimated maximum brake deceleration [m/s²],
    from the brake learner or \texttt{brake\_model.full\_service\_mps2}
  \item $m$: total consist mass [kg], from \texttt{getConsistInfo()}
  \item $dt = 0.2$ s: fixed control period (MC server tick)
\end{itemize}
\textbf{Origin:} $\mathcal{T}$ is constructed by the stop-guidance entry logic in
\texttt{train\_controller.lua} (or the equivalent state machine) when the train
transitions from cruising to terminal stopping.
\textbf{Purpose:} $\mathcal{T}$ provides a complete, immutable description of the
terminal stopping scenario, ensuring the PID derivation (Theorems 5–9) and the
discrete-time implementation (Definition 10) operate on a well-defined input.
\end{definition}
```

### 4. Section 2.1 — Clarify state vector and $s_\text{target}$
**Location:** Lines 186–192

**Change:** Add an explanatory paragraph before the state vector equation:
- Clarify that $s(k)$ is the **distance to physical target** (a fixed point on the track), so $s(k) \to 0$ means the train has reached the target.
- Define $s_\text{target}$ explicitly: it is the target position, which we set to $0$ in our coordinate system (distance measured from the target). Thus $e_s(k) = s(k) - 0 = s(k)$ is simply the remaining distance.
- Alternatively, if $s(k)$ is absolute track position, then $s_\text{target}$ is the fixed target position and $e_s(k)$ is the position error. State which convention is used.
- Recommended: Use the convention that $s(k)$ is **distance to target** (as defined in Definition 1), so $s_\text{target} = 0$ and $e_s(k) = s(k)$. This avoids confusion.
- If keeping the general form $s(k) - s_\text{target}$, explicitly state: "$s_\text{target}$ is a constant equal to the physical target position; in our coordinate system where distance is measured from the target, $s_\text{target} = 0$."

## Validation
After edits, verify:
- [ ] All cross-references (labels) are intact.
- [ ] New definitions/theorems are numbered consistently.
- [ ] The document compiles with `pdflatex` (or at least has no obvious LaTeX errors).
- [ ] The Lean proof is updated to match the revised mathematical proof (augmented state-space, correct signs, parametric stability).
- [ ] First-principles derivation is included as a theoretical upper bound, with a note that the required fields (`designAdhesionNewtons`, `brakeMultiplier`) are not yet observable via the OC API.
- [ ] Learner positivity lemma is proved: `brake_model.full_service_mps2 > 0` always holds.
- [ ] Stability proof uses augmented $3\times3$ state-space including integrator.
- [ ] Sign conventions are consistent: braking command is negative in the state-space, positive in the PID output.
- [ ] Parametric stability holds for any $\hat{a}_\text{brake} > 0$.
