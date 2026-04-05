# Curve Handling V1.5: Direct Handoff for `fast`-Aware Deadlock Recovery

## Summary
- This handoff replaces `curve-handling-v1.4` as the current working context.
- Current state from the logs:
  - `test21` route-stall is improved in `test22`
  - `test20` terminal deadlock is also improved in `test22`
  - but the new deadlock-forward recovery now triggers too early and too slowly for `fast`
- The new main problem is:
  - the fallback meant for true deadlock is now acting like a normal end-approach mode
  - and its speed is effectively conservative-level, not `fast`
- `route` remains the primary focus. `goto` and `goto --via` still ride the same shared route/leg runner automatically.

## Sources
- `AGENTS.md`
- `programs/train_controller.lua`
- `docs/runtime.md`
- `docs/control-model.md`
- real save logs:
  - `path_test19.log`
  - `path_test20.log`
  - `path_test21.log`
  - `path_test22.log`
- local verification:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`

## Current Verified State
- The single V1 production controller remains `programs/train_controller.lua`.
- Save and workspace controllers are currently identical.
- The current controller already contains:
  - `guidance_mode=route|stop`
  - `terminal_stop_target`
  - `terminal_brake_snapshot_mps2`
  - `terminal_buffer_brake_active`
  - `buffer_settle_mode`
  - `terminal_success_stop_ok`
  - `terminal_success_physical_ok`
- Local verification for the current workspace state is green:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
- The previously verified good buffered-stop reference from the current project state remains:
  - `arrived_at_target`
  - `stop_buffer_m=6`
  - `physical_distance=5.24m`
  - `physical_buffer_error=0.76m`
  - `terminal_success_stop_ok=true`
  - `terminal_success_physical_ok=true`

## Diagnosis
- `path_test19.log` remains the “bad physical halt is rejected” reference:
  - `physical_distance=3.63m`
  - `physical_buffer_error=2.37m`
  - `terminal_success_stop_ok=true`
  - `terminal_success_physical_ok=false`
  - not falsely accepted
- `path_test20.log` shows the original terminal deadlock:
  - `stop_guidance_entry_physical_distance=9.99m`
  - `stop_guidance_entry_stop_longitudinal=3.94m`
  - repeated `final_brake_hold`
  - `buffer_settle_mode=none`
  - `buffer_settle_block_reason=target_ahead`
  - no `terminal_limit_exit`
- `path_test21.log` shows the route-guidance stall:
  - `stop_guidance_entry=false`
  - `guidance_mode=route`
  - repeated `reason=overspeed`
  - `physical_distance=8.57m`
  - `throttle=0.00`
  - `brake=0.00`
  - no forward progress
- `path_test22.log` shows the new intermediate state:
  - the route-stall is gone
  - the terminal deadlock is partially improved
  - but `deadlock_forward_recovery` now activates too early
  - `stop_guidance_entry` occurs at `physical_distance=7.32m`
  - `stop_longitudinal=4.28m`
  - then `buffer_settle_mode=forward`
  - `buffer_settle_block_reason=deadlock_forward_recovery`
  - `fast` correction runs at about `cap=0.15m/s` with tiny throttle
- Explicit conclusion:
  - the current deadlock-forward path is too broad
  - it is acting like a normal terminal approach mode instead of a true deadlock fallback
  - it is also too slow for `fast`, effectively collapsing to conservative-level correction

## Implementation Changes
- Keep the existing route geometry, stop-axis model, CLI, and route-book unchanged.
- Keep the route-stall fix from `v1.4`.
- Refine only the new deadlock-forward path so it becomes:
  - a true deadlock fallback
  - profile-aware
  - not the default `fast` terminal approach behavior

### Deadlock-forward entry must become stricter
- `deadlock_forward_recovery` must no longer activate merely because:
  - target is ahead
  - reverse says `target_ahead`
  - speed is low enough
- It must require a real deadlock/stall signature:
  - `guidance_mode == "stop"`
  - `stop_context.in_no_reverse_approach == true`
  - target still ahead
  - `terminal_success_consistent == false`
  - train nearly stationary
  - stall has persisted for a short time
- Add a dedicated state field:
  - `terminal_deadlock_candidate_since = nil`
- Reset it whenever:
  - target-ahead progress resumes
  - stop target is no longer materially ahead
  - speed rises back above the stall threshold
  - mode leaves terminal stop guidance

### Separate deadlock gating from fine-trim gating
- Keep three distinct forward concepts:
  - normal `forward settle`
  - deadlock-forward recovery
  - ordinary `approach_stop`
- Deadlock-forward must not activate while the train is still in a plausible normal stop approach.
- Concretely:
  - if `approach_stop` is still valid and the train is not truly stalled, stay in braking logic
  - only allow deadlock-forward after the train has effectively come to a stop short of the target

### Make deadlock-forward profile-aware
- Current `test22` shows `fast` recovery running at `cap=0.15m/s`, which is effectively conservative.
- Split deadlock-forward speed and throttle by profile so `fast` is materially quicker than `conservative`.
- Add these defaults:
```lua
-- DEFAULTS
terminal_deadlock_stall_speed_mps = 0.10,
terminal_deadlock_stall_time_s = 0.75,
```
- Use these profile values:
```lua
-- conservative
buffer_settle_forward_deadlock_speed_mps = 0.15,
buffer_settle_forward_deadlock_throttle_limit = 0.04,
```

```lua
-- fast
buffer_settle_forward_deadlock_speed_mps = 0.35,
buffer_settle_forward_deadlock_throttle_limit = 0.06,
```
- Keep `fast` deadlock-forward clearly slower than normal `fast` travel, but no longer conservative-level.

### Change the helper shape
- Replace the current deadlock-forward helper with one that also receives `now`.
- It should only return eligible when the run has actually stalled.
- Expected helper shape:
```lua
local function forward_deadlock_recovery_block_reason(
  profile,
  state,
  longitudinal_error_m,
  lateral_error_m,
  speed_toward_target_mps,
  axis_speed_mps,
  stop_context,
  now
)
  if not stop_context or not stop_context.in_no_reverse_approach then
    return "outside_no_reverse_approach"
  end
  if stop_context.must_stop_now then
    return "must_stop_now"
  end
  if longitudinal_error_m <= DEFAULTS.arrival_longitudinal_m then
    return longitudinal_error_m < 0 and "target_behind" or "inside_arrival_window"
  end
  if longitudinal_error_m > (profile.buffer_settle_forward_deadlock_max_longitudinal_m or DEFAULTS.terminal_deadlock_forward_max_longitudinal_m) then
    return "beyond_deadlock_forward_window"
  end
  if lateral_error_m > (profile.buffer_settle_max_lateral_m or DEFAULTS.near_target_correction_lateral_m) then
    return "lateral_error_too_large"
  end
  if state.stop_first_active or state.near_target_correction_active then
    return "higher_priority_terminal_recovery"
  end
  if math.abs(speed_toward_target_mps) > DEFAULTS.terminal_deadlock_stall_speed_mps then
    return "not_stalled_yet"
  end
  if math.abs(axis_speed_mps) > math.max(DEFAULTS.terminal_deadlock_stall_speed_mps, DEFAULTS.arrival_speed_mps * 0.5) then
    return "axis_not_stalled_yet"
  end
  if not state.terminal_deadlock_candidate_since then
    return "waiting_for_deadlock_timer"
  end
  if now - state.terminal_deadlock_candidate_since < DEFAULTS.terminal_deadlock_stall_time_s then
    return "waiting_for_deadlock_timer"
  end
  return nil
