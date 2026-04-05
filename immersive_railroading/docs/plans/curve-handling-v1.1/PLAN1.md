# Curve Handling V1.4 Follow-Handoff: Terminal Deadlock + Route-Stall Fix

## Summary
- This follow-up handoff replaces the previous “deadlock only” framing with the **two actual regressions** visible in the current code and logs.
- `path_test20.log` shows the original terminal deadlock:
  - `guidance_mode=stop`
  - target still ahead
  - `buffer_settle_mode=none`
  - `buffer_settle_block_reason=target_ahead`
  - repeated `final_brake_hold`
  - no `terminal_limit_exit`
- `path_test21.log` shows a second regression:
  - the train never reaches `stop_guidance`
  - it stalls in `guidance_mode=route`
  - repeated `reason=overspeed`
  - `throttle=0.00`, `brake=0.00`
  - `stop_guidance_entry=false`
  - fixed at `physical_distance=8.57m`
- The next implementation must fix **both**:
  1. no terminal deadlock after `stop_guidance`
  2. no route-guidance stall caused by brake-release hold

## Current Verified Diagnosis
- Workspace and save controller are currently identical.
- Current deadlock fix is only partial:
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L1002) now allows failure for inconsistent terminal stops
  - but [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L899) still blocks forward settle outside the narrow fine-trim window
  - and [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L2967) has no separate target-ahead deadlock-forward-recovery path
- `test21` is a different failure class:
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L1071) applies `must_hold_brake` before normal mode selection
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L3456) re-arms `brake_release_until` even when computed brake falls to zero in normal route guidance
  - this creates a self-sustaining “brake mode with zero brake” stall

## Exact Implementation Changes
- **Do not change**
  - route geometry
  - waypoint semantics
  - CLI
  - route book
  - stop-axis model
  - logger structure beyond a few minimal fields if needed
- **Add one new terminal recovery concept**
  - keep `forward settle` as the fine-trim corridor
  - add a second corridor for `target ahead but stalled in stop guidance`
  - this corridor must reuse forward motion, but it must **not** be blocked by `buffer_settle_forward_max_longitudinal_m`
- **Restrict brake-release hold to true stop/approach braking**
  - `brake_release_until` must not keep a route-guidance overspeed branch frozen at zero throttle and zero brake
  - brake-release hold is only valid in:
    - `guidance_mode=stop`
    - `stop_context.must_stop_now`
    - `stop_context.in_approach_stop`
    - `stop_context.in_no_reverse_approach`
  - it is not valid for normal route-guidance overspeed regulation
- **Keep reverse settle narrow**
  - do not weaken `target_ahead`
  - reverse remains only for real small overshoot
- **Failure order**
  - after `stop_guidance`, a stalled run must end in exactly one of:
    - success
    - forward settle
    - reverse settle
    - terminal failure
  - never endless `final_brake_hold`

## Ready-to-Apply Code Shape
- **1. Add explicit deadlock-forward parameters to `DEFAULTS` and both profiles**
  - Put them next to the existing `buffer_settle_forward_*` values.
```lua
-- DEFAULTS
terminal_deadlock_forward_max_longitudinal_m = 12.0,
terminal_deadlock_forward_speed_mps = 0.15,
```

```lua
-- conservative
buffer_settle_forward_deadlock_max_longitudinal_m = 12.0,
buffer_settle_forward_deadlock_speed_mps = 0.15,
```

```lua
-- fast
buffer_settle_forward_deadlock_max_longitudinal_m = 12.0,
buffer_settle_forward_deadlock_speed_mps = 0.15,
```
- Decision:
  - use the same deadlock window for both profiles
  - keep normal fine-trim windows unchanged
  - deadlock recovery is not a new “fast feature”; it is a safety escape hatch

- **2. Add a dedicated helper after `forward_buffer_settle_block_reason(...)`**
  - New helper name:
    - `forward_deadlock_recovery_block_reason(...)`
  - Purpose:
    - allow forward recovery when the target is still ahead, the train is already nearly stopped, and normal forward settle was blocked only because the miss is too large for fine trim
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

- **3. Change settle selection in the stop-guidance block**
  - Keep existing order:
    1. normal forward settle
    2. reverse settle
  - Add:
    3. deadlock-forward recovery if reverse says `target_ahead`
  - Patch the branch in the block around [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L2967) like this:
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
- Decision:
  - do not delete the existing forward or reverse helpers
  - add the deadlock-forward helper as a third branch only for the `target_ahead` stop-stall case

- **4. Restrict brake-release hold in `select_motion_mode(...)`**
  - Replace the current unconditional `must_hold_brake` with context-aware hold:
```lua
  local brake_hold_allowed = state.guidance_mode == "stop"
    or must_stop_now
    or (stop_context and (stop_context.in_approach_stop or stop_context.in_no_reverse_approach))
  local must_hold_brake = brake_hold_allowed
    and state.brake_release_until
    and uptime() < state.brake_release_until
```
- This change goes in [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L1071).
- Decision:
  - route-guidance overspeed regulation must be able to leave brake mode once overspeed disappears
  - stop-phase hold behavior remains unchanged

- **5. Restrict where `brake_release_until` is armed**
  - In the brake branch near [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua#L3456), replace the current deadband tail with:
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
- Decision:
  - generic route overspeed can coast/drive again
  - only actual stop/approach braking may keep the brake-hold timer

- **6. Add minimal state/logging only if needed**
  - Optional but recommended:
    - `terminal_deadlock_recovery_active`
    - set true only when `buffer_settle_block_reason == "deadlock_forward_recovery"`
  - If added, log it in the big status line, but do not redesign logging
  - If not added, the existing `buffer_settle_mode=forward` + `buffer_settle_block_reason=deadlock_forward_recovery` is enough

## Preview / Sandbox Test Changes
- Keep the existing preview structure in [controller_preview.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/previews/controller_preview.lua).
- **Add a new deadlock helper preview**
  - extend `preview_buffer_settle_mode(...)` with a deadlock-forward branch only after the normal forward branch and before reverse:
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
- **Add exact new assertions**
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

## Acceptance Criteria
- `path_test20`-style runs:
  - no endless `final_brake_hold`
  - acceptable outcome:
    - `buffer_settle_mode=forward` with deadlock-forward recovery
    - or `terminal_limit_exit`
- `path_test21`-style runs:
  - no stationary `guidance_mode=route` stall at zero throttle/zero brake
  - the train must either:
    - resume route guidance toward capture
    - enter `stop_guidance`
    - or fail explicitly
- Existing good behavior must remain:
  - no new curve oscillation
  - no new `reverser_mismatch`
  - no false success for `path_test19`-style bad physical-buffer halts
- Required local verification:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`

## Assumptions and Defaults
- This handoff is for the same agent as the prior V1.3 work; repo rules and environment rules are already known.
- The priority order is fixed:
  1. remove the route-guidance brake-hold stall from `test21`
  2. remove the terminal target-ahead deadlock from `test20`
  3. only then return to further buffer-determinism tuning
- The code snippets above are designed to fit the current file structure and symbol names directly, but they are still a handoff spec, not an already-applied patch.
