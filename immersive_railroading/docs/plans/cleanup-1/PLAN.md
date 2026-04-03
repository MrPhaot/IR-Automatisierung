# One-Pass Cleanup Plan For Remaining Review Churn

## Summary
Handle the remaining review-prone issues in one coordinated pass across the wrapper, controller, and preview harness. The goal is to eliminate three classes of recurring comments at once:

- wrapper exit/error handling that still loses intent on thrown failures
- controller inconsistencies between target-axis and motion-axis logic, plus weak safe-stop behavior
- preview drift caused by copied constants/path tables instead of canonical sources

Already-fixed docs/lint items stay untouched in this pass.

## Current State
- This is a cleanup and anti-drift pass, not a curve-handling pass.
- Many earlier review items are already fixed and should not be reopened first:
  - docs lint and wording cleanups
  - abort logging and `aborted_by_user`
  - preview `must_stop_now` shadowing
  - preview brake-exit margin alignment
  - preview runtime-error normalization order
  - `train_controller.lua` auto-run preserving exit code `130`
- The remaining open items match the current code:
  - `programs/trainctl.lua` still calls `controller("__module__")` directly
  - `programs/trainctl.lua` still calls `module.main({...})` directly
  - `programs/train_controller.lua` still prefers `info` power before `consist`
  - `programs/train_controller.lua` still recomputes `speed_toward_target_mps` from `axis_speed_mps` in the two special branches
  - `programs/train_controller.lua` `apply_safe_stop()` still delegates to `apply_controls()`
  - `tests/previews/controller_preview.lua` still duplicates `PROFILES`, `INFO_PATHS`, and `HORSEPOWER_PATHS`
- Non-goal:
  - do not change route or curve-planning behavior in this cleanup pass

## Key Changes
- In `programs/trainctl.lua`, harden the wrapper completely.
  - Add a tiny local helper for interrupt-like reasons: `"interrupted"`, `"terminated"`, `"terminate"`.
  - Wrap both `controller("__module__")` and `module.main({...})` in `pcall`.
  - Normalize or stringify thrown errors before exit-code decisions.
  - Preserve the current stderr behavior.
  - Exit `130` for:
    - `"aborted by user"`
    - normalized interrupt-like reasons from returned errors
    - normalized interrupt-like reasons from thrown errors
  - Exit `1` for all other failures.
  - Do not change the controller’s built-in auto-run block; only harden the standalone wrapper.

- In `programs/train_controller.lua`, make consist totals and motion-axis behavior consistent.
  - Change `extract_characteristics()` so `power_w` prefers `consist` before `info`.
  - Keep kW-to-W scaling, horsepower fallback, and final fallback defaults exactly as they are.
  - Also switch the horsepower fallback order to `consist` first, then `info`, so power precedence matches mass and traction.
  - Keep `raw_desired_reverser` anchored to `longitudinal_error_m` on `target_axis`.
  - Keep `axis_speed_mps` for target-line diagnostics, terminal-limit checks, and logs.
  - Ensure every recomputation of `speed_toward_target_mps` uses `motion_axis_speed_mps * desired_reverser`, not `axis_speed_mps * desired_reverser`, including the special branches after `suppress_reverse_recovery` and inside `stop_first_active`.

- In `programs/train_controller.lua`, rewrite `apply_safe_stop()` as a real best-effort safe stop.
  - Keep `safe_stop_control(brake)` as the source of desired stop values.
  - Do not call `apply_controls()` from `apply_safe_stop()`.
  - Invoke setters independently in this order:
    1. `setBrake`
    2. `setIndependentBrake`
    3. `setThrottle`
    4. `setReverser`
  - Wrap each setter in its own `pcall`, collect failures, and continue attempting the remaining setters.
  - If any setter failed, raise one aggregated error string after all attempts complete.
  - Keep `abort_run()` retry-once behavior, but let it benefit from the stronger `apply_safe_stop()` implementation.

