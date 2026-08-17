# IR 1.11.0 (Minecraft 1.7.10 / GTNH) Docs + Schedule Redstone/Scope Changes

Implementation-ready plan for
`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`.

All runtime facts below are **verified by inspecting the installed jar**
`ImmersiveRailroading-1.7.10-forge-1.11.0.jar`
(`~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/mods/`).

---

## Baseline (verified — overrides the earlier GitHub-changelog assumption)
- Target: **Minecraft 1.7.10**, **Immersive Railroading 1.11.0** (GTNH port jar).
- The GitHub `TeamOpenIndustry/ImmersiveRailroading` changelog describes a **different
  MC line (1.17+)** and does **NOT** apply here. Do not copy its feature list (transfer
  table, TABLE part, MC 1.17+ support, `power_w`/`tractive_effort_kn`/`max_pressure_*`
  config keys). None of those names exist in this jar.
- `component.ir_remote_control` is the **Radio Control Card**
  (`thirdparty/opencomputers/RadioCtrlCardDriver`) — distinct from the augment components.
- Augment OC components (verified in `wiki/en_us/open-computers.txt`):
  - `component.ir_augment_detector`: `info()`, `consist()`, `getTag()`, `setTag(string)`,
    `getPos()`, `getAugmentType()`.
  - `component.ir_augment_control`: `setThrottle(number)`, `setBrake(number)`, `horn()`,
    `getPos()`, `getAugmentType()`.
- `info()` / `consist()` return an info dump whose **exact field keys are not enumerated**
  in the bundled wiki — keep the existing "Known Mismatch" note; re-verify in-game.
- Augment filter rework confirmed present: `gui/AugmentFilterGUI` + `library/Augment$Properties`
  (tag/predicate model: `positiveFilter`, `negativeFilter`, `doorActuatorFilter`,
  `stockDetectorMode`, `locoControlMode`, `redstoneMode`, `pushpull`, `couplerAugmentMode`).
  `tags` surface via augment `getTag`/`setTag` + `includeTags`/`excludeTags` filter fields,
  **not** a stock-config `tags` key.
- Command: `/immersiverailroading reload` **still exists** in 1.11.0 (jar `IRCommand`
  usage string is `(reload|debug)`); `cargoFill` also present. Do **not** document reload
  as removed.

**User constraint (hard):** points 2 & 3 are **editor-only** (`route_book_editor.lua`).
`station_dispatch.lua` runtime tick logic is **not** changed (per-entry detector read and
per-entry redstone drive stay as-is). `station_schedule.lua` must still parse/evaluate the
new scope format so saved schedules remain valid and the (unchanged) dispatcher keeps working.

---

## Architecture decisions (final — no implementer discretion)

1. **Editor-internal `condition.scope` is a string; the persisted schedule stores a table.**
   This matches the existing code path: `make_chain_condition` (route_book_editor.lua:419)
   stores `scope_to_editor_text(stored_table)` → string in the chain field;
   `runtime_condition_from_editor` (659) calls `scope_from_editor_text(string)` → table when
   the modal is submitted. The new table form lives only in persisted data + chooser state.
   Consequence: `chain_condition_label` (538, `tostring`) and the `render_modal` scope row
   (2202, `tostring`) need **no change** — they already render a string. Do **not** convert
   the chain field to hold tables; that would break those two render sites.

2. **The redstone-output union and the scope station list are computed from the MODAL's
   live `entries` field, not the saved schedule.** Why: the user edits `entries` inside the
   modal before `on_submit` writes them back; the picker must reflect the in-progress draft
   (e.g. adding a 3rd entry must immediately extend the offered outputs/stations). Reading
   the saved `SCHEDULES[id].entries` would lag until save. `refresh_rule_output_options` and
   `begin_scope_chooser` therefore call `schedule_entry_station_ids(state.book, state.modal)`.

3. **`resolve_detector_ids(route_book, station, condition)`** — keep the active `station`
   parameter alongside `route_book` so legacy string scopes (which carry no station) still
   fall back to the active entry station. New table scopes look up their own
   `scope.station_id` in `route_book`.

4. **Legacy scope values are read-compat and normalized on save, never written by the editor.**
   `"station_any_detector"` / `"station_all_detectors"` / `{detector_id=...}` still parse and
   evaluate. A `nil` `station_id` (from legacy normalized without a fallback) is **accepted**
   by validation and resolved at runtime via the active station — do not require
   `station_id` to be a string in the validation check.

