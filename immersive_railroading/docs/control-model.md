# Control Model

## V1 Shape
- Position source: `ir_remote_control.getPos()`
- Train characteristic sources: `ir_remote_control.info()` and `consist()`
- Mass, traction, and power prefer consist-level totals when they are present, so the controller scales to the whole train instead of only the linked locomotive
- Power prefers watt or kilowatt fields first, then falls back to `horsepower` converted to watts
- Command surface: throttle, reverser, brake, independent brake, ignition

## Speed-Centric Longitudinal Split
- The controller now separates planning/state from actuator output:
  - planner/state machine decides the current `speed_limit_mps`, desired reverser, and hard force mode (`auto`, `coast`, `full_brake`, `hold`)
  - terminal commit logic derives a trackable `speed_command_mps` from that limit
  - one signed longitudinal controller computes effort from speed error in `auto`
  - one allocator maps signed effort to throttle-only or brake-only output
- `speed_plan_target_mps` still appears in logs as a compatibility alias, but it is no longer the only meaningful speed-plan field.
- In the production route path `execute_route_plan(...) -> run_route_leg(...)`, normal driving no longer shapes behavior with throttle caps, throttle floors, or profile-specific throttle clamps.
- `control_loop(...)` still exists as a legacy path and still contains older throttle-limit logic, so documentation should not describe the whole file as uniformly migrated.
- Terminal safety still comes from the speed envelope, stop-guidance state, and failure serialization logic.

## Current Terminal Control Path
- The production terminal path filters measured progress speed into `controller_speed_mps` before it enters the longitudinal controller.
- Once the run enters a committed stop, `terminal_speed_command_mps` becomes monotone non-increasing so the planner cannot raise the commanded stop speed again mid-stop.
- The terminal controller freezes a dedicated PID basis from `terminal_brake_snapshot_mps2` instead of letting late brake-learning drift reshape the stop response.
- The derivative term is disabled for terminal legs.
- Terminal effort is further cleaned up before actuation:
  - effort is phase-limited for route terminal, committed stop, and final low-speed stop
  - effort slew is rate-limited before `allocate_effort_to_controls(...)`

## Why The PID Baseline Is Physics-Derived
- A fixed gain set would only match one train.
- V1 instead scales gains from a reference cruise speed, a traction-limited drive horizon, and a brake-limited stop horizon.
- That keeps the controller behavior in the same rough family when mass, power, or brake authority change.

Baseline preview formula reproduced in code:

```lua
local a_drive = math.min(traction_n / mass_kg, power_w / math.max(v_ref_mps, 1) / mass_kg)
local t_drive = v_ref_mps / a_drive
local t_brake = v_ref_mps / brake_model.full_service_mps2

local kp = 1 / v_ref_mps
local ki = kp / t_brake
local kd = kp * math.min(t_drive, t_brake)
```

## Why Brake Learning Exists
- Exact brake force is the least reliable input in the locally documented API surface.
- V1 therefore learns effective full-service deceleration from observed slowdowns while a brake command is applied.
- An exponential moving average is used so one noisy sample does not permanently distort the stopping model.

## Why Stop Control Uses A Speed Envelope
- The terminal leg of `goto` or `route` still resolves to one point target in V1.
- A remaining-distance speed cap based on `sqrt(2ad)` gives the controller a simple braking boundary that adapts as the learned brake model improves.
- This is safer than trying to brake only when already near the target.
- `stop_buffer_m` is now handled in two stages: during the normal terminal approach it acts as remaining distance to the physical target, and only late in the end approach does the controller freeze a final stop axis and convert that buffer into an explicit halting point.
- Why: this keeps the older curve-following behavior alive on known-good end curves instead of letting an early fixed stop axis drag the train into oscillation before the real final entry is complete.
- Stop-guidance entry now uses its own margin `stop_guidance_entry_margin_m`, which is separate from the broader `required_stop_margin_m` used by no-reverse and stop-now safety envelopes.
- The default `conservative` profile intentionally keeps a tighter stop-guidance entry margin and a more cautious end-phase envelope so the train is more likely to stop without any reverse recovery on straight target runs.
- The last meters now add a conservative `approach_stop` phase before the final arrival window so the train is pushed into braking early enough on straight runs instead of relying on one late overspeed trigger.
- Near-target overshoots now follow a `stop_first` rule: brake to a real halt first, then either accept a small residual miss as `near_target_arrival` or allow only a very small correction move.
- That near-target resolution is intentionally split into phases: `stop_first` handles the stop itself, then a second decision chooses `near_target_arrival`, a limited `near_target_correction`, or a logged V1 limit if the residual miss is already too large for a tiny correction.
- The complementary failure mode is stopping short inside the terminal no-reverse window. V1.1 therefore reuses `final_forward_crawl` as a guarded forward recovery mode: if the target is still ahead, alignment remains sane, and the residual miss stays inside a small terminal corridor, the planner lowers the speed target and the shared signed effort path handles actuator output.

## Profile Modes

- `conservative` is the default profile when no explicit flag is passed to `trainctl goto`.
- `conservative` prioritizes minimal or zero overshoot by braking earlier, entering stop guidance under a stricter margin, clamping target speed harder in the final approach, and preferring a very slow forward recovery over any reverse recovery when the train ends up stopping short.
- `fast` differs primarily by a higher pass-through travel speed scale and a looser stop-guidance entry margin; the terminal controller architecture itself remains shared.

## Why Distance And Motion Axis Are Now Separate

- The real target is still a point in world space, so braking and arrival decisions use full point distance instead of only a projection onto the current motion frame.
- The motion axis is kept only as a local track-direction hint for interpreting whether the train is moving toward or away from the target.
- Once the train produces a reliable velocity vector, the retained `target_line_axis` keeps the route frame stable while `motion_axis` is refreshed from filtered velocity only when alignment stays good.
- This avoids the failure seen in `reverse_test1.log`, where a near-stop axis rotation turned almost the entire target error into lateral drift and made the controller think it had already arrived, without pretending the live motion hint itself is permanently frozen.

## Why Curve Handling Uses Explicit Geometry

- The controller still does not know the rail graph, junction state, or future curve tangent from the API alone.
- V1 therefore handles curves by splitting a run into explicit legs from `--via` or route-book `via`.
- Route-book routes are directed `from -> to` station edges. `via` points are guardrails only.
- Intermediate legs stay in pass-through tracking so the train keeps a route-aligned frame without trying to stop or wait at each waypoint.
- Only the final leg re-enters the full terminal arrival logic.
- Pass-through auto mode suppresses service brake when the train is clearly below target speed; force modes such as moving-away and reverser mismatch can still brake.

## Known Limits

- No automatic route topology or signal awareness in V1
- Direction handling still assumes the train is roughly aligned for the intended move; route/junction logic belongs in later programs
- The retained target-line axis is a robustness fix, not a substitute for real track topology on curves, junctions, or station approaches
- Curve runs still require explicit intermediate waypoints or named routes; the controller does not discover them on its own
- `route_book.lua` ships as a schema-only file because station coordinates are save-specific
- `reverse_test7.log` and `reverse_test8.log` refined the straight-line endgame: immediate reverse recovery near the target is intentionally blocked until the train has actually stopped
- `reverse_test10.log` and `reverse_test11.log` further show that micro-correction is only meant for small to moderate residual misses; larger misses after the stop are treated as a documented V1 limit instead of pretending a tiny correction can recover them
- `reverse_test14.log` showed the complementary conservative failure mode: stopping short and deadlocking in final brake hold is also undesirable, so the terminal leg now keeps a guarded forward recovery window before it escalates to `stalled_outside_v1_limit`
