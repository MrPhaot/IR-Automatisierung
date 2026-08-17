# IR 1.11.0 (Minecraft 1.7.10) Docs + Schedule Redstone/Scope Changes

Plan for three changes to the Immersive Railroading OpenComputers stack
(`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`).

Source of truth for runtime facts: the **installed** jar
`/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/mods/ImmersiveRailroading-1.7.10-forge-1.11.0.jar`.
Its `mcmod.info` declares `mcversion = "1.7.10"`, `version = "1.11.0"`. The GitHub
`TeamOpenIndustry/ImmersiveRailroading` repo and its changelog describe MC 1.10–1.16
builds and **do not apply** to this 1.7.10 jar — do not derive behavior from that
changelog. Verified-by-jar facts used below were obtained by unpacking the jar and
disassembling `cam72cam/immersiverailroading/gui/AugmentFilterGUI`,
`library/Augment$Properties`, `registry/LocomotiveDefinition`, and
`thirdparty/opencomputers/AugmentDriver*`.

User clarified: **points 2 & 3 are editor-only behavior** (`route_book_editor.lua`),
not the runtime dispatcher (`station_dispatch.lua`). `station_schedule.lua` still
must parse/evaluate the new scope format so saved schedules stay valid and the
dispatcher keeps working, but the dispatcher's per-entry detector read / redstone
drive is intentionally left unchanged.

---

## Implementation Order

1. **Docs first** (point 1) — re-baseline on the 1.7.10 jar, fix the version line,
   document the real augment rework, correct the rolling-stock additions.
2. **Schedule redstone union** (point 2) — editor + `station_schedule` validation.
3. **Wait-Condition scope rework** (point 3) — two-level + multi-select chooser.

---

## 1. Update docs for the 1.7.10 / IR 1.11.0 jar

### 1.1 Correct baseline (replaces the "MC version support: 1.17.1–1.21.1" line)

The project runs on **Minecraft 1.7.10** with **Immersive Railroading 1.11.0**
(jar: `ImmersiveRailroading-1.7.10-forge-1.11.0.jar`). The 1.17.1–1.21.1 version
range belongs to a different MC line and is irrelevant here. Do NOT copy the
GitHub IR changelog items wholesale — only facts confirmed in this jar apply.

### 1.2 Augment rework — CONFIRMED present in this jar (not "to be verified later")

Verified classes in the jar: `cam72cam/immersiverailroading/gui/AugmentFilterGUI`
and `cam72cam/immersiverailroading/library/Augment$Properties`. The augment filter
is now a **dedicated in-game GUI** (`AugmentFilterGUI`) with a **programmatic,
tag/predicate-based** filter model stored in `Augment$Properties`:

- `String positiveFilter`
- `String negativeFilter`
- `String doorActuatorFilter`
- `StockDetectorMode stockDetectorMode` (enum: `SIMPLE`, `SPEED`, …)
- `LocoControlMode locoControlMode`
- `RedstoneMode redstoneMode`
- `boolean pushpull`
- `CouplerAugmentMode couplerAugmentMode`

The old "right-click with a stock item to filter, redstone torch to configure"
model from the bundled `wiki/en_us/augment-detector.txt` is superseded by this GUI.

OC component facts verified from `thirdparty/opencomputers/AugmentDriver*` and
`wiki/en_us/open-computers.txt`:
- `component.ir_augment_detector`: `info()`, `consist()`, `getTag()`, `setTag(string)`,
  `getPos()`, `getAugmentType()`.
- `component.ir_augment_control`: `setThrottle(number)`, `setBrake(number)`, `horn()`,
  `getPos()`, `getAugmentType()`.
- `component.ir_remote_control` exists too — it is the **Radio Control Card**
  (`RadioCtrlCardDriver`), distinct from the augment components.
- Event: `ir_train_overhead` with `event_name, net_address, augment_type, stock_uuid`.

`info()` / `consist()` return "an info dump about the current car / consist" — the
exact field keys are **not** enumerated in the bundled wiki and MUST be re-verified
in-game before relying on them (keep the existing "Known Mismatch" note in
AGENTS.md; this plan does not change that).

### 1.3 Rolling-stock config additions — changelog field names do NOT match 1.7.10