5. **Scope chooser is a two-stage state machine with no back-navigation.** Stage 1 = station
   pick (from entry stations); stage 2 = detector multi-select + "(done)". The detector stage
   does **not** auto-close; only "(done)" writes and closes. Arrow keys move
   `chooser.selected`; Enter calls `choose_chain_option`.

6. **`station_dispatch.lua` is out of scope.** No detector-read or redstone-drive changes.
   A redstone rule referencing a non-active entry's output validates OK but only fires when
   that entry is the active wait station — accepted editor-only limitation.

---

## 1. Docs (auto-updatable per AGENTS.md; `AGENTS.md` itself needs explicit permission)

- `docs/runtime.md`
  - Lines 3–7 "Confirmed Components": keep `ir_remote_control` (annotate = Radio Control
    Card), `ir_augment_detector`, `ir_augment_control`. Add one line on `AugmentFilterGUI`
    (tag/predicate filters: includeTags/excludeTags, positiveFilter/negativeFilter,
    stockDetectorMode, locoControlMode, redstoneMode, pushpull, couplerAugmentMode).
  - Lines 21–27 "Confirmed Augment Notes From Local Jar": change jar reference
    `1.7.10-forge-1.10.0.jar` → `1.7.10-forge-1.11.0.jar`; replace old wiki bullets with the
    verified 1.11.0 augment model; keep "info() payload not documented, verify in-game".
  - Add "Baseline" note: MC 1.7.10 / IR 1.11.0 (GTNH); the GitHub repo/changelog is a
    different MC line and does not apply.
- `docs/station-schedules.md`
  - "Detector scopes": document the new per-station scope schema (§3); keep legacy forms as
    read-compat; scope station resolution uses the schedule's entry stations (union, `via`
    excluded).
  - "Station-Side Redstone": the Schedule editor's redstone-rule output picker offers the
    **union** of `redstone_outputs` across all entry stations (not only entry 1). This is
    editor-only discovery; stations still DEFINE outputs in the Stations tab.
- `docs/operations/download-and-run.md`: augment config is now the in-game `AugmentFilterGUI`
  (old right-click/redstone-torch method superseded); note `/immersiverailroading reload`
  still exists.
- `README.md`: one-line baseline note (MC 1.7.10 / IR 1.11.0).
- `AGENTS.md`: DO NOT auto-edit — list "IR 1.7.10/1.11.0 runtime facts" as needing user
  permission.

---

## 2. Redstone-I/O availability = union of all entry stations (editor)

**Context.** The schedule edit modal edits **only entry 1's** waits + redstone rules
(route_book_editor.lua:2766-2771): `on_submit` writes `wait.groups`/`redstone.rules` to
entry 1 and copies previous entries' wait/redstone for the rest. So "all entries" means the
**option pools** (redstone outputs + scope stations) span every entry's station, not
per-entry editing. This change touches **only** the Schedule editor's redstone-rule output
picker (`refresh_rule_output_options`, used by the `redstone_rules` field) and the
schedule-wide wait-condition scope (§3). It does **NOT** touch the **Stations tab**, where
`STATIONS[id].redstone_outputs` / `detector_ids` are defined. There is no active
per-condition redstone output picker (legacy `condition.redstone` is display-only).

**Rule.** Available redstone outputs = **union** of `STATIONS[id].redstone_outputs` for every
station referenced by an entry (`entry.station`, else route terminal `route.to` via
`entry_destination_station_id`, 1342; `via` excluded).
Example: `entries={{station="2_oil_frack"},{station="1_oil_ref"}}` → editor offers both
stations' outputs.

### 2.1 Editor (`programs/route_book_editor.lua`)
- Add `schedule_entry_station_ids(book, modal)`: iterate `modal.fields` for `key=="entries"`;
  for each `item.value` call `collect_schedule_entry_refs({entries={item.value}})` (809) and
  resolve via `entry_destination_station_id(book, ref.station, ref.route)` (1342); collect
  resolved, de-duplicated station ids (order stable: first appearance).
- Add `available_redstone_ids_for_schedule(book, station_ids)`: merge + sort + de-dup
  `redstone_outputs` keys across the given stations (guard nil station).
- `refresh_rule_output_options` (1390): source options from
  `available_redstone_ids_for_schedule(book, schedule_entry_station_ids(book, modal))`;
  keep the "append current `field.output.value` if absent" behavior so an already-saved
  output stays selectable; fall back to `modal_destination_station_id(book, modal)` only when
  no entry resolves to a station (empty schedule edge case).
