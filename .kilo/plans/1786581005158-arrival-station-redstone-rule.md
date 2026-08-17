# Redstone Rule Condition: "arrived at station" + per-rule pulse/constant

Revised plan for
`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`.
Builds on the just-implemented scope/union plan
(`.kilo/plans/1786581005158-ir111-schedule-scope-redstone.md`) and the
verified jar baseline (`ImmersiveRailroading-1.7.10-forge-1.11.0.jar`).

## Architecture decisions (final — no implementer discretion)
1. **"arrived at station" is a new condition type `arrived_at_station`** added to the
   shared `SCHEDULE_CONDITION_TYPES` vocabulary (route_book_editor.lua:79). It carries a
   `station` (must be one of the schedule's entry stations). Usable in
   `entry.redstone.rules[].groups` (DNF) and in `entry.wait.groups` (where it completes
   immediately at that station). It is NOT a separate top-level schedule field.
2. **Redstone rule schema becomes `{output, signal, pulse_ticks, groups}`.** The user picks
   the redstone output first (existing flow), then adds conditions (including
   `arrived_at_station`) and chains them (AND/OR). `signal` ∈ `{"pulse","constant"}` stored
   as a choice field on the rule; `pulse_ticks` is a per-rule number text field, optional —
   falls back to the output's configured `pulse_ticks` at runtime. This satisfies
   "individually pickable per rule, not a global schedule variable."
3. **Signal semantics:**
   - `constant` → output held active while the rule's `groups` evaluate to complete
     (reuses the existing `pending_outputs` mechanism in `tick_wait_session`).
   - `pulse` → one-shot pulse (duration = `rule.pulse_ticks` or the output's
     `pulse_ticks`) on the rising edge of rule-group completion. Implemented via a new
     `tick.arrival_pulses` array; the dispatcher fires these pulses inside the wait loop.
     NOTE: `shutdown` at departure will terminate any in-flight arrival pulse; this is
     acceptable because the pulse already started on the rising edge.
4. **Output picker for a redstone rule = the union of all entry stations' outputs**
   (from the just-implemented `available_redstone_ids_for_schedule`), consistent with
   §2 of the scope/union plan. "arrived at X" conditions inside the rule can reference
   any entry station; validation enforces the station is an entry station.
5. **`station_dispatch.lua` is the only runtime touch.** Add `arrival_pulses` handling in
   the per-entry wait loop; no detector-read change. The existing `redstone_io` controller
   already supports arbitrary `pulse_ticks` via its `config.pulse_ticks` field, so a
   per-rule override is just a config copy with the overridden field.

## 1. New condition type `arrived_at_station`
### 1.1 Editor (`programs/route_book_editor.lua`)
- Add `"arrived_at_station"` to `SCHEDULE_CONDITION_TYPES` (line 79), between
  `"inactivity"` and `"passengers"`.
- `make_chain_condition` (442): add `station = tostring(condition.station or "")` to the
  returned table.
- `runtime_condition_from_editor` (689): add branch
  `elseif condition.type == "arrived_at_station" then out.station = tostring(condition.station or "")`.
- `apply_condition_type` (2108): add branch
  `elseif option == "arrived_at_station" then condition.station = tostring(condition.station or "")`.
- `chain_condition_label` (559): add branch
  `elseif condition.type == "arrived_at_station" then label = ("arrived at %s"):format(tostring(condition.station or "?"))`.
- `build_modal_rows` condition_chain branch (1609–1637): after the `else` block that adds
  comparator/value/scope, add an `elseif selected.type == "arrived_at_station"` branch that
  appends a single `chain_condition_detail` row with `detail = "station"`.
- `chain_detail_visible_value` (2319): add
  ```lua
  if row.detail == "station" then
    return ("Station: [%s]"):format(tostring(condition.station or "?"))
  end
  ```
- Click handlers for `chain_condition_detail` with `detail == "station"` (both at 3330–3340
  and 3374–3384): add
  ```lua
  if clicked_row.detail == "station" then
    return begin_station_chooser_for_arrival(state, clicked_row.field)
  end
  ```
- New helper `begin_station_chooser_for_arrival(state, field)`:
  - `condition = selected_chain_condition(field)`; if nil return false.
  - `station_ids = schedule_entry_station_ids(state.book, state.modal)`; if empty return false.
  - Pre-select the index of `condition.station` if present.
  - `field.chooser = {kind="station_chooser", condition_ref={group_index=field.selected_group_index, condition_index=field.selected_condition_index}, options=station_ids, selected=selected}`.
  - return true.
- `choose_chain_option` (2119): add branch
  ```lua
  if chooser.kind == "station_chooser" then
    local condition = field.groups[chooser.condition_ref.group_index].conditions[chooser.condition_ref.condition_index]
    if not condition then return false end
    condition.station = tostring(chooser.options[chooser.selected] or "")
    field.selected_group_index = chooser.condition_ref.group_index
    field.selected_condition_index = chooser.condition_ref.condition_index
    field.chooser = nil
    return true
  end
  ```
- `build_chain_chooser_rows` (1492): add `station_chooser = "Choose Station"` to the
  section_label map (line 1498). The existing loop at 1511–1531 already renders any
  chooser kind as `chain_chooser` rows, so no further change needed.

### 1.2 `station_schedule.lua` resolution/validation
- `validate_condition` (103): accept `arrived_at_station`. Add branch:
  ```lua
  elseif condition.type == "arrived_at_station" then
    if type(condition.station) ~= "string" or condition.station == "" then
      errors[#errors + 1] = "arrived_at_station requires a non-empty station"
    elseif entry_station_ids and not entry_station_ids[condition.station] then
      errors[#errors + 1] = ("arrived_at_station station %s is not in schedule entries"):format(condition.station)
    end
  ```
  Add `entry_station_ids` as a 5th optional parameter (default `nil`) to preserve backward
  compatibility.
- `evaluate_condition` (377): add branch before the final `else`:
  ```lua
  elseif condition.type == "arrived_at_station" then
    complete = session.station_id == condition.station
  ```
  (true iff the active wait station matches; no detector, no scope).
- `resolve_detector_ids` (334): not called for `arrived_at_station` (no scope). Fine.

## 2. Redstone rule schema change (`{output, signal, pulse_ticks, groups}`)
### 2.1 Editor (`programs/route_book_editor.lua`)
- `make_redstone_rule` (483): extend the editor rule table with
  `signal = make_choice_field({key="signal", label="Signal", value="constant", options={"pulse","constant"}})` and
  `pulse_ticks = make_text_field({key="pulse_ticks", label="Pulse ticks", value=""})`.
- `runtime_redstone_rules_from_editor` (720): persist
  `{output=trim(rule.output.value), signal=rule.signal and rule.signal.value or "constant", pulse_ticks=tonumber(rule.pulse_ticks and rule.pulse_ticks.value) or nil, groups=runtime_groups_from_chain(rule)}`.
- `build_modal_rows` redstone_rules branch (1643–1694): in the "Selected Redstone Rule"
  section, after the `redstone_rule_output` row (1674–1680), add
  ```lua
  rows[#rows + 1] = {kind="choice", field=rule.signal}
  rows[#rows + 1] = {kind="text", field=rule.pulse_ticks}
  ```
  (Generic `choice` and `text` rows render via existing modal renderers at 2388–2391 and
  are editable via existing handlers at 3320–3321 and 3635–3636 / `current_modal_text_cell`.)
- Schedule edit modal `on_submit` (2916–2936): unchanged — the `redstone_rules` field
  already writes `entry.redstone.rules` to entry 1 (and copies previous entries). The new
  `signal`/`pulse_ticks` are carried inside each rule by the existing field plumbing.

### 2.2 Runtime (`programs/station_dispatch.lua` + `station_schedule.lua`)
- `create_wait_session` (354): add `_rule_complete = {}` to the returned session table.
- `tick_wait_session` (443): change the rule evaluation loop from
  `for _, rule in ipairs(...)` to `for rule_index, rule in ipairs(...)` so we can track
  per-rule rising edges. Replace the existing `pending_outputs[rule.output] = true` (474–476)
  with:
  ```lua
  local rule_complete = M.evaluate_rule_groups(rule.groups, session.station, detector_snapshots, session, now)
  if rule.signal == "constant" and rule_complete then
    pending_outputs[rule.output] = true
  end
  if rule.signal == "pulse" and rule_complete and not session._rule_complete[rule_index] then
    local cfg = (session.station.redstone_outputs or {})[rule.output]
    if cfg then
      local pulse_cfg = {}
      for k, v in pairs(cfg) do pulse_cfg[k] = v end
      pulse_cfg.pulse_ticks = rule.pulse_ticks or cfg.pulse_ticks or 20
      arrival_pulses[#arrival_pulses + 1] = {name = rule.output, config = pulse_cfg}
    end
  end
  session._rule_complete[rule_index] = rule_complete
  ```
  (Wrap this in the existing loop; add `local arrival_pulses = {}` near line 449.)
- Extend the `tick_wait_session` return table (492–499) with `arrival_pulses = arrival_pulses`.
- In `station_dispatch.lua` wait loop, after `tick = station_schedule.tick_wait_session(...)` (598)
  and before the `if tick.complete` block (609):
  ```lua
  for _, p in ipairs(tick.arrival_pulses or {}) do
    io_controller:pulse(p.name, p.config)
  end
  ```
  (Mirrors the departure-pulse loop at 610–612.) The existing `io_controller:shutdown` at
  departure (614) clears any in-flight pulse.

## 3. Validation (`programs/lib/station_schedule.lua`)
### 3.1 Entry-station set (shared)
In `M.validate` (178), per schedule, build the set once before the per-entry loop:
```lua
local entry_station_ids = {}
for _, entry in ipairs(schedule.entries or {}) do
  local sid = M.resolve_entry_station_id(route_book, entry)
  if sid then entry_station_ids[sid] = true end
end
```
Pass `entry_station_ids` into the `validate_condition` calls (lines 250, 304) so
`arrived_at_station` can be checked.

### 3.2 `validate_condition` (103)
Accept `arrived_at_station`: require `condition.station` to be a string. When
`entry_station_ids` is provided, enforce `entry_station_ids[condition.station]`.
Add `entry_station_ids` as a 5th optional parameter (default `nil`) to preserve backward
compatibility.

### 3.3 Redstone rule validation
In the rule-validation block (lines 269–317), after validating `rule.output` and
`rule.groups`:
- `rule.signal` must be `"pulse"` or `"constant"` (or absent/empty → treat as `"constant"`).
- `rule.pulse_ticks`, when present, must be numeric (≥ 1).

## 4. Docs
- `docs/station-schedules.md` "Station-Side Redstone": document that `entry.redstone.rules`
  now supports `signal` (`pulse`/`constant`) and `pulse_ticks` (per-rule, optional),
  and that the DNF condition vocabulary includes `arrived_at_station` (requires a station
  from the schedule's entries). Note `constant` = held while rule groups complete;
  `pulse` = one-shot on rising edge with per-rule duration (falls back to output's
  `pulse_ticks`). Note also that in-flight arrival pulses are terminated by the
  departure `shutdown`.
- (Optional) `inspect_redstone_runtime` (route_book_editor.lua:907): arrival-pulse
  behavior is already covered by the existing rule listing.

## 5. Tests / previews
- `station_schedule_preview.lua`: add a valid/invalid `arrived_at_station` condition
  (station in entries → valid; station missing → invalid).
- `route_book_editor_emulator.lua`: round-trip an `arrived_at_station` condition inside a
  redstone rule's group, plus a rule with `signal="pulse"` and `pulse_ticks=10`.
- Dispatcher preview / emulator: add a schedule with entry 1 → station X, redstone rule
  `{output="O", signal="pulse", groups={{arrived_at_station X}}}`. Assert on arrival at X
  the dispatcher calls `io_controller:pulse("O", cfg_with_pulse_ticks)`. Assert a
  `constant` rule keeps `O` in pending_outputs during the wait and it is cleared on
  departure.
- Update `term_ui_preview.lua` if it asserts condition-type counts (add
  `arrived_at_station` to the chooser options).

## Affected files
- `programs/route_book_editor.lua` — `SCHEDULE_CONDITION_TYPES`; chain condition
  type/detail/rendering for `arrived_at_station`; new `station_chooser` kind;
  `make_redstone_rule` + `runtime_redstone_rules_from_editor` extended with `signal`/`pulse_ticks`;
  rule rendering rows for signal/pulse_ticks; `apply_condition_type` extended.
- `programs/station_dispatch.lua` — arrival-pulse handling in wait loop.
- `programs/lib/station_schedule.lua` — `evaluate_condition` `arrived_at_station` branch;
  `tick_wait_session` rising-edge pulse tracking + `arrival_pulses` return field;
  `create_wait_session` `_rule_complete` init; `validate_condition` + `M.validate`
  entry-station-set + `arrived_at_station` checks; redstone-rule `signal`/`pulse_ticks`
  validation.
- `docs/station-schedules.md` — arrival-condition docs.
- `AGENTS.md` — DO NOT auto-edit (needs permission).

## Validation
- `luac -p` on edited Lua files.
- Run preview tests above; manual: edit a multi-entry schedule, add a redstone rule with
  `arrived_at_station` chained with `cargo_percent >= 90`, set `signal="pulse"`,
  `pulse_ticks=15`; run `station_dispatch run <schedule>`; confirm the output pulses on
  arrival with 15-tick duration. Set `signal="constant"`; confirm output stays active
  during the wait and clears on departure. Confirm existing `entry.redstone.rules` and
  Stations tab I/O editing are unaffected.

## Risks / edge cases (all closed)
- `arrived_at_station` true only when `session.station_id == condition.station` → no
  detector read, no cross-station runtime magic; matches "wait cycle is initiated" at that
  station.
- Pulse rising-edge tracked per-session (`_rule_complete`) → no double-pulse on re-eval.
- Per-rule `pulse_ticks` overrides output's default via a config copy; no global state.
- `create_wait_session` builds a fresh session per entry, so `_rule_complete` resets
  naturally between entries/cycles.
- Cyclic revisits → arrival pulse fires on each revisit; correct.
- In-flight arrival pulse terminated by departure `shutdown`; acceptable because the pulse
  already started on the rising edge.
