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

## Implementation Consequence
- V1 still uses `info()` because that method is confirmed and the plan requires train-derived controller scaling.
- The controller extracts mass, power, traction, and speed limits through a list of candidate field paths.
- If none are present, it falls back to named conservative defaults and prints the derived values in `inspect` so in-game testing can reveal what should be tightened later.

## Observed Mismatch To Keep In Mind
- Plan requirement: derive PID scales from train characteristics.
- Runtime uncertainty: the exact `info()` table shape is not locally documented.
- Chosen V1 approach: derive from whatever train characteristics are present, document missing fields, and keep fallbacks explicit instead of hard-coding unexplained gains.