- Remove stale comment at 1321–1324 ("outputs ... belong to the schedule's first entry").
- `SCHEDULE_SCOPE_BASE_OPTIONS` (88) and `available_scope_options_for_station` (1365) become
  unused after §3 — remove both (and the two usages at 1367–1368).

**Edge cases.** (a) Two entries reference the same station → de-dup. (b) Entry has only a
route (no `station`) → resolved via `route.to`. (c) Entry `route` unknown/unresolved → skip
that entry's station; union still covers the rest. (d) No resolvable station at all → picker
shows the single-destination fallback (so existing behavior for a 1-entry schedule holds).

### 2.2 Validation (`programs/lib/station_schedule.lua`)
- `validate_condition` (103): add optional 4th param `allowed_outputs` (name→true). In the
  redstone branch (129–149), when `allowed_outputs` is provided check
  `allowed_outputs[output]`, else fall back to
  `route_book.STATIONS[station_id].redstone_outputs` (keeps the public single-condition call
  usable).
- `M.validate` (154): per schedule, before the per-entry loop, build the union of output names
  across all entry stations (`M.resolve_entry_station_id` per entry; skip nil) and pass it to
  both `validate_condition` calls (216, 268).
- **Runtime unchanged** (editor-only limit): a rule referencing a non-active entry's output
  validates OK but the dispatcher only drives the active entry's station outputs, so it won't
  fire at runtime. Documented, not fixed.

---

## 3. Wait-Condition Scope rework (editor-only)

**Context.** For detector condition types only (`passengers`, `cargo_percent`,
`fluid_percent`): the user clicks **Scope** → picks a **station** from the schedule's entry
stations (the ONLY station selector in the schedule) → then picks "all detectors of that
station" (AND) or individual detectors (OR, multi-select). `station-any_detector` is
replaced by the explicit detector-set selection.

### 3.1 Stored scope schema + text forms (decision 1 & 4)
- All detectors: `{station_id="<id>", all_detectors=true}`
- Detector set: `{station_id="<id>", detector_ids={"d1","d2"}}` (sorted, unique; empty set =
  none selected)
- Legacy (read-compat, never written): `"station_all_detectors"` /
  `"station_any_detector"` / `{detector_id="..."}`.

Editor-text (round-trips via the two helpers; this is what the chain field stores):
- all → `"station:<id>:all"` (e.g. `"station:2_oil_frack:all"`)
- set → `"station:<id>:detectors:d1,d2"` (sorted, comma, no spaces)
- legacy strings / `{detector_id}` returned verbatim.

```lua
local function scope_to_editor_text(scope)
  if type(scope) == "table" and type(scope.station_id) == "string" then
    if scope.all_detectors then return ("station:%s:all"):format(scope.station_id) end
    if type(scope.detector_ids) == "table" then
      local ids = {}; for _, d in ipairs(scope.detector_ids) do ids[#ids + 1] = d end
      table.sort(ids)
      return ("station:%s:detectors:%s"):format(scope.station_id, table.concat(ids, ","))
    end
  end
  if scope == "station_all_detectors" or scope == "station_any_detector" then return scope end
  if type(scope) == "table" and type(scope.detector_id) == "string" then return "detector:" .. scope.detector_id end
  return "station_any_detector"
end

local function scope_from_editor_text(text, fallback_station_id)
  text = trim(text)
  local sid, kind, rest = text:match("^station:([^:]*):(all|detectors):?(.*)$")
  if sid and sid ~= "" then
    if kind == "all" then return {station_id = sid, all_detectors = true} end
    if kind == "detectors" then
      local ids = {}
      for id in (rest or ""):gmatch("([^,]+)") do local t = trim(id); if t ~= "" then ids[#ids + 1] = t end end
      table.sort(ids); return {station_id = sid, detector_ids = ids}
    end
  end
  if text == "station_all_detectors" or text == "station_any_detector" then
    return {station_id = fallback_station_id, all_detectors = true}
  end
  if text:match("^detector:") then
    local d = trim(text:sub(#"detector:" + 1)); if d ~= "" then return {detector_id = d} end
  end
  return {station_id = fallback_station_id, all_detectors = true}
end
```
`fallback_station_id` is optional (new text embeds the station). `runtime_condition_from_editor`
keeps `scope_from_editor_text(condition.scope)` (no fallback); `resolve_detector_ids` active-
station fallback covers `nil` `station_id`.

