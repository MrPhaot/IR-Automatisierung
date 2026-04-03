# Runtime Notes

## Confirmed Components
- `component.ir_remote_control`
- `component.ir_augment_detector`
- `component.ir_augment_control`

## Confirmed Remote-Control Methods
- `info()`
- `consist()`
- `getPos()`
- `setThrottle(number)`
- `setReverser(number)`
- `setBrake(number)`
- `setIndependentBrake(number)`
- `getIgnition()`
- `setIgnition(boolean)`
- tag, horn, bell helpers

## Confirmed Augment Notes From Local Jar
The bundled wiki text in `ImmersiveRailroading-1.7.10-forge-1.10.0.jar` documents:
- `ir_augment_detector`
- `ir_augment_control`
- event `ir_train_overhead`

It does not document the remote-control card payload returned by `info()`.

## Confirmed Runtime Fields From Real `inspect`
Observed on the OpenComputers test machine:

- `info()` exposes at least:
  - `direction = EAST`
  - `max_speed = 76.465505226481`
  - `horsepower = 2549`
  - `traction = 194161`
  - `weight = 80930.0`
  - `reverser = -1.0`
  - `speed = -0.0`
- `consist()` exposes at least:
  - `weight_kg = 100493.0`
  - `total_traction_N = 194161`

Those fields are now preferred over older conservative fallbacks when deriving controller characteristics.

## Implementation Consequence
- V1 still uses `info()` because that method is confirmed and the plan requires train-derived controller scaling.
- The controller now derives:
  - mass from consist-level totals such as `weight_kg` before single-locomotive weight fields
  - traction from `total_traction_N` / `traction`
  - power from watt or kilowatt fields first, then `horsepower` converted to watts
  - speed limits from `max_speed`
- If those fields are missing, it still falls back to named conservative defaults and prints the derived values in `inspect` so in-game testing can reveal what should be tightened later.

## Observed Mismatch To Keep In Mind
- Plan requirement: derive PID scales from train characteristics.
- Runtime uncertainty: the exact `info()` table shape is still not locally documented as a stable contract.
- Chosen V1 approach: prefer confirmed observed fields, document them here, and keep fallbacks explicit instead of hard-coding unexplained gains.
