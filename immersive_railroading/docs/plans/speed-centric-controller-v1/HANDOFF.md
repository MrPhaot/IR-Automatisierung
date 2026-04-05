# Speed-Centric Controller V1 Handoff

## Current Status
- Repo root: `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- Writable root: `/home/mrphaot/Dokumente/lua/minecraft`
- Inspect-only PrismLauncher paths:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`
- Production controller remains a single file:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua`
- This handoff is for a control-architecture redesign, not for route geometry, route book, or CLI changes.

## Why This Handoff Shape
- Use the same handoff style that already produced useful implementation commits:
  - fixed read order
  - explicit current verified state
  - fixed implementation priorities
  - explicit do-not list
  - validation commands and acceptance criteria
- This pattern is verified via Git history:
  - `61a179c feat: align fast profile terminal parameters with conservative for stability; add travel_speed_scale`
  - `b3589a4 fix: add terminal_progress_floor_throttle logic to run_route_leg for buffer approach stall prevention`
- Practical conclusion:
  - keep this handoff execution-oriented and decision-complete
  - do not make the next agent rediscover the current state

## Verified Baseline In This Session
- Static syntax check is green:
  - `luac -p immersive_railroading/programs/train_controller.lua`
- Current preview/test state is not green:
  - `lua immersive_railroading/tests/previews/controller_preview.lua`
    - fails at `controller_preview.lua:650`
    - message: `fast stop capture should stay blocked until the entry speed drops below its release limit`
  - `lua immersive_railroading/tests/previews/test_outside_capture_window.lua`
    - fails because current result is `true buffer_window 2.0`
    - test still expects `outside_capture_window`
- Current real-log evidence:
  - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test31.log`
    - `profile=conservative`
    - `stop_guidance_entry reason=late_buffer_capture`
    - final outcome: `arrived_at_target`
  - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test32.log`
    - `profile=fast`
    - `stop_guidance_entry reason=buffer_window`
    - later `buffer_settle_forward`
    - later repeated `final_brake_hold`
    - final outcome: `terminal_limit_exit reason=stalled_outside_v1_limit`

## Current Code Facts That Matter
- Profile knobs are still strongly throttle-centric:
  - `programs/train_controller.lua:93`
- Stop-guidance entry is speed-envelope based already:
  - `programs/train_controller.lua:747`
- Travel speed scaling already exists for pass-through legs:
  - `programs/train_controller.lua:2948`
- The normal drive path is still dominated by throttle caps, floors, and branch-specific overrides:
  - `programs/train_controller.lua:3541`
- Brake output is still derived from overspeed heuristics instead of one shared signed control effort:
  - `programs/train_controller.lua:1224`
- `control_loop(...)` still exists, but production route execution goes through:
  - `execute_route_plan(...) -> run_route_leg(...)`
- The currently failing previews are stale because they still encode the old `fast` capture/endgame assumptions.

## Root Diagnosis
- The current controller mixes three responsibilities that should be separate:
  - speed planning
  - safety/state gating
  - actuator allocation
- The present architecture computes a `target_speed_mps`, but then overrides it with:
  - `throttle_limit`
  - profile-specific throttle scales
  - minimum-throttle floors
  - forced brake branches
  - terminal buffer and settle-specific actuator clamps
- That makes the PID non-authoritative.
- The redesign goal is therefore:
  - planner/state machine set speed limits and maneuver intent
  - one longitudinal controller computes signed effort from speed error
  - one allocator maps that effort to throttle/brake
  - throttle limits stop being behavior-tuning knobs

## Required Implementation Direction
- Keep route geometry, stop-buffer geometry, stop-guidance capture, and failure logging semantics.
- Redesign only the longitudinal control path.
- The implementation should be done in this order:

### 1. Introduce three internal helpers
- Add a speed-plan helper.
- Add a signed effort controller.
- Add an actuator allocator.

Recommended helper shape:

```lua
local function make_speed_plan(v_target_mps, desired_reverser, reason, force_mode)
  return {
    v_target_mps = math.max(v_target_mps or 0, 0),
    desired_reverser = desired_reverser or 1,
    reason = reason or "speed_tracking",
    force_mode = force_mode or "auto", -- auto | coast | hold | full_brake
  }