- In `programs/train_controller.lua`, expose canonical definitions for preview reuse.
  - Extend the `exports` table returned in `__module__` mode to include:
    - `DEFAULTS`
    - `PROFILES`
    - `INFO_PATHS`
    - `HORSEPOWER_PATHS`
    - `HORSEPOWER_TO_W`
  - Do not export more internal behavior than needed for the preview harness.

- In `tests/previews/controller_preview.lua`, stop duplicating production tables.
  - Load `train_controller.lua` in module mode with `loadfile(... )("__module__")`.
  - Replace the local copies of:
    - `DEFAULTS`
    - `PROFILES`
    - mass/traction/power/max-speed lookup arrays
    - horsepower path arrays
    with canonical values from the production module.
  - Keep local helper functions where needed, but source their constants and lookup precedence from the imported canonical tables.
  - Keep the existing `must_stop_now_fn` / `stop_now_flag` rename; do not reintroduce the old shadowing.

- In `tests/previews/controller_preview.lua`, align the remaining helper behavior with production.
  - Use imported `DEFAULTS.min_brake_mps2` and imported `PROFILES` in `profiled_stop_speed_cap()`.
  - Use imported `INFO_PATHS` and `HORSEPOWER_PATHS` in `extract_characteristics()`.
  - Use imported `HORSEPOWER_TO_W` instead of a local magic number.
  - Keep the existing brake-release-hold, coast, interrupt-normalization, and stop-context logic already brought into parity.
  - Add or keep assertions that prove:
    - consist-first power wins over info-level power
    - nested/camelCase lookup variants resolve correctly
    - fast/conservative profile data are fully present
    - preview still passes after switching to canonical imports

## Test Plan
- Wrapper:
  - Read `programs/trainctl.lua` and confirm both module load and `module.main` are `pcall`-protected.
  - Confirm:
    - returned `"aborted by user"` exits `130`
    - thrown/returned interrupt-like errors exit `130`
    - all other failures exit `1`

- Controller:
  - `luac -p immersive_railroading/programs/train_controller.lua`
  - Re-read `extract_characteristics()` and confirm power now prefers consist first.
  - Re-read all `speed_toward_target_mps = ...` assignments and confirm they consistently use `motion_axis_speed_mps`.
  - Re-read `apply_safe_stop()` and confirm it:
    - does not call `apply_controls()`
    - attempts every setter independently
    - aggregates failures instead of short-circuiting

- Preview:
  - `lua immersive_railroading/tests/previews/controller_preview.lua`
  - `rg -n "local DEFAULTS = \\{|local PROFILES = \\{|local mass_paths =|local traction_paths =|local power_paths =|local horsepower_paths =|local max_speed_paths =" immersive_railroading/tests/previews/controller_preview.lua`
    and confirm it returns no matches, because the preview now imports canonical tables instead of defining local copies.
  - Search the preview for:
    - `local DEFAULTS = {`
    - `local PROFILES = {`
    - local duplicated mass/traction/power/max-speed path arrays
    and confirm those copies are gone.
  - Search for `must_stop_now` and confirm only the intentional helper and `stop_context.must_stop_now` usage remain.
  - Keep assertions for:
    - consist-first power extraction
    - nested key variants
    - coast behavior
    - brake-release hold
    - interrupt normalization
    - imported profile completeness

- Cleanup packet:
  - Re-read `docs/plans/cleanup-1/PLAN.md`, `docs/plans/cleanup-1/HANDOFF.md`, and `docs/plans/cleanup-1/PROMPT.md` together.
  - Confirm they are self-contained and do not require older chat history.
  - Confirm the handoff clearly separates already-fixed work from still-open cleanup items.

## Assumptions
- The cleanest anti-drift solution is module-mode reuse of canonical controller tables, not continued manual synchronization in the preview.
- `apply_safe_stop()` should prioritize “attempt all stop-related setters” over fail-fast behavior because it is used only on shutdown/abort/backstop paths.
- `target_axis` remains the route frame, while `motion_axis` is the stabilized motion interpretation; this pass only makes that separation consistent, not broader route-planning changes.
- The cleanup packet should follow the established `foundation-v1` structure, so adding both `HANDOFF.md` and `PROMPT.md` is the most durable choice.