The modern changelog lists `power_w/kw/ps/hp`, `tractive_effort_kn/n`,
`max_pressure_bar/kpa/psi`, `revertDirection`, `FORWARD`/`REVERSE` light dirs,
`tags`, `snow_layers`, `fuel_override`. **None of these exact names exist in this
jar.** `LocomotiveDefinition` (verified via `javap`) uses:

- `double power_kW`
- `double traction_N`
- `double factorOfAdhesion`
- `boolean toggleBell`, `boolean works`, `boolean hasRadioEquipment`,
  `boolean muliUnitCapable`, `boolean isCabCar`, `boolean isLinkedBrakeThrottle`,
  `boolean isCog`
- accessors: `getHorsePower(gauge)`, `getWatt(gauge)`, `getStartingTractionNewtons(gauge)`

`tags` surface through the augment `getTag`/`setTag` + `includeTags`/`excludeTags`
filter fields, not a `tags` stock-config key. So: **do not document the changelog's
rolling-stock field names as 1.7.10 facts.** Document the actual 1.7.10 fields above
and keep the "info() field shape unverified" note.

### 1.4 Command change

`IRCommand.class` in the jar references both `reload` and `cargoFill` tokens. Verify
in-game whether `/immersiverailroading reload` still exists in 1.11.0 and whether
`cargoFill` is the replacement subcommand; document whichever is true. Do not assume
the changelog's "reload removed" claim without confirming against this jar.

### 1.5 Exact doc edits (auto-updatable per AGENTS.md; `AGENTS.md` itself needs
explicit permission — list as a TODO, do not auto-edit)

- `docs/runtime.md`
  - Lines 3–7 "Confirmed Components": keep `component.ir_remote_control` but annotate
    it is the Radio Control Card; keep `ir_augment_detector` / `ir_augment_control` as
    the augment OC components. Add one line: "Augment filters are configured in-game
    via `AugmentFilterGUI` (tag/predicate based: includeTags/excludeTags,
    positiveFilter/negativeFilter, stockDetectorMode, locoControlMode, redstoneMode,
    pushpull, couplerAugmentMode)."
  - Lines 21–27 "Confirmed Augment Notes From Local Jar": change the jar reference from
    `1.7.10-forge-1.10.0.jar` to `1.7.10-forge-1.11.0.jar`. Replace the old
    wiki-derived bullets with the verified 1.11.0 augment model above. Keep the note
    that `info()` payload is not documented by the bundled wiki and must be verified
    in-game.
  - Add a one-line "Baseline" note: "Target Minecraft 1.7.10, Immersive Railroading
    1.11.0. The GitHub `TeamOpenIndustry/ImmersiveRailroading` repo describes other
    MC versions and does not apply here."
- `docs/station-schedules.md`
  - Lines 40–43 "Detector scopes": add the new per-station scope schema (see point 3);
    keep legacy forms as read-compat. Document that scope station resolution uses the
    schedule's entry stations (union, `via` excluded).
  - Lines 52–67 "Station-Side Redstone": add that the Schedule editor's redstone-rule
    output picker offers the **union** of `redstone_outputs` across all entry stations
    (not only the first entry). Clarify this is editor-only discovery; stations still
    DEFINE their outputs in the Stations tab (see point 2 note).
- `docs/operations/download-and-run.md`
  - Augment configuration is now via the in-game `AugmentFilterGUI`; the old
    right-click/redstone-torch method no longer applies.
  - Note the `/immersiverailroading reload` status per 1.4 (verify against jar).
- `README.md`: one-line baseline note: "Target: Minecraft 1.7.10, Immersive
  Railroading 1.11.0 (`ImmersiveRailroading-1.7.10-forge-1.11.0.jar`)."
- `AGENTS.md`: DO NOT auto-edit. List "IR 1.7.10/1.11.0 runtime facts" as needing
  user permission (update Confirmed Components + Known Mismatch to reference the
  1.11.0 jar and the augment GUI rework).

---

## 2. Redstone-I/O availability at Schedules = union of all entry stations

### 2.0 Scope clarification (answers the Schedule-vs-Stations question)

This change affects **only** the **Schedule editor's redstone-rule output picker**
(`refresh_rule_output_options`, used by the `redstone_rules` field) and the
schedule-wide wait-condition scope (point 3). It does **NOT** touch the **Stations
tab** (`Add Station` / `Edit Station`, lines ~2534–2618), where
`book.STATIONS[id].redstone_outputs` and `book.STATIONS[id].detector_ids` are
*defined/edited*. Those definitions are the source of truth; the union here is only
the set of *selectable* outputs shown to the user.

