# Investigation report: train stalls at terminal station

## Symptom
- Train reaches the final entry station but cannot stop cleanly.
- Log ends with:
  ```
  terminal_limit_exit route_name=1_oil_1 leg=7/7 reason=stalled_outside_v1_limit
  distance=4.18m physical_distance=2.06m longitudinal=-4.10m lateral=0.79m
  speed_toward_target=-0.00m/s axis_speed=0.00m/s stop_buffer_m=6.00m
  physical_target=(658.00,68.00,-458.00) terminal_stop_target=(658.14,67.63,-452.01)
  ```
- `longitudinal=-4.10m` means the train came to rest **4.10 m past** the terminal stop target along the route axis.
- `speed_toward_target=-0.00m/s` + `axis_speed=0.00m/s` confirms the train is fully stopped (stalled) but outside the allowed V1 stop zone, so `station_dispatch` aborts the wait cycle.

## Timeline from log (last lines)
1. Train enters terminal phase (`leg_mode=terminal`) and stop guidance activates.
2. `stop_guidance_entry=true` with `stop_guidance_entry_reason=late_buffer_capture`.
3. Controller switches to `mode=coast` / `reason=near_target_correction` and tries to creep onto the target.
4. Speed decays to ~0 m/s while the train is still `longitudinal=-4.10m` past the target.
5. `terminal_failure_pending=true`, `terminal_failure_elapsed_s=2.00`, then `terminal_limit_exit ... stalled_outside_v1_limit`.

## What changed recently
- `train_controller.lua` has non-trivial PID/stop changes in the last few commits:
  - `0b2a8e5` — PID redesign for throttle/brake value finding based on speed.
  - `a67fcee` — "Bessere Stopp-Präzision bei 'conservative'".
  - `dcbfe93` / `86bef9f` — command oscillation fixes during terminal phase.
- The current diff does **not** modify `train_controller.lua`. The working tree changes are limited to:
  - `station_dispatch.lua` (+3 lines: arrival-pulse firing inside the wait loop)
  - `station_schedule.lua` (editor-only condition/rule schema, validation, `_rule_complete` tracking)
  - `route_book_editor.lua` (new `arrived_at_station` condition, per-rule `signal`/`pulse_ticks`)
  - docs/previews
- None of these changes touch the stop controller, PID, or physics loop. They cannot change braking distance or terminal stop behavior at runtime.

## Hypothesis
**Most likely cause:** recent PID/stop-parameter changes in `train_controller.lua` (commits `0b2a8e5` and `a67fcee`) altered the terminal braking envelope for `conservative` profile. The train now undershoots braking aggressiveness in the last few meters, overshoots the terminal stop target by ~4 m, comes to a full stop outside the V1 limit, and the dispatcher treats this as a terminal failure.

**Why this is not the schedule/redstone update:**
- The stall happens *before* `schedule_wait_complete` / wait-session logic. It is purely in `run_route_leg` / terminal stop guidance.
- `station_dispatch.lua` only starts the wait loop *after* the train has arrived. The log shows the train never cleanly arrives; `terminal_limit_exit` fires during leg execution.
- Redstone outputs are irrelevant here; the only redstone line in the log is the expected `redstone_output_inactive` after the controller gives up.

## Evidence summary
| Indicator | Value | Interpretation |
|-----------|-------|----------------|
| `leg_mode` | `terminal` | Final stop leg |
| `stop_guidance_entry` | `true` (`late_buffer_capture`) | Stop guidance started, but buffer was already tight |
| `terminal_brake_snapshot` | `0.900` | Brake model is 0.9g |
| `mode` | `coast` / `near_target_correction` | Controller coasted instead of braking in the last meters |
| `longitudinal` | `-4.10m` | Overshoot past terminal stop target |
| `speed_toward_target` | `-0.00m/s` | Fully stopped |
| `terminal_failure_elapsed_s` | `2.00` | Controller held for 2 s then gave up |
| `reason` | `stalled_outside_v1_limit` | Dispatcher aborted because stop position is invalid |

## Redstone / schedule update verdict
The just-implemented redstone rule changes (`arrived_at_station`, per-rule `signal`/`pulse_ticks`, arrival-pulse firing in `station_dispatch.lua`) are **not** the cause. They affect post-arrival I/O, not the approach/terminal stop physics.

## Proposed next steps (read-only; no code change yet)
1. **Diff the PID/stop parameters** between the last known good stop commit (`a67fcee` "Bessere Stopp-Präzision bei conservative") and HEAD for `train_controller.lua`. Look for:
   - `terminal_stop_capture_distance_m`
   - `terminal_stop_guidance_distance_m`
   - `approach_stop_*` / `terminal_buffer_*` values
   - PID `kp`/`ki`/`kd` in `derive_pid` for the `conservative` profile
2. **Check `stop_buffer_m`:** log shows `stop_buffer_m=6.00m` while earlier terminal legs showed `0.00m`. A larger stop buffer without matching brake increase can push the train past the target.
3. **Review `near_target_correction` / `stop_first` logic:** line 151 shows `near_target_correction=true near_target_resolution=correct`, then immediately `terminal_failure_pending=true`. The correction window may be too narrow or the creep throttle too weak.
4. **Temporary validation:** run the same schedule with `profile=fast` (if terminal parameters were aligned per `61a179c`) to see if the issue is profile-specific.

## Risk assessment
- The issue is **deterministic** (same terminal, same overshoot, same `stalled_outside_v1_limit`).
- It is **localized** to terminal stop physics in `train_controller.lua`.
- No runtime crash or Lua error; the controller cleanly exits the leg because the stop position is invalid.
- Fix should be a parameter/PID tuning change, not a structural code change.
