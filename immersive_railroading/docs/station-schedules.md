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
- `arrived_at_station`
- `passengers`
- `fluid_percent`
- `cargo_percent`

`arrived_at_station` completes when the active wait station matches the rule's `station` field.
The station must be one of the schedule's entry stations (resolved from `entry.station` or the
route terminal `route.to`). No detector read is involved.

Detector scopes (per-station, chosen via the editor's two-stage Scope picker):
- All detectors of a station: `{station_id = "<id>", all_detectors = true}`
- Explicit detector set: `{station_id = "<id>", detector_ids = {"d1", "d2"}}` (sorted, unique; empty set = none selected)

Legacy forms are read-compat and never written by the editor:
- `"station_all_detectors"` / `"station_any_detector"`
- `{detector_id = "..."}`

Scope station resolution uses the schedule's entry stations (union of every entry's station,
resolved from `entry.station` or the route terminal `route.to`; `via` is excluded). A scope
referencing a station not currently among the entries still resolves at runtime via the active
station, so a missing `station_id` (from legacy-normalized scopes) is valid.

Wagon-related metrics come from `ir_augment_detector.info()` only.
V1 does not use `ir_remote_control.consist()` for wagon waits.

`inactivity` resets on material metric changes:
- `cargo_percent` and `fluid_percent` at `0.5`
- `passengers` at `1`

## Station-Side Redstone

Stations define named outputs under `STATIONS[id].redstone_outputs`.

Each redstone rule now supports `signal` and `pulse_ticks`:
- `signal`: `"pulse"` (one-shot on rising edge) or `"constant"` (held while rule groups complete)
- `pulse_ticks`: optional per-rule pulse duration (ticks); falls back to the output's configured
  `pulse_ticks` at runtime

Condition modes on wait conditions (legacy):
- `while_pending`
- `on_departure_pulse`

Rule signal semantics:
- `constant` → output held active while the rule's DNF groups evaluate to complete (reuses
  `pending_outputs`)
- `pulse` → one-shot pulse (duration = `rule.pulse_ticks` or output's `pulse_ticks`) on the
  rising edge of rule-group completion. In-flight arrival pulses are terminated by departure
  `shutdown`; this is acceptable because the pulse already started on the rising edge.

The Schedule editor's redstone-rule output picker offers the **union** of `redstone_outputs`
across every entry station (so a rule may bind an output defined on any entry's station). Stations
still OWN and DEFINE their outputs in the Stations tab; the union is editor-only discovery and does
not change how the dispatcher drives the active entry's station. A rule bound to a non-active entry's
output validates, but only fires at runtime when that entry is the active wait station.

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