end
```

### Add explicit deadlock-candidate state management
- Add state fields in leg state:
  - `terminal_deadlock_candidate_since = nil`
  - optional `terminal_deadlock_recovery_active = false`
- Update every tick in terminal stop guidance:
  - if target still ahead, stop-context active, and speed nearly zero:
    - start or keep `terminal_deadlock_candidate_since`
  - else:
    - clear it

### Keep `fast` from looking conservative during correction
- When deadlock-forward is active:
  - use a dedicated cap/throttle limit for the profile
  - do not reuse the normal `buffer_settle_forward_speed_mps`
- In the drive branch, add:
```lua
if buffer_settle_mode == "forward" and buffer_settle_block_reason == "deadlock_forward_recovery" then
  throttle_limit = math.min(
    throttle_limit,
    profile.buffer_settle_forward_deadlock_throttle_limit or profile.buffer_settle_forward_throttle_limit or throttle_limit
  )
end
```
- In settle selection, if deadlock-forward becomes active:
```lua
target_speed_mps = math.min(
  target_speed_mps,
  profile.buffer_settle_forward_deadlock_speed_mps or DEFAULTS.terminal_deadlock_forward_speed_mps
)
```

## Test Plan
- `test22`-style regression:
  - route-stall must stay fixed
  - deadlock-forward must not activate immediately after `stop_guidance_entry` while the train is still in a plausible normal stop approach
  - `fast` deadlock-forward, when it does activate, must use a visibly higher target speed than `0.15m/s`
- `test20`-style regression:
  - no endless `final_brake_hold`
  - acceptable outcomes:
    - delayed true deadlock-forward recovery
    - or explicit `terminal_limit_exit`
- `test19`-style regression:
  - still must not be falsely accepted
- Local checks:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
- Preview additions:
  - deadlock-forward does not activate before stall timer elapses
  - deadlock-forward activates after stall timer with target still ahead
  - `fast` deadlock-forward speed cap is greater than conservative
  - route-guidance brake-release stall fix still holds

## Assumptions
- The `v1.4` route-stall fix should stay in place.
- The next step is not another geometry redesign; it is narrowing and retuning the new recovery path.
- `fast` should remain more assertive than `conservative` even during recovery, but still clearly slower than normal tracking.