end
```

```lua
local function compute_longitudinal_effort(pid, integral, previous_error, speed_error, dt_s, integral_limit)
  local next_integral = clamp(integral + speed_error * dt_s, -integral_limit, integral_limit)
  local derivative = (speed_error - previous_error) / math.max(dt_s, 0.001)
  local raw_effort = pid.kp * speed_error + pid.ki * next_integral + pid.kd * derivative
  local effort = clamp(raw_effort, -1, 1)

  -- Anti-windup: do not keep integrating further into saturation.
  if raw_effort ~= effort then
    if (raw_effort > 1 and speed_error > 0) or (raw_effort < -1 and speed_error < 0) then
      next_integral = integral
    end
  end

  return effort, next_integral, speed_error
end
```

```lua
local function allocate_effort_to_controls(effort_cmd, reverser)
  local throttle = 0
  local brake = 0

  if effort_cmd >= DEFAULTS.throttle_deadband then
    throttle = clamp(effort_cmd, 0, 1)
  elseif effort_cmd <= -DEFAULTS.brake_deadband then
    brake = clamp(-effort_cmd, 0, 1)
    if brake > 0 and brake < DEFAULTS.min_brake_command then
      brake = DEFAULTS.min_brake_command
    end
  end

  return {
    throttle = throttle,
    reverser = reverser,
    brake = brake,
    independent_brake = 0,
  }
