# Runtime Notes

## Confirmed Components
- `component.ir_remote_control` — the Radio Control Card (`thirdparty/opencomputers/RadioCtrlCardDriver`)
- `component.ir_augment_detector`
- `component.ir_augment_control`
- `component.redstone`

Note: the in-game augment configuration UI is the `AugmentFilterGUI`. Its model is a
tag/predicate filter with the fields `positiveFilter`, `negativeFilter`, `doorActuatorFilter`,
`stockDetectorMode`, `locoControlMode`, `redstoneMode`, `pushpull`, and `couplerAugmentMode`.
Tags surface through augment `getTag`/`setTag` plus the filter fields `includeTags`/`excludeTags`
(not a stock-config `tags` key). OpenComputers augments confirmed in the bundled wiki are
`ir_augment_detector` and `ir_augment_control`.

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
## Baseline

This project targets **Minecraft 1.7.10** with **Immersive Railroading 1.11.0** (GTNH port
jar `ImmersiveRailroading-1.7.10-forge-1.11.0.jar`). The GitHub `TeamOpenIndustry/ImmersiveRailroading`
changelog describes a different MC line (1.17+) and does **not** apply here; do not copy its
feature list (transfer table, TABLE part, MC 1.17+ support, `power_w`/`tractive_effort_kn` config keys).

## Confirmed Augment Notes From Local Jar

The bundled wiki text in `ImmersiveRailroading-1.7.10-forge-1.11.0.jar` documents:
- `ir_augment_detector`
- `ir_augment_control`
- event `ir_train_overhead`
- the in-game `AugmentFilterGUI` (tag/predicate filters: includeTags/excludeTags, positiveFilter/
  negativeFilter, stockDetectorMode, locoControlMode, redstoneMode, pushpull, couplerAugmentMode)

It does not document the remote-control card payload returned by `info()`; verify in-game.

## Confirmed Schedule V1 Detector Facts
- detector `CommonAPI.info()` exposes wagon-related wait metrics used by V1:
  - `cargo_percent`
  - `cargo_size`
  - `fluid_amount`
  - `fluid_max`
  - `passengers`
- detector `CommonAPI.consist()` does not expose a full wagon list
- `ir_train_overhead` currently arrives as:
  - `event_name`
  - `net_address`
  - `augment_type`
  - `stock_uuid`

Implementation consequence:
- wagon-related schedule waits must stay on `ir_augment_detector.info()`
- `station_dispatch.lua` treats `ir_train_overhead` only as transient runtime metadata and does not persist `last_stock_uuid` or `last_seen`

## Confirmed Schedule V1 Redstone Facts
- local OpenComputers redstone support confirmed:
  - `getInput`
  - `getOutput`
  - `setOutput`

Implementation consequence:
- station schedules may drive output-only redstone in V1
- redstone input remains intentionally out of scope

## Route Graph Scope

No native IR rail topology API is used in V1. The schedule graph is manual route-book data:
- `ROUTES[id].from`
- `ROUTES[id].to`
- `ROUTES[id].via`

Dispatcher cold-start guardrail picking uses only stored coordinates plus a short remote-control heading probe.

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

## Speed-Centric Runtime Signals
- Route execution now logs a planner/allocator split for longitudinal control:
  - `speed_plan_limit_mps`
  - `speed_plan_command_mps`
  - `speed_plan_target_mps`
  - `speed_plan_force_mode`
  - `terminal_speed_commit_active`
  - `d_term_active`
  - `effort_cmd`
  - `allocated_throttle`
  - `allocated_brake`
- `speed_plan_target_mps` is kept as a compatibility alias while log readers migrate; the real planner split is `speed_plan_limit_mps` plus `speed_plan_command_mps`.
- `speed_plan_force_mode` is limited to `auto`, `coast`, `full_brake`, and `hold`.
- Terminal diagnostics now also expose the stop-guidance gate directly:
  - `stop_guidance_entry_margin_m`
  - `stop_guidance_required_stop_m`
- `stop_guidance_entry_margin_m` is now its own planner threshold and is no longer implicitly identical to `required_stop_margin_m`.
- Terminal diagnostics remain otherwise unchanged in scope, so safety analysis still uses the same channels as before.

## Observed Mismatch To Keep In Mind
- Plan requirement: derive PID scales from train characteristics.
- Runtime uncertainty: the exact `info()` table shape is still not locally documented as a stable contract.
- Chosen V1 approach: prefer confirmed observed fields, document them here, and keep fallbacks explicit instead of hard-coding unexplained gains.