### 3.2 Two-stage scope chooser (decision 5)
`begin_scope_chooser` (1997) — replace the body (currently single `available_scope_options_for_station`
call):
- `station_ids = schedule_entry_station_ids(state.book, state.modal)`; if empty return false.
- Pre-parse current `condition.scope` (via `scope_from_editor_text`) to find its station; set
  `selected` to that station's index in `station_ids`, else 1.
- `field.chooser = {kind="scope", condition_ref={group_index=field.selected_group_index,
  condition_index=field.selected_condition_index}, stage="station", station_id=nil,
  selected_detectors={}, all_selected=false, options=station_ids, selected=selected}`.

`choose_chain_option` (2034) — replace the `if chooser.kind == "scope" then … end` block
(currently 2110–2120):
- `stage == "station"`: `chooser.station_id = chooser.options[chooser.selected]`; preload
  `selected_detectors`/`all_selected` from current `condition.scope` if it names this station;
  set `chooser.options = {"(all detectors)", <detector ids of STATIONS[station_id]...>,
  "(done)"}`, `chooser.stage = "detectors"`, `chooser.selected = 1`; return true.
- `stage == "detectors"`:
  - `chooser.selected == #chooser.options` ("(done)"): build the text — `all_selected` →
    `"station:<id>:all"`; else collect checked detector ids (sorted) →
    `"station:<id>:detectors:..."`; set `condition.scope = text`;
    restore `field.selected_group_index/condition_index`; `field.chooser = nil`; return true.
  - `chooser.selected == 1` ("(all detectors)"): toggle `all_selected` (when enabling, clear
    `selected_detectors`).
  - else: toggle `chooser.selected_detectors[option]`; `all_selected = false`.
  - return true (do **not** auto-close except on "(done)").

`build_chain_chooser_rows` (1437): for `chooser.kind == "scope"`, set the section label from
`chooser.stage` ("Choose Scope Station" / "Choose Detectors"); add `row.checked` per option in
the detector stage: `"(all detectors)"` → `chooser.all_selected`; `"(done)"` → `nil`; else
`chooser.selected_detectors[option] == true`.

**Rendering fix (required for multi-select).** `render_modal` `chain_chooser` branch
(line 2355–2357) currently marks `[x]` from `option_index == chooser.selected`. Change the
marker to: if `row.checked ~= nil` then `row.checked and "[x]" or "[ ]"`, else the existing
`selected`-based marker. This keeps cursor navigation (`>`) separate from the toggle checkbox.

No back-navigation: closing and re-opening Scope restarts at the station stage.

### 3.3 `station_schedule.lua` resolution/validation (keep dispatcher working)
Change `resolve_detector_ids` signature `(station, condition)` →
`(route_book, station, condition)` and update the only caller at 338 to
`resolve_detector_ids(session.route_book, session.station, condition)`:

```lua
local function resolve_detector_ids(route_book, station, condition)
  local scope = condition.scope
  if type(scope) == "table" and type(scope.station_id) == "string" then
    local st = route_book and route_book.STATIONS and route_book.STATIONS[scope.station_id]
    if scope.all_detectors then return st and st.detector_ids or {} end
    if type(scope.detector_ids) == "table" then return scope.detector_ids end
  end
  if type(scope) == "table" and type(scope.detector_id) == "string" then
    return {scope.detector_id}
  end
  -- legacy strings and any scope without an explicit station -> active entry station
  if station then return station.detector_ids or {} end
  return {}
end
```

`evaluate_condition` (331): AND mode must also cover the new table form. Replace the
`condition.scope == "station_all_detectors"` test with:
```lua
local and_mode = (condition.scope == "station_all_detectors")
  or (type(condition.scope) == "table" and condition.scope.all_detectors == true)
```
Keep the existing else-branch (OR across the resolved set). Legacy `station_any_detector` OR
behavior preserved for read-compat.

`validate_condition` scope check (121–124) — accept the new table form and allow `nil`
`station_id` (decision 4):
```lua
local scope = condition.scope
local scope_ok = false
if scope == "station_any_detector" or scope == "station_all_detectors" then
  scope_ok = true
elseif type(scope) == "table" then
  if scope.all_detectors == true then
    scope_ok = true
  elseif type(scope.detector_ids) == "table" then
    scope_ok = true
    for _, d in ipairs(scope.detector_ids) do
      if type(d) ~= "string" then scope_ok = false; break end
    end
  elseif type(scope.detector_id) == "string" then
    scope_ok = true
  end
  -- station_id may be nil for legacy-normalized scopes; resolution falls back to the
  -- active station at runtime, so a missing station_id is not an error here.
end
if not scope_ok then
  errors[#errors + 1] = ("%s requires station_any_detector, station_all_detectors, "
    .. "{station_id, all_detectors=true}, {station_id, detector_ids={...}}, or {detector_id=...} scope"):format(condition.type)
end
```

