# PLAN24: Terminal Late-Capture mit Stop-First und Buffer-Korrektur

## Summary
Fix bleibt lokal in `programs/train_controller.lua`.

Korrektur zum vorherigen Plan: keine normale “Terminal-Failure” als gewünschter Ausgang. Nach Late-Capture gilt:
- erst sicher stoppen, ohne Throttle
- wenn Stop-Ziel vor Zug liegt: rückwärts zum Buffer korrigieren
- wenn Stop-Ziel vor Zug und Zug zu kurz steht: vorwärts korrigieren
- erst danach Arrival und Schedule-Wait

IR-Jar geprüft: OpenComputers Control API erlaubt nur `setThrottle(number)` und `setBrake(number)`; Reverser kommt über Remote-Control-Card-API im Projekt bereits bestätigt. Emulator-Baseline läuft.

## Key Changes
- Conservative-Profil bekommt kleine Reverse-Buffer-Korrektur:
```lua
buffer_settle_reverse_speed_mps = 0.35,
buffer_settle_reverse_throttle_limit = 0.04,
buffer_settle_reverse_max_overshoot_m = 10.0,
```

- `reverse_buffer_settle_block_reason(...)` nicht mehr auf `profile.name == "fast"` begrenzen:
```lua
if (profile.buffer_settle_reverse_speed_mps or 0) <= 0 then
  return "profile_disabled"
end
```

- Neuer Helper erzwingt Stop-First ohne PID-Throttle:
```lua
local function terminal_stop_first_force_mode(state, speed_toward_target_mps, axis_speed_mps)
  if not (state and state.stop_first_active and not state.stopped_after_overshoot) then
    return nil, nil
  end
  if math.abs(speed_toward_target_mps) > DEFAULTS.arrival_speed_mps
    or math.abs(axis_speed_mps) > DEFAULTS.arrival_speed_mps then
    return "full_brake", "stop_first_brake"
  end
  return "hold", "stop_first_settle"
end
```

- In `run_route_leg(...)`, nach `terminal_buffer_brake_active` und vor Low-Speed-`coast`:
```lua
local stop_first_force_mode, stop_first_reason = terminal_stop_first_force_mode(
  state,
  speed_toward_target_mps,
  axis_speed_mps
)
if stop_first_force_mode then
  speed_plan_force_mode = stop_first_force_mode
  speed_plan_desired_reverser = state.active_reverser
  planner_reason = stop_first_reason
  state.phase = "tracking"
end
```

- Generic `hold`-Branch ergänzen:
```lua
elseif speed_plan.force_mode == "hold" then
  runtime_context.integral = 0
  state.previous_effort_cmd = 0
  control = {
    throttle = 0,
    reverser = 0,
    brake = DEFAULTS.hold_brake,
    independent_brake = DEFAULTS.hold_independent_brake,
  }
  state.mode = "hold"
```

- Nach Stop-First-Settle bei Late-Capture nicht in `near_target_limit` fallen, sondern Buffer-Settle erlauben:
```lua
if state.stop_first_active and state.stopped_after_overshoot and not near_target_hold then
  local allow_buffer_settle = state.late_stop_capture == true
  local can_correct = (not allow_buffer_settle) and is_near_target_correction_candidate(
    distance_to_stop_target_m,
    stop_longitudinal_distance_m,
    stop_lateral_error_m
  )
  state.stop_first_active = false
  state.stopped_after_overshoot = false
  state.halted_near_target_since = nil
  state.near_target_correction_active = can_correct
  state.near_target_resolution = allow_buffer_settle and "buffer_settle_pending"
    or (can_correct and "correct" or "limit")
  state.brake_release_until = nil
end
```

- Buffer-settle throttle hard begrenzen, weil speed-centric allocator sonst bis Phase-Cap treiben kann:
```lua
local function terminal_buffer_settle_drive_limit(profile, buffer_settle_mode, buffer_settle_block_reason)
  if buffer_settle_mode == "forward" then
    if buffer_settle_block_reason == "deadlock_forward_recovery" then
      return profile.buffer_settle_forward_deadlock_throttle_limit
        or DEFAULTS.near_target_correction_throttle_limit
    end
    return profile.buffer_settle_forward_throttle_limit
  elseif buffer_settle_mode == "reverse" then
    return profile.buffer_settle_reverse_throttle_limit
  end
  return nil
end
```

