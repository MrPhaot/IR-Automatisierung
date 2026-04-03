# Control Model

## V1 Shape
- Position source: `ir_remote_control.getPos()`
- Train characteristic source: `ir_remote_control.info()` with `consist()` as a secondary fallback
- Command surface: throttle, reverser, brake, independent brake, ignition

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
- The `goto` command only knows a point target in V1.
- A remaining-distance speed cap based on `sqrt(2ad)` gives the controller a simple braking boundary that adapts as the learned brake model improves.
- This is safer than trying to brake only when already near the target.
- The last meters now add a conservative `approach_stop` phase before the final arrival window so the train is pushed into braking early enough on straight runs instead of relying on one late overspeed trigger.
- Near-target overshoots now follow a `stop_first` rule: brake to a real halt first, then either accept a small residual miss as `near_target_arrival` or allow only a very small correction move.

## Why Distance And Motion Axis Are Now Separate
- The real target is still a point in world space, so braking and arrival decisions use full point distance instead of only a projection onto the current motion frame.
- The motion axis is kept only as a local track-direction hint for interpreting whether the train is moving toward or away from the target.
- Once the train produces a reliable velocity vector, that axis is frozen for the rest of the maneuver.
- This avoids the failure seen in `reverse_test1.log`, where a near-stop axis rotation turned almost the entire target error into lateral drift and made the controller think it had already arrived.

## Known Limits
- Straight-line waypoint distance only
- No route topology or signal awareness in V1
- Direction handling still assumes the train is roughly aligned for the intended move; route/junction logic belongs in later programs
- The frozen axis is a robustness fix, not a substitute for real track topology on curves, junctions, or station approaches
- V1 is currently intended for point targets that lie on an approximately straight approach from the current train position
- Targets that sit on curves without explicit intermediate waypoints remain outside the stable V1 envelope, as seen in `reverse_test4.log`
- `reverse_test7.log` and `reverse_test8.log` refined the straight-line endgame: immediate reverse recovery near the target is intentionally blocked until the train has actually stopped
