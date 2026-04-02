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

## Known Limits
- Straight-line waypoint distance only
- No route topology or signal awareness in V1
- Direction handling assumes the train is aligned for the intended move; route/junction logic belongs in later programs
