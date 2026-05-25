# Station Schedules

## Frozen V1 Route Book Shape

`programs/route_book.lua` returns:
- `AUGMENTS`
- `STATIONS`
- `ROUTES`
- `SCHEDULES`

Detector address rule:
- the raw OC address is stored exactly once in `AUGMENTS.DETECTORS[detector_id].address`
- all other references use `detector_id`

Station binding rule:
- `STATIONS[id].detector_ids` is the only station relation
- detectors do not carry a reverse station pointer

## Wait Semantics

Schedule entries are station stops. Prefer:
- `entry.station = "station_id"`
- `entry.route = "route_id"` when the next path should be explicit

If `entry.route` is omitted, `station_dispatch.lua` resolves exactly one route from `current_station_id` to `entry.station`.

Routes are directed station edges. Prefer `from`, `to`, and `via`; legacy `waypoints` remain readable. `via` points are guardrails only, not station waits.

`wait.groups` is disjunctive normal form:
- OR between groups
- AND within a group

Supported condition types:
- `time_passed`
- `inactivity`
- `passengers`
- `fluid_percent`
- `cargo_percent`

Detector scopes:
- `station_any_detector`
- `station_all_detectors`
- `{ detector_id = "..." }`

Wagon-related metrics come from `ir_augment_detector.info()` only.
V1 does not use `ir_remote_control.consist()` for wagon waits.

`inactivity` resets on material metric changes:
- `cargo_percent` and `fluid_percent` at `0.5`
- `passengers` at `1`

## Station-Side Redstone

Stations define named outputs under `STATIONS[id].redstone_outputs`.

Allowed condition modes:
- `while_pending`
- `on_departure_pulse`

Meaning:
- `while_pending` stays active while a referencing condition remains false
- `on_departure_pulse` fires one pulse when the wait completes and the train departs

V1 remains intentionally limited:
- no redstone input waits
- no junction graph
- no block reservations

## Programs

- `route_book_editor.lua` edits the route book with a mouse-first terminal UI
- `station_dispatch.lua` validates and runs schedules on top of `train_controller.lua`
- `programs/lib/route_book_store.lua` owns canonical load/save formatting
- `programs/lib/augment_registry.lua` owns detector registry validation and scan helpers
- `programs/lib/station_schedule.lua` owns DNF wait evaluation
- `programs/lib/redstone_io.lua` owns output polarity and pulse handling
- `programs/lib/term_ui.lua` owns shared terminal hit-target rendering helpers
