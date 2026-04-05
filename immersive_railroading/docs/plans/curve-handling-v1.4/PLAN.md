# Curve Handling V1.4: Current-State Handoff for Route-Stall and Terminal-Deadlock Fix

## Summary
- This handoff supersedes `curve-handling-v1.3` as the next working context.
- It is based only on the current controller and current save evidence.
- The previous deadlock fix was incomplete. There are now two active regressions:
  1. terminal deadlock after `stop_guidance`
  2. route-guidance stall before `stop_guidance`
- `route` is the primary focus. `goto` and `goto --via` still inherit the same terminal behavior automatically because they use the same route/leg runner.

## Sources
- `AGENTS.md`
- `programs/train_controller.lua`
- `docs/runtime.md`
- `docs/control-model.md`
- real save logs:
  - `path_test19.log`
  - `path_test20.log`
  - `path_test21.log`
- local verification:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`

## Current Verified State
- The single V1 production controller remains `programs/train_controller.lua`.
- The current controller already contains:
  - `guidance_mode=route|stop`
  - `terminal_stop_target`
  - `terminal_brake_snapshot_mps2`
  - `terminal_buffer_brake_active`
  - `buffer_settle_mode`
  - `terminal_success_stop_ok`
  - `terminal_success_physical_ok`
- Workspace and save controllers are currently identical.
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
- `path_test19.log` remains the relevant “bad halt is rejected” reference:
  - farther-start run
  - `physical_distance=3.63m`
  - `physical_buffer_error=2.37m`
  - `terminal_success_stop_ok=true`
  - `terminal_success_physical_ok=false`
  - not falsely accepted; user aborts
- `path_test20.log` shows the terminal deadlock:
  - `stop_guidance_entry_physical_distance=9.99m`
  - `stop_guidance_entry_stop_longitudinal=3.94m`
  - repeated `final_brake_hold`
  - `buffer_settle_mode=none`
  - `buffer_settle_block_reason=target_ahead`
  - no `terminal_limit_exit`
  - user aborts
- `path_test21.log` shows the new route-guidance stall:
  - never enters `stop_guidance`
  - repeated `guidance_mode=route`
  - repeated `reason=overspeed`
  - `stop_guidance_entry=false`
  - `stop_guidance_block_reason=outside_capture_window`
  - `physical_distance=8.57m`
  - `throttle=0.00`
  - `brake=0.00`
  - user aborts
- Explicit conclusion:
  - there are two regressions now:
    1. terminal deadlock after `stop_guidance`
    2. route-guidance stall caused by `brake_release_until` / motion-mode interaction
- Current code-level diagnosis:
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L1002) already allows failure for inconsistent terminal stops, so the old “never fail at all” issue is only partially addressed
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L899) still blocks forward settle outside the narrow fine-trim window
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L2967) still has no separate target-ahead deadlock-forward-recovery branch
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L1071) applies brake-release hold before normal route mode selection
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L3456) re-arms `brake_release_until` even when the computed brake has already fallen to zero in normal route guidance
  - together this creates a self-sustaining route-guidance stall in `test21`, and leaves `test20` without a dedicated forward escape hatch when reverse correctly reports `target_ahead`

## Implementation Direction
- Do not redesign route geometry.
- Do not redesign waypoints.
- Do not change CLI behavior.
- Do not change route-book schema.
- Do not redesign logging.
- Fix these two things only:
  - route-guidance overspeed stall
  - target-ahead terminal deadlock
- Then preserve existing correctness behavior:
  - `path_test19` must still not be falsely accepted
  - the previously good buffered-stop reference must remain possible
- Failure order after `stop_guidance` must be explicit and exhaustive:
  - success
  - forward settle
  - reverse settle
  - terminal failure
  - never endless `final_brake_hold`

## Exact Code Shape
- The next agent should implement these changes exactly unless direct local code inspection reveals a concrete placement conflict. If names or placement need adaptation, preserve the semantics exactly.

### 1. Add deadlock-forward defaults
- Add these fields next to the existing terminal/buffer settle defaults in `DEFAULTS`:
```lua
terminal_deadlock_forward_max_longitudinal_m = 12.0,
terminal_deadlock_forward_speed_mps = 0.15,
```

### 2. Add deadlock-forward profile values
- Add these fields to both profiles next to the existing `buffer_settle_forward_*` values:
```lua
buffer_settle_forward_deadlock_max_longitudinal_m = 12.0,
buffer_settle_forward_deadlock_speed_mps = 0.15,
```
- Keep the current fine-trim forward windows unchanged. The new fields are only for the broader “target still ahead but already stalled” recovery corridor.

### 3. Add a separate helper for target-ahead deadlock recovery
- Add this helper after `forward_buffer_settle_block_reason(...)` and before `reverse_buffer_settle_block_reason(...)`:
```lua
local function forward_deadlock_recovery_block_reason(
  profile,
  state,
  longitudinal_error_m,
  lateral_error_m,
  speed_toward_target_mps,
  axis_speed_mps,
  stop_context
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
  if state.moving_away_confidence >= DEFAULTS.moving_away_confidence_threshold then
    return "moving_away_risk"
  end
  if math.abs(speed_toward_target_mps) > (profile.buffer_settle_forward_deadlock_speed_mps or DEFAULTS.terminal_deadlock_forward_speed_mps) then
    return "speed_too_high"
  end
  if math.abs(axis_speed_mps) > math.max(
    profile.buffer_settle_forward_deadlock_speed_mps or DEFAULTS.terminal_deadlock_forward_speed_mps,
    DEFAULTS.arrival_speed_mps * 2
  ) then
    return "axis_speed_too_high"
  end
  return nil
end
```

### 4. Patch settle selection for `target_ahead`
- In the terminal stop-guidance settle-selection block, keep the existing order:
  1. normal forward settle
  2. reverse settle
- Add a third branch for `reverse_block == "target_ahead"`, using the new helper.
- Use this patch shape:
```lua
        if not forward_block then
          buffer_settle_mode = "forward"
          buffer_settle_eligible = true
          buffer_settle_block_reason = "eligible"
          desired_reverser = 1
          target_speed_mps = math.min(target_speed_mps, profile.buffer_settle_forward_speed_mps)
        else
          local reverse_block = reverse_buffer_settle_block_reason(
            profile,
            state,
            raw_desired_reverser,
            stop_longitudinal_error_m,
            stop_lateral_error_m,
            speed_toward_target_mps,
            axis_speed_mps,
            stop_context
          )

          if reverse_block == "target_ahead" then
            local deadlock_forward_block = forward_deadlock_recovery_block_reason(
              profile,
              state,
              stop_longitudinal_error_m,
              stop_lateral_error_m,
              speed_toward_target_mps,
              axis_speed_mps,
              stop_context
            )
            if not deadlock_forward_block then
              buffer_settle_mode = "forward"
              buffer_settle_eligible = true
              buffer_settle_block_reason = "deadlock_forward_recovery"
              desired_reverser = 1
              target_speed_mps = math.min(
                target_speed_mps,
                profile.buffer_settle_forward_deadlock_speed_mps or DEFAULTS.terminal_deadlock_forward_speed_mps
              )
            else
              terminal_recovery_block = deadlock_forward_block
              terminal_recovery_eligible = false
              buffer_settle_block_reason = deadlock_forward_block
            end
          else
            terminal_recovery_block = reverse_block or "eligible"
            terminal_recovery_eligible = reverse_block == nil
            if not reverse_block then
              buffer_settle_mode = "reverse"
              buffer_settle_eligible = true
              buffer_settle_block_reason = "eligible"
              desired_reverser = -1
              target_speed_mps = math.min(target_speed_mps, profile.buffer_settle_reverse_speed_mps)
            else
              buffer_settle_block_reason = forward_block
              if reverse_block ~= "profile_disabled" or profile.name == "fast" then
                buffer_settle_block_reason = reverse_block
              end
            end
          end
        end
```
- Important:
  - keep reverse recovery narrow
  - do not weaken `target_ahead`
  - deadlock-forward recovery is only a forward escape hatch for stalled target-ahead stop states

### 5. Restrict brake-release hold in `select_motion_mode(...)`
- Replace the current unconditional `must_hold_brake` definition with this context-aware version:
```lua
local brake_hold_allowed = state.guidance_mode == "stop"
  or must_stop_now
  or (stop_context and (stop_context.in_approach_stop or stop_context.in_no_reverse_approach))
local must_hold_brake = brake_hold_allowed
  and state.brake_release_until
  and uptime() < state.brake_release_until
```
- This must preserve stop-phase brake hold behavior while allowing normal route-guidance overspeed control to leave brake mode again.

### 6. Restrict where `brake_release_until` is armed
- In the brake branch, replace the current deadband tail with:
```lua
local allow_brake_release_hold = state.guidance_mode == "stop"
  or stop_context.must_stop_now
  or stop_context.in_approach_stop
  or stop_context.in_no_reverse_approach

if brake < DEFAULTS.brake_deadband then
  brake = 0
  if allow_brake_release_hold then
    state.brake_release_until = now + DEFAULTS.brake_release_hold_s
  else
    state.brake_release_until = nil
  end
else
  state.brake_release_until = nil
end
```
- This is required to prevent the `test21` route-guidance overspeed stall where the controller sits in brake mode with both `throttle=0` and `brake=0`.

### 7. Minimal extra state/logging only if needed
- Do not redesign logging.
- Optional but acceptable:
  - add `terminal_deadlock_recovery_active`
  - set it true only when the forward deadlock path is active
- If no dedicated flag is added, the existing combination
  - `buffer_settle_mode=forward`
  - `buffer_settle_block_reason=deadlock_forward_recovery`
  is already sufficient and should be preferred over broader log churn.

## Preview Additions
- Extend the preview rather than inventing a new test harness.
- Add a deadlock-forward branch to the preview settle chooser after the normal forward branch and before reverse:
```lua
  if stop_context.in_no_reverse_approach
    and not stop_context.must_stop_now
    and geometry.stop_longitudinal_error_m > (profile.buffer_settle_forward_max_longitudinal_m or 0)
    and geometry.stop_longitudinal_error_m <= (profile.buffer_settle_forward_deadlock_max_longitudinal_m or DEFAULTS.terminal_deadlock_forward_max_longitudinal_m)
    and geometry.stop_lateral_error_m <= (profile.buffer_settle_max_lateral_m or DEFAULTS.near_target_correction_lateral_m)
    and math.abs(geometry.speed_toward_target_mps) <= (profile.buffer_settle_forward_deadlock_speed_mps or DEFAULTS.terminal_deadlock_forward_speed_mps)
    and math.abs(geometry.axis_speed_mps) <= math.max(
      profile.buffer_settle_forward_deadlock_speed_mps or DEFAULTS.terminal_deadlock_forward_speed_mps,
      DEFAULTS.arrival_speed_mps * 2
    ) then
    return "forward"
  end
```
- Add these exact assertions:
```lua
assert(
  preview_buffer_settle_mode(
    "fast",
    false,
    false,
    {stop_first_active = false, near_target_correction_active = false},
    {in_no_reverse_approach = true, must_stop_now = false},
    {
      raw_desired_reverser = 1,
      stop_longitudinal_error_m = 3.94,
      stop_lateral_error_m = 0.98,
      speed_toward_target_mps = 0.0,
      axis_speed_mps = 0.0,
    }
  ) == "forward",
  "log20-style target-ahead terminal stall should enter deadlock-forward recovery"
)
```

```lua
assert(
  select_motion_mode({
    mode = "brake",
    guidance_mode = "route",
    near_target_correction_active = false,
    profile_name = "fast",
    brake_release_until = 120,
  }, 0.0, 1.41, 8.57, {must_stop_now = false, in_no_reverse_approach = false, in_approach_stop = false}) ~= "brake",
  "route-guidance overspeed fallback must not deadlock on brake-release hold when the brake command has already dropped to zero"
)
```

```lua
assert(
  select_motion_mode({
    mode = "brake",
    guidance_mode = "stop",
    near_target_correction_active = false,
    profile_name = "fast",
    brake_release_until = 120,
  }, 0.0, 1.41, 4.04, {must_stop_now = false, in_no_reverse_approach = true, in_approach_stop = false}) == "brake",
  "stop-guidance no-reverse hold must still honor brake-release hold in the true terminal stop phase"
)
```
- Keep existing assertions for:
  - terminal brake hold regression
  - off-target line regression
  - conservative forward settle
  - fast reverse settle boundaries

## Non-Goals
- No return to old curve-before-terminal planning
- No generic buffer retuning first
- No waypoint redesign
- No CLI or route-book work
- No deployment/debugging tangent unless the save/workspace identity check becomes false again

## Test Plan
- Static checks:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
- Real-log validation must use save logs, not screenshots.
- Acceptance scenarios:
  - `path_test20` must no longer hang in `final_brake_hold`
  - acceptable outcomes:
    - forward deadlock recovery
    - or explicit `terminal_limit_exit`
  - `path_test21` must no longer freeze in `guidance_mode=route` with `reason=overspeed`, `throttle=0.00`, and `brake=0.00`
  - for `path_test21`, acceptable outcomes are:
    - route guidance resumes toward capture
    - or `stop_guidance` is reached
    - or the run fails explicitly
  - `path_test19` must still not be falsely accepted
  - no new oscillation on the final curve
  - no new `reverser_mismatch`
- Cross-entrypoint regression:
  - `route` is the primary case
  - `goto` and `goto --via` only need regression coverage because they share the same terminal code path

## Assumptions and Defaults
- This handoff is for the same style of implementation agent as the previous handoff, but it is standalone and does not rely on earlier plan text.
- The next implementation phase should not broaden scope beyond the two current regressions unless a direct local code conflict makes that unavoidable.
- Priority order is fixed:
  1. remove the route-guidance stall from `test21`
  2. remove the target-ahead terminal deadlock from `test20`
  3. only then revisit further buffer-determinism tuning