### 3.4 Migration / legacy data flow
Old saved schedules may store `condition.scope` as a string (`"station_any_detector"` etc.)
or `{detector_id=...}`. On **edit**, `make_chain_condition` (419) runs
`scope_to_editor_text(stored)` → a string in the chain field (legacy strings pass through
verbatim; `{detector_id}` → `"detector:x"`). On **save**, `runtime_condition_from_editor`
(666) parses the string → table. Legacy `"station_any_detector"`/`"station_all_detectors"`
normalize to `{station_id=fallback, all_detectors=true}` (fallback = first entry station via
`schedule_entry_station_ids[1]` if a fallback is threaded, else `nil` — both validated and
runtime-resolved correctly per §3.3). No separate migration pass is required; the existing
load/save path handles it.

**Edge cases.** (a) Condition scope references a station the user later deletes from `entries`
→ at edit time the chooser still parses the stored station (it's embedded in the text); on
re-save it persists as-is (validation uses the union which no longer includes it, but the
rule's output/scope is still valid because `resolve_detector_ids` looks the station up in
`route_book.STATIONS`, not in entries). (b) Entry resolves only via route `to` (no
`entry.station`) → still included in the union/scope list. (c) Detector list changes between
edits → `(all detectors)` re-reads `STATIONS[station_id].detector_ids` live. (d) Empty
detector set chosen → writes `detector_ids={}`; `resolve_detector_ids` returns `{}` → condition
never completes (intentional "select at least one" via "(done)" with none checked = no
detectors).

---

## Affected files
- `programs/route_book_editor.lua` — §2 (union helpers) & §3 (two-stage/multi-select scope,
  `scope_to_editor_text`/`scope_from_editor_text`, rendering marker fix at 2356, help text at
  2991/3004).
- `programs/lib/station_schedule.lua` — §2 `allowed_outputs` param; §3 `resolve_detector_ids`
  signature + AND-mode; scope validation allowing `nil` `station_id`.
- `docs/runtime.md`, `docs/station-schedules.md`, `docs/operations/download-and-run.md`,
  `README.md` — §1. `AGENTS.md` — listed as user-permission TODO only.
- Preview tests (update, see §Validation):
  `tests/previews/route_book_editor_emulator.lua` (~97, ~128),
  `tests/previews/station_schedule_preview.lua` (~30, ~102),
  `tests/previews/term_ui_preview.lua` (~294, ~411, **~456-462**).

## Validation
- `luac -p` on edited Lua files.
- Preview updates:
  - `term_ui_preview.lua:456-462`: the `assert(saw_station_any == true, ...)` assertion
    **must change** — the editor no longer offers `station_any_detector`. Assert instead that
    the scope chooser lists the schedule's entry station ids (or remove the assertion).
  - `route_book_editor_emulator.lua:128`: keep legacy-string parsing working; add a
    round-trip assertion `scope_to_editor_text({station_id="1_oil_ref", detector_ids={"loader"}})`
    == `"station:1_oil_ref:detectors:loader"`.
  - `station_schedule_preview.lua` / `term_ui_preview.lua`: keep legacy `"station_any_detector"`
    validating; add a case `condition.scope = {station_id="x", detector_ids={"a","b"}}`
    validates and resolves to `{"a","b"}`; add a case with `station_id=nil, all_detectors=true`
    still validates (legacy-normalized path).
  - Add a preview: (a) schedule redstone options == union of entry stations; (b) scope
    chooser Level 1 lists entry stations; (c) station → toggle detectors → "(done)" writes
    `"station:<id>:detectors:..."`; (d) legacy scope values still validate.
- Manual: open `route_book_editor.lua`, edit a multi-entry schedule; confirm the redstone-rule
  output picker shows all entry stations' outputs and the Scope flow picks station → detector
  set; confirm the Stations tab I/O editing is unaffected.

## Risks (all closed)
- Cross-entry redstone output validates but does not fire at runtime → accepted editor-only
  limitation (decision 6), documented.
- Legacy scope with `nil` `station_id` → accepted by validation (decision 4) and resolved via
  active station; no migration pass needed.
- No change to `station_dispatch.lua` runtime → no regression to in-world train behavior.