Nach `slew_limit_effort(...)`, vor `allocate_effort_to_controls(...)`:
```lua
local settle_drive_limit = terminal_buffer_settle_drive_limit(
  profile,
  buffer_settle_mode,
  buffer_settle_block_reason
)
if settle_drive_limit and effort_cmd > settle_drive_limit then
  effort_cmd = settle_drive_limit
end
```

- Late-buffer Arrival nur nach echter Korrektur/physischer Konsistenz:
```lua
local function is_late_buffer_station_arrival(
  profile,
  state,
  stop_context,
  distance_to_stop_target_m,
  stop_longitudinal_distance_m,
  stop_lateral_error_m,
  distance_to_physical_target_m,
  physical_lateral_error_m,
  stop_buffer_m,
  speed_toward_target_mps,
  axis_speed_mps
)
  if not (state and state.late_stop_capture and state.stopped_after_overshoot) then
    return false
  end
  if state.stop_first_active or state.near_target_correction_active then
    return false
  end
  if state.buffer_settle_mode ~= "none" then
    return false
  end
  if not (stop_context and stop_context.in_no_reverse_approach) then
    return false
  end
  if math.abs(speed_toward_target_mps) > DEFAULTS.arrival_speed_mps
    or math.abs(axis_speed_mps) > DEFAULTS.arrival_speed_mps then
    return false
  end
  local stop_ok = is_strict_arrival(
    distance_to_stop_target_m,
    stop_longitudinal_distance_m,
    stop_lateral_error_m,
    speed_toward_target_mps
  )
  local physical_ok = is_terminal_success_physical_ok(
    profile,
    distance_to_physical_target_m,
    stop_buffer_m
  ) and physical_lateral_error_m <= (
    profile.buffer_settle_max_lateral_m or DEFAULTS.near_target_correction_lateral_m
  )
  return stop_ok and physical_ok
end
```

Use:
```lua
local late_buffer_arrival = is_late_buffer_station_arrival(...)
terminal_success_stop_ok = terminal_success_stop_ok or late_buffer_arrival
terminal_success_physical_ok = terminal_success_physical_ok or late_buffer_arrival
```

## Tests
Add `tests/previews/test_late_buffer_terminal_stop.lua` with module-level helper tests.

Required assertions:
- observed log state `stop_first=true`, speed `-5.26`, axis `-5.26` => `full_brake`, no `auto`
- stopped stop-first state => `hold`
- conservative reverse buffer settle with `raw_desired_reverser=-1`, longitudinal `-8.70`, lateral `0.5`, speed `0.05` => eligible
- same with overshoot `12.0` => blocked
- late-buffer raw overshoot at physical `2.85`, buffer `6`, stop target `8.70m` away => no Arrival yet
- after reverse correction near stop target + physical buffer error <= `1.0` => Arrival true
- undershoot `stop_longitudinal_error_m=4.0` => forward settle eligible

Run:
```sh
cd immersive_railroading
lua tests/previews/test_outside_capture_window.lua
lua tests/previews/train_controller_emulator.lua
lua tests/previews/test_late_buffer_terminal_stop.lua
luac -p programs/train_controller.lua
```

Static snippets already checked in sandbox:
- `terminal_stop_first_force_mode` returns `full_brake` for logged moving-away state.
- late-arrival predicate rejects speed/lateral/buffer-invalid states.
- existing previews + `luac -p` pass before planned edits.

## Acceptance Criteria
- Logged failure shape cannot produce `mode=drive throttle=0.10` while `stop_first=true`, `late_stop_capture=true`, and train moves away from stop target.
- Late overshoot stops, then reverses at small throttle until configured `stop_buffer_m` is reached.
- Late undershoot stops, then creeps forward until buffer is reached.
- Schedule only receives arrival after terminal stop and physical buffer agree.
- No route loop-away after late terminal capture.
- Pass-through legs unchanged.