There is currently **no active per-condition redstone output picker**: legacy
`condition.redstone` is no longer written by the editor (only a "Legacy Redstone
Warning" is shown, lines ~2743–2748). If a future condition-redstone picker is added
it would also read this union, but it is out of scope now. So "update of
`refresh_rule_output_options` and any condition-redstone output picker" = update
`refresh_rule_output_options` only; the Stations tab is explicitly excluded.

Rule: the available redstone outputs shown for a schedule are the **union** of
`STATIONS[id].redstone_outputs` for every station referenced by an entry.
"Station referenced by an entry" = `entry.station` when present, else the route's
terminal station (`route.to` / `route_terminal_station_id`). **`via` waypoints are
excluded** — use `entry_destination_station_id` semantics (already ignores `via`).

Example: `entries = {{station="2_oil_frack"},{station="1_oil_ref"}}` → editor offers
the redstone outputs of BOTH `2_oil_frack` and `1_oil_ref`.

### 2.1 Editor changes (`programs/route_book_editor.lua`)

Replace `available_redstone_ids_for_station` (single station, lines 1360–1363) with
a schedule-wide union builder. The schedule entries live in the modal's `entries`
repeatable field (same accessor `modal_first_entry_ref` already reads the first
entry).

```lua
-- Returns every resolved station id referenced by the schedule's entries
-- (entry.station, else route terminal). via waypoints are ignored.
local function schedule_entry_station_ids(book, modal)
  local ids = {}
  for _, field in ipairs(modal and modal.fields or {}) do
    if field.key == "entries" then
      for _, item in ipairs(field.items or {}) do
        local refs = collect_schedule_entry_refs({entries = {item.value}})
        local ref = refs[1]
        if ref then
          local station_id = entry_destination_station_id(book, ref.station, ref.route)
          if station_id then
            ids[#ids + 1] = station_id
          end
        end
      end
    end
  end
  return ids
end

-- Sorted, de-duplicated union of redstone output names across the given stations.
local function available_redstone_ids_for_schedule(book, station_ids)
  local seen = {}
  local merged = {}
  for _, station_id in ipairs(station_ids or {}) do
    local station = book and book.STATIONS and book.STATIONS[station_id]
    for _, name in ipairs(sorted_keys(station and station.redstone_outputs or {})) do
      if not seen[name] then
        seen[name] = true
        merged[#merged + 1] = name
      end
    end
  end
  table.sort(merged)
  return merged
end
```

Update `refresh_rule_output_options` (lines 1390–1404) to use the union. Keep the
"append current value if absent" behavior so an already-saved output name remains
selectable even if its station is no longer referenced:

```lua
local function refresh_rule_output_options(modal, field)
  local book = field and field.book or nil   -- make_redstone_rule sets rule.book
  local station_ids = schedule_entry_station_ids(book, modal)
  if #station_ids == 0 then
    local single = modal_destination_station_id(book, modal)
    if single then
      station_ids = {single}
    end
  end
  local options = available_redstone_ids_for_schedule(book, station_ids)
  local seen_current = false
  for _, option in ipairs(options) do
    if option == tostring(field.output.value or "") then
      seen_current = true
      break
    end
  end
  if not seen_current and trim(field.output.value) ~= "" then
    options[#options + 1] = tostring(field.output.value)
  end
  field.output.options = options
end
```

Remove the stale comment at lines 1321–1324 ("outputs ... belong to the schedule's
first entry"); replace with: "Redstone rule output options are the union of every
entry station's `redstone_outputs` (see `schedule_entry_station_ids`)."

`SCHEDULE_SCOPE_BASE_OPTIONS` (line 88) is no longer used by the scope picker after
point 3; remove its two usages (lines 1367–1368) and the declaration.

### 2.2 Validation (`programs/lib/station_schedule.lua`)

A redstone rule is stored only on entry 1 (editor `on_submit`, lines 2769–2771) but
is conceptually schedule-wide, so a rule's output may belong to ANY entry station.
`M.validate_condition` gains an optional `allowed_outputs` set (output-name → true)
gathered per schedule as the union of all entry stations; when absent it falls back
to the single `route_book.STATIONS[station_id].redstone_outputs` (keeps the public
single-condition call usable).

```lua
function M.validate_condition(route_book, station_id, condition, allowed_outputs)
  ...
  if condition.redstone ~= nil then
    if type(condition.redstone) ~= "table" then
      errors[#errors + 1] = "redstone must be a table when present"
    else
      if type(condition.redstone.output) ~= "string" then
        errors[#errors + 1] = "redstone.output must be a string"
      else
        local outputs = allowed_outputs
        if outputs == nil then
          local station = route_book.STATIONS[station_id]
          outputs = station and station.redstone_outputs or {}
        end
        if not outputs[condition.redstone.output] then
          errors[#errors + 1] = ("redstone output %s not defined by any referenced station"):format(
            tostring(condition.redstone.output)
          )
        end
      end
      if condition.redstone.mode ~= "while_pending" and condition.redstone.mode ~= "on_departure_pulse" then
        errors[#errors + 1] = "redstone.mode must be while_pending or on_departure_pulse"
      end
    end
  end
  return errors
end
```

In `M.validate`, before the per-entry loop, build the union for the schedule and pass
it to both `validate_condition` calls (lines 216 and 268):

```lua
-- inside the `for _, name in ipairs(names)` loop, after `schedule = schedules[name]`:
local allowed_outputs = {}
for _, entry in ipairs(schedule.entries or {}) do
  local sid, sid_err = M.resolve_entry_station_id(route_book, entry)
  if sid then
    local station = route_book.STATIONS[sid]
    for name in pairs(station and station.redstone_outputs or {}) do
      allowed_outputs[name] = true
    end
  end
end
```

Then: `M.validate_condition(route_book, station_id, condition, allowed_outputs)` at
line 216, and `M.validate_condition(route_book, station_id, plain_condition, allowed_outputs)`
at line 268.

Runtime: unchanged (editor-only per user). If a condition references an output owned
by a non-active entry's station, runtime application at that station won't drive it —
document this as a known editor-only limitation (already noted in `station_schedule`
evaluate flow; no code change).

---

## 3. Wait-Condition Scope rework (editor-only)

New scope selection flow when a wait condition has the Scope feature (detector
condition types only: `passengers`, `cargo_percent`, `fluid_percent`):

1. **First click on Scope** → choose a **specific station** from the schedule's
   entry stations (fetched from `entries` exactly like point 2 via
   `schedule_entry_station_ids`).
2. **`station-all-detectors` is kept**, now expressed per chosen station: "all
   detectors of <station>" (AND semantics across that station's `detector_ids`).
3. **`station-any-detector` is replaced** by individual multi-select of the chosen
   station's detectors (OR semantics across the listed set).

### 3.1 Stored scope schema (architectural decision — no implementer freedom)

Persisted `condition.scope` is **always a table** in the new format; legacy strings
are read-compat only and normalized to the table form on first scope-chooser open:

- All detectors of a station: `{station_id = "<id>", all_detectors = true}`
- Explicit detector set (one or more): `{station_id = "<id>", detector_ids = {"d1","d2"}}`
  (sorted ascending, unique; empty `detector_ids` is treated as "none selected").
- Legacy (read-compat, never written by the editor):
  - `"station_all_detectors"` → `{station_id = <first entry station>, all_detectors = true}`
  - `"station_any_detector"` → `{station_id = <first entry station>, all_detectors = true}`
  - `{detector_id = "..."}` → `{station_id = <first entry station>, detector_ids = {"..."}}`
  The `<first entry station>` fallback uses `schedule_entry_station_ids(...)[1]`.

### 3.2 Exact text forms (display/round-trip — no refinement allowed)

`scope_to_editor_text(scope)` MUST return exactly:
- new all: `"station:<id>:all"` (e.g. `"station:2_oil_frack:all"`)
- new set: `"station:<id>:detectors:d1,d2"` — detector ids sorted ascending, joined
  by a single comma, **no spaces** (e.g. `"station:1_oil_ref:detectors:loader,mine_front"`)
- legacy string: returned verbatim (`"station_all_detectors"` / `"station_any_detector"`)
- legacy `{detector_id="x"}`: `"detector:x"`

`scope_from_editor_text(text, fallback_station_id)` MUST parse exactly:
- `"station:<id>:all"` → `{station_id="<id>", all_detectors=true}`
- `"station:<id>:detectors:d1,d2"` → `{station_id="<id>", detector_ids={d1,d2}}`
  (split on `,`, trim each, drop empties, sort)
- `"station_all_detectors"` / `"station_any_detector"` →
  `{station_id=fallback, all_detectors=true}` (legacy, normalized)
- `"detector:x"` → `{detector_id="x"}` (legacy, normalized only if station unknown)
- anything else → `{station_id=fallback, all_detectors=true}`

```lua
local function scope_to_editor_text(scope)
  if type(scope) == "table" and type(scope.station_id) == "string" then
    if scope.all_detectors then
      return ("station:%s:all"):format(scope.station_id)
    end
    if type(scope.detector_ids) == "table" then
      local ids = {}
      for _, d in ipairs(scope.detector_ids) do
        ids[#ids + 1] = d
      end
      table.sort(ids)
      return ("station:%s:detectors:%s"):format(scope.station_id, table.concat(ids, ","))
    end
  end
  if scope == "station_all_detectors" or scope == "station_any_detector" then
    return scope
  end
  if type(scope) == "table" and type(scope.detector_id) == "string" then
    return "detector:" .. scope.detector_id
  end
  return "station_any_detector"
end

local function parse_station_scope(text, fallback_station_id)
  local sid, kind, rest = text:match("^station:([^:]*):(all|detectors):?(.*)$")
  if not sid or sid == "" then
    sid = fallback_station_id
  end
  if kind == "all" then
    return {station_id = sid, all_detectors = true}
  end
  if kind == "detectors" then
    local ids = {}
    for id in (rest or ""):gmatch("([^,]+)") do
      local t = trim(id)
      if t ~= "" then
        ids[#ids + 1] = t
      end
    end
    table.sort(ids)
    return {station_id = sid, detector_ids = ids}
  end
  return nil
end

local function scope_from_editor_text(text, fallback_station_id)
  text = trim(text)
  local parsed = parse_station_scope(text, fallback_station_id)
  if parsed then
    return parsed
  end
  if text == "station_all_detectors" or text == "station_any_detector" then
    return {station_id = fallback_station_id, all_detectors = true}
  end
  if text:match("^detector:") then
    local detector_id = trim(text:sub(#"detector:" + 1))
    if detector_id ~= "" then
      return {detector_id = detector_id}
    end
  end
  return {station_id = fallback_station_id, all_detectors = true}
end
```

`make_chain_condition` (line 412) already routes `scope` through
`scope_to_editor_text`; with a table scope this now yields the new text — fine, but
the persisted value should be the **table**, not the text. Therefore change line 419
from `scope = scope_to_editor_text(condition.scope)` to store the normalized table:
`scope = scope_from_editor_text(scope_to_editor_text(condition.scope), first_station_id)`
where `first_station_id = schedule_entry_station_ids(book, modal)[1]`. To keep
`make_chain_condition` pure, pass `first_station_id` in: update its two call sites
(lines 2055, 2078-area) to supply it from `state.book`/`state.modal`.

`apply_condition_type` (line 2030) calls
`scope_to_editor_text(scope_from_editor_text(condition.scope))`; change to
`scope_from_editor_text(scope_to_editor_text(condition.scope), first_station_id)`.

### 3.3 Two-level + multi-select scope chooser

The existing chooser (`build_chain_chooser_rows`, `choose_chain_option`) is
single-select. Extend the `scope` chooser object and its row rendering; do NOT
generalize the whole chooser framework.

`begin_scope_chooser(state, field)` (replace lines 1997–2021):

```lua
local function begin_scope_chooser(state, field)
  local condition = selected_chain_condition(field)
  if not condition then
    return false
  end
  local station_ids = schedule_entry_station_ids(state.book, state.modal)
  if #station_ids == 0 then
    return false
  end
  -- Normalize legacy scope to the new table form up front.
  local fallback = station_ids[1]
  if type(condition.scope) ~= "table" or type(condition.scope.station_id) ~= "string" then
    condition.scope = scope_from_editor_text(scope_to_editor_text(condition.scope), fallback)
  end
  field.chooser = {
    kind = "scope",
    condition_ref = {
      group_index = field.selected_group_index,
      condition_index = field.selected_condition_index,
    },
    stage = "station",
    station_id = nil,
    selected_detectors = {},
    all_selected = false,
    options = station_ids,   -- Level 1: entry station ids
    selected = 1,
  }
  return true
end
```

`choose_chain_option` scope branch (replace lines 2110–2119):

```lua
  if chooser.kind == "scope" then
    local condition = field.groups[chooser.condition_ref.group_index].conditions[chooser.condition_ref.condition_index]
    if not condition then
      return false
    end

    if chooser.stage == "station" then
      chooser.station_id = chooser.options[chooser.selected]
      local prev = type(condition.scope) == "table" and condition.scope or {}
      chooser.all_selected = (prev.station_id == chooser.station_id) and (prev.all_detectors == true)
      chooser.selected_detectors = {}
      if prev.station_id == chooser.station_id and type(prev.detector_ids) == "table" then
        for _, d in ipairs(prev.detector_ids) do
          chooser.selected_detectors[d] = true
        end
      end
      local station = state.book.STATIONS[chooser.station_id] or {}
      chooser.options = {"(all detectors)"}
      for _, d in ipairs(sorted_keys(station.detector_ids or {})) do
        chooser.options[#chooser.options + 1] = d
      end
      chooser.options[#chooser.options + 1] = "(done)"
      chooser.stage = "detectors"
      chooser.selected = 1
      return true
    end

    if chooser.stage == "detectors" then
      if chooser.selected == #chooser.options then
        -- "(done)": write the resolved scope table and close.
        if chooser.all_selected then
          condition.scope = {station_id = chooser.station_id, all_detectors = true}
        else
          local ids = {}
          for _, d in ipairs(chooser.options) do
            if d ~= "(all detectors)" and d ~= "(done)" and chooser.selected_detectors[d] then
              ids[#ids + 1] = d
            end
          end
          table.sort(ids)
          condition.scope = {station_id = chooser.station_id, detector_ids = ids}
        end
        field.selected_group_index = chooser.condition_ref.group_index
        field.selected_condition_index = chooser.condition_ref.condition_index
        field.chooser = nil
        return true
      end
      if chooser.selected == 1 then
        chooser.all_selected = not chooser.all_selected
        if chooser.all_selected then
          chooser.selected_detectors = {}
        end
      else
        local detector_id = chooser.options[chooser.selected]
        chooser.selected_detectors[detector_id] = not chooser.selected_detectors[detector_id]
        chooser.all_selected = false
      end
      return true
    end

    return false
  end
```

`build_chain_chooser_rows` (lines 1443–1462): for `chooser.kind == "scope"`, set the
section label from `chooser.stage` ("Choose Scope Station" / "Choose Detectors"),
and add `row.checked` so multi-select shows `[x]`:

```lua
  rows[#rows + 1] = {
    kind = "section",
    label = (chooser.kind == "scope")
      and (chooser.stage == "detectors" and "Choose Detectors" or "Choose Scope Station")
      or (({
        operator = "Choose Join",
        condition_type = "Choose Condition",
        existing_condition_type = "Choose Condition",
        comparator = "Choose Comparator",
        scope = "Choose Scope",
      })[chooser.kind] or "Choose Option"),
  }
  for option_index, option in ipairs(chooser.options or {}) do
    local checked
    if chooser.kind == "scope" and chooser.stage == "detectors" then
      if option == "(all detectors)" then
        checked = chooser.all_selected
      elseif option == "(done)" then
        checked = nil
      else
        checked = chooser.selected_detectors[option] == true
      end
    end
    rows[#rows + 1] = {
      kind = "chain_chooser",
      field_index = field_index,
      field = field,
      chooser = chooser,
      option_index = option_index,
      option = option,
      checked = checked,
    }
  end
```

`render_chain_chooser_row` (lines 2355–2369): when `row.checked ~= nil`, render
`row.checked and "[x]" or "[ ]"` instead of the `selected == option_index` marker.

Scope summary rendering (line 2202) and chain-condition token rendering (lines 2949,
2967) already call `scope_to_editor_text(condition.scope)`; with the table scope they
now produce `station:<id>:all` / `station:<id>:detectors:...`. No change needed
there, but update any literal "station_any_detector" default text in those two spots
to use `scope_to_editor_text` (already the case).

### 3.4 `station_schedule.lua` resolution/validation (keep dispatcher working)

`resolve_detector_ids` signature changes from `(station, condition)` to
`(route_book, condition)` because the new table scope carries its own `station_id`
that may differ from the active session station. Update the only caller at line 338
from `resolve_detector_ids(session.station, condition)` to
`resolve_detector_ids(session.route_book, condition)` (the session built in
`create_wait_session` already carries `route_book`).

```lua
local function resolve_detector_ids(route_book, condition)
  if type(condition.scope) == "table" and type(condition.scope.station_id) == "string" then
    local station = route_book.STATIONS[condition.scope.station_id]
    if condition.scope.all_detectors then
      return station and station.detector_ids or {}
    end
    if type(condition.scope.detector_ids) == "table" then
      return condition.scope.detector_ids
    end
  end
  if condition.scope == "station_any_detector" or condition.scope == "station_all_detectors" then
    return station.detector_ids or {}   -- legacy: uses the active station
  end
  if type(condition.scope) == "table" and type(condition.scope.detector_id) == "string" then
    return {condition.scope.detector_id}
  end
  return {}
end
```

`evaluate_condition` (lines 357–374) is unchanged: with the resolved id list,
`station_all_detectors`/new `all_detectors` use AND across that station's detectors;
otherwise OR across the listed set (existing else-branch). Keep legacy
`station_any_detector` OR behavior for read-compat.

`validate_condition` scope check (lines 121–124): accept the new table form:

```lua
    local scope = condition.scope
    local scope_ok = false
    if scope == "station_any_detector" or scope == "station_all_detectors" then
      scope_ok = true
    elseif type(scope) == "table" and type(scope.station_id) == "string" then
      if scope.all_detectors == true then
        scope_ok = true
      elseif type(scope.detector_ids) == "table" then
        scope_ok = true
        for _, d in ipairs(scope.detector_ids) do
          if type(d) ~= "string" then
            scope_ok = false
            break
          end
        end
      end
    elseif type(scope) == "table" and type(scope.detector_id) == "string" then
      scope_ok = true
    end
    if not scope_ok then
      errors[#errors + 1] = ("%s requires station_any_detector, station_all_detectors, "
        .. "{station_id, all_detectors=true}, {station_id, detector_ids={...}}, or {detector_id=...} scope"):format(condition.type)
    end
```

---

## Affected files

- `programs/route_book_editor.lua` — points 2 & 3 (union + two-level/multi-select scope UI).
- `programs/lib/station_schedule.lua` — `validate_condition` `allowed_outputs` param + new
  scope table; `resolve_detector_ids(route_book, condition)`; scope validation.
- `docs/runtime.md`, `docs/station-schedules.md`, `docs/operations/download-and-run.md`,
  `README.md` — point 1 (exact edits in §1.5).
- `AGENTS.md` — DO NOT auto-edit; list "IR 1.7.10/1.11.0 runtime facts" as needing user permission.
- Preview tests (update assertions, see §Validation):
  `tests/previews/route_book_editor_emulator.lua` (~97, ~128),
  `tests/previews/station_schedule_preview.lua` (~30, ~102),
  `tests/previews/term_ui_preview.lua` (~294, ~411, ~458).

## Validation

- `luac -p` on edited Lua files.
- Update preview tests:
  - `route_book_editor_emulator.lua` line ~128: the wait-summary assertion currently
    expects `"station_any_detector"`; keep legacy-string parsing working, and add an
    assertion that a new table scope `{"station_id"="1_oil_ref", detector_ids={"loader"}}`
    round-trips through `scope_to_editor_text` → `"station:1_oil_ref:detectors:loader"`.
  - `station_schedule_preview.lua` / `term_ui_preview.lua`: keep legacy `"station_any_detector"`
    scopes validating; add a case where `condition.scope =
    {station_id="x", detector_ids={"a","b"}}` validates and resolves to `{"a","b"}`.
- Add a preview asserting: (a) schedule redstone options = union of entry stations;
  (b) scope chooser Level 1 lists entry stations; (c) choosing a station then toggling
  detectors then "(done)" writes `{station_id, detector_ids={...}}`; (d) legacy scope
  values still validate.
- Manual: open `route_book_editor.lua`, edit a multi-entry schedule, confirm the
  redstone-rule output picker shows all entry stations' outputs and the Scope flow
  picks station → detector set; confirm the Stations tab I/O editing is unaffected.
