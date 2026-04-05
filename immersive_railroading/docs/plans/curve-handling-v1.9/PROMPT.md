# Curve Handling V1.9 Prompt

You are continuing the current curve-handling debugging thread for the Immersive Railroading OpenComputers project in:

`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`

Use this handoff as the current working context:

`docs/plans/curve-handling-v1.9/PLAN.md`

## Important constraints
- You may write only inside `/home/mrphaot/Dokumente/lua/minecraft`.
- The PrismLauncher instance and the save are inspect-only:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`
- Do not invent APIs or behavior. Inspect real code and real logs first.
- `programs/train_controller.lua` stays the single production controller file for V1.
- Comments should explain mainly why.
- Prefer reading real logs directly instead of screenshots.

## Read in this order before making changes
1. `AGENTS.md`
2. `docs/plans/curve-handling-v1.9/PLAN.md`
3. `docs/runtime.md`
4. `docs/control-model.md`
5. `programs/train_controller.lua`
6. Relevant real logs, especially `path_test19.log`, `path_test20.log`, `path_test23.log`, `path_test26.log`, and `path_test27.log`

## Current verified local state
- `luac -p programs/train_controller.lua` is green.
- `lua tests/previews/controller_preview.lua` is green.
- Existing preview output currently includes:
  - `pid ok: kp=0.0941 ki=0.0109 kd=0.4500`
  - `brake learning ok: 1.230 m/s^2`
  - `stop profile ok: 7.36 m/s at 25m, 21.24 m/s at 400m`
  - `lateral frame regression ok: 15.28 m/s cap stays above zero`
  - `axis capture regression ok: sideways startup jitter rejected`
  - `target line axis regression ok: target geometry stays primary over early motion samples`
  - `approach stop regression ok: late braking is forced near the target`
  - `overshoot recovery regression ok: small overshoot keeps braking before reverse recovery`
  - `terminal brake hold regression ok: approach stop does not release the brake too early`
  - `off-target line regression ok: large residual miss is not treated as a valid terminal arrival`
  - `curve guard regression ok: bends do not immediately trigger moving-away braking`
  - `startup guard regression ok: early shallow regressions do not trigger stop-and-go`
  - `interrupt regression ok: interrupted and terminated reasons are recognized`
  - `canonical import regression ok: preview uses production defaults, profiles, and lookup paths`
  - `characteristic extraction ok: mass=100493 traction=194161 power=1900789W`
- `tests/previews/test_outside_capture_window.lua` already exists and should remain green.

## Root cause you must preserve
- The remaining issue is primarily not the global PID.
- The remaining issue is primarily not another brake/throttle tuning problem.
- The main cause is that stop-guidance deadlock detection still depends on the wrong progress signal.
- `state.progress_speed_mps` is reused across the route-guidance to stop-guidance transition even though the target frame changes from physical target to terminal stop target.
- That contaminates the stall signal after `stop_guidance_entry`.
- As a result, `waiting_for_deadlock_timer` can repeat indefinitely because `terminal_deadlock_candidate_since` does not mature on a clean stop-relative stagnation signal.

## Interpretation of recent tests
- `test23` was the old pre-stop route stall with no `stop_guidance_entry`.
- `test26` showed partial improvement: `stop_guidance_entry` returned, but failure/recovery behavior was still unstable.
- `aaae838` improved two real things:
  - adaptive `terminal_buffer_progress_floor(...)`
  - `terminal_failure_arming_allowed(...)` to serialize failure behind `waiting_for_deadlock_timer`
- `test27` now exposes the remaining root issue clearly:
  - `terminal_failure_pending` stays false as intended
  - but `waiting_for_deadlock_timer` repeats
  - `deadlock_forward_recovery` never activates
  - the run stalls until manual abort

## Your implementation priorities are fixed
1. Introduce a dedicated stop-guidance-local progress signal.
2. Reset and initialize it explicitly on `stop_guidance_entry`.
3. Use it for `target_ahead_stalled` instead of `state.progress_speed_mps`.
4. Keep `terminal_failure_arming_allowed(...)` as-is.
5. Only secondarily, if still needed, widen `terminal_buffer_progress_floor(...)` applicability.

## Implement exactly this
1. In `begin_leg(...)`, add:
   - `stop_previous_distance_to_target_m = nil`
   - `stop_distance_delta_m = 0`
   - `stop_progress_speed_mps = 0`
   - `stop_progress_initialized = false`
2. On `stop_guidance_entry`:
   - reset the stop-local progress fields
   - seed `stop_previous_distance_to_target_m` from `distance_to_stop_target_m`
   - ensure the physical-target to stop-target frame switch does not create a fake progress sample
3. During `guidance_mode == "stop"`:
   - compute raw stop progress only from `distance_to_stop_target_m`
   - smooth it independently from the route-level progress signal
   - update `stop_previous_distance_to_target_m` after the sample
4. In `target_ahead_stalled`:
   - replace the dependency on `state.progress_speed_mps` with `state.stop_progress_speed_mps`
   - keep the `speed_toward_target_mps` and `axis_speed_mps` gates
5. Keep `terminal_failure_arming_allowed(buffer_settle_block_reason)`.
6. Extend runtime logging minimally with:
   - `stop_distance_delta`
   - `stop_progress_speed`
   - optional `stop_progress_initialized`
7. Only if still needed after the root-cause fix:
   - widen `terminal_buffer_progress_floor` activation slightly deeper into route-guidance pre-stop approach
   - do not turn the work into another threshold-only tuning pass

## Do not
- redesign route geometry
- redesign waypoint semantics
- redesign CLI behavior
- redesign `route_book`
- redesign the global PID model
- solve this only by changing `terminal_deadlock_stall_time_s` or similar constants
- remove the current failure-arming serialization

## Required preview/test work
- Keep these green:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - `lua tests/previews/test_outside_capture_window.lua`
- Add preview coverage for:
  - stop-progress reset on `stop_guidance_entry`
  - deadlock candidate logic using stop-local progress instead of global progress
  - `terminal_failure_arming_allowed("waiting_for_deadlock_timer")` remaining false
  - no regression of the outside-capture-window block case
- If possible, inspect a fresh real save log and report:
  - `stop_guidance_entry`
  - `stop_progress_speed`
  - `waiting_for_deadlock_timer`
  - `terminal_deadlock_candidate_elapsed_s`
  - `deadlock_forward_recovery`
  - `terminal_failure_pending`
  - `terminal_limit_exit`

## When you are done, summarize
- how the root cause was fixed technically
- how stop-local progress differs from the old shared progress signal
- whether `test27` now reaches recovery instead of waiting forever
- which previews/checks you verified locally
- what remains uncertain in the real save