end
```

### 2. Move all normal driving to speed-plan -> effort -> allocator
- In `run_route_leg(...)`, the normal `state.mode == "drive"` path must stop building behavior around `throttle_limit`.
- Keep these values as planner inputs only:
  - `target_speed_mps`
  - approach/terminal speed caps
  - stop-guidance capture speed caps
  - buffer settle speeds
  - near-target correction speeds
- Do not use these anymore as direct actuator caps:
  - `DEFAULTS.approach_throttle_limit`
  - `DEFAULTS.cruise_throttle_limit`
  - `DEFAULTS.approach_stop_throttle_limit`
  - `DEFAULTS.near_target_correction_throttle_limit`
  - `DEFAULTS.launch_throttle_limit`
  - `profile.forward_crawl_throttle_limit`
  - `profile.terminal_recovery_throttle_limit`
  - `profile.terminal_recovery_min_throttle`
  - `profile.approach_stop_throttle_scale`
  - `profile.terminal_buffer_throttle_limit`
  - `profile.buffer_settle_forward_throttle_limit`
  - `profile.buffer_settle_forward_deadlock_throttle_limit`
  - `profile.buffer_settle_reverse_throttle_limit`
  - `profile.launch_throttle_scale`
  - `terminal_buffer_progress_floor(...)`
- For the first pass, it is acceptable to leave these fields defined but unused.
- The goal is to remove them from the control path, not necessarily delete all table entries in the same patch.

### 3. Replace drive/brake branch heuristics with force modes
- Keep hard safety overrides only.
- Allowed force modes:
  - `hold`
  - `full_brake`
  - `coast`
  - `auto`
- Mapping rules:
  - `hold`
    - arrival hold
    - abort
    - terminal-safe stop after declared failure
  - `full_brake`
    - reverser mismatch above switch speed
    - explicit abort
    - hard terminal buffer emergency brake if still needed
  - `coast`
    - optional for tiny residual errors where neither drive nor brake is useful
  - `auto`
    - all normal longitudinal behavior
- In `auto`, use only:
  - `speed_error = v_target_mps - speed_toward_target_mps`
  - `compute_longitudinal_effort(...)`
  - `allocate_effort_to_controls(...)`

### 4. Keep the planner conservative in terminal phases
- Do not redesign:
  - `stop_speed_cap(...)`
  - `required_stop_distance_m(...)`
  - `can_enter_stop_guidance(...)`
  - stop-progress channel
  - `terminal_failure_arming_allowed(...)`
- The redesign is not "remove speed envelopes".
- It is "remove actuator tuning through throttle caps".
- Terminal behavior should remain speed-envelope-driven.

### 5. Refactor profile semantics toward speed limits
- Keep `travel_speed_scale`.
- Keep terminal speed parameters such as:
  - `approach_stop_target_speed_scale`
  - `terminal_buffer_entry_speed_cap_mps`
  - `terminal_buffer_final_speed_cap_mps`
  - `buffer_settle_forward_speed_mps`
  - `buffer_settle_reverse_speed_mps`
  - `terminal_recovery_speed_mps`
- Treat these as planner parameters only.
- `fast` should differ from `conservative` primarily by higher pass-through speed in this redesign branch.
- Do not reintroduce an aggressive `fast` terminal actuator strategy.

### 6. Update docs together with code
- Update:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/control-model.md`
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/runtime.md`
- Required doc changes:
  - the controller is now speed-centric
  - PID output is signed effort, not "throttle only unless branch says brake"
  - planner vs actuator allocator are separate
  - runtime logs now expose planner and effort values

## New Logging Requirements
- Add these periodic log fields:
  - `speed_plan_target_mps`
  - `speed_plan_force_mode`
  - `effort_cmd`
  - `allocated_throttle`
  - `allocated_brake`
- Keep all current terminal diagnostics:
  - `stop_guidance_entry_reason`
  - `buffer_settle_mode`
  - `terminal_failure_pending`
  - `terminal_deadlock_candidate_elapsed_s`

## Required Preview/Test Rewrite
- The current preview baseline is stale and must be updated as part of the redesign.
- Replace outdated `fast` capture assumptions in:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/previews/controller_preview.lua`
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/previews/test_outside_capture_window.lua`

Add these new preview cases:

### A. Signed effort basics
- Below target speed -> positive effort.
- Above target speed -> negative effort.
- Near zero error -> effort near zero.
- Anti-windup should prevent runaway integral growth at saturation.

### B. Allocator semantics
- Positive effort yields throttle only.
- Negative effort yields brake only.
- No normal path should emit both throttle and brake together.
- Force-mode `hold` and `full_brake` bypass allocator output cleanly.

### C. Speed-plan semantics
- Pass-through legs:
  - `fast` gets higher `v_target_mps` through `travel_speed_scale`.
- Terminal legs:
  - `fast` and `conservative` use the same endgame speed plan unless explicitly changed in planner parameters.
- Stop-guidance and buffer-settle modes continue to constrain speed, not throttle.

### D. Regression coverage
- `can_enter_stop_guidance(...)` still behaves according to the current speed-envelope semantics.
- Terminal success still requires both:
  - stop-target success
  - physical-buffer success

## Validation Commands
- `luac -p immersive_railroading/programs/train_controller.lua`
- `lua immersive_railroading/tests/previews/controller_preview.lua`
- `lua immersive_railroading/tests/previews/test_outside_capture_window.lua`
- `rg -n "throttle_limit =|terminal_buffer_progress_floor\\(|approach_stop_throttle_scale|terminal_recovery_throttle_limit|buffer_settle_forward_throttle_limit" immersive_railroading/programs/train_controller.lua`
- `rg -n "speed_plan_target_mps|effort_cmd|allocated_throttle|allocated_brake|speed_plan_force_mode" immersive_railroading/programs/train_controller.lua`

## Acceptance Criteria
- Normal longitudinal control in `run_route_leg(...)` no longer depends on throttle-limit shaping.
- Planner/state machine set only speed targets and force modes.
- One shared signed controller determines the normal drive/brake command.
- One allocator maps signed effort into throttle/brake.
- Existing terminal safety and stop-guidance logic remains intact.
- `controller_preview.lua` and `test_outside_capture_window.lua` are green again with updated expectations.
- Real logs still show:
  - `conservative` terminal success
  - `fast` faster travel behavior
  - no regression into the old `fast` terminal deadlock pattern

## Assumptions
- Keep `programs/train_controller.lua` as the single production controller file for this redesign pass.
- It is acceptable to leave legacy throttle-tuning fields in `DEFAULTS` and `PROFILES` temporarily, as long as they are no longer behavior-defining.
- `control_loop(...)` is legacy and secondary; correctness priority is `run_route_leg(...)`, but shared helpers should be reusable in both paths if touched.
