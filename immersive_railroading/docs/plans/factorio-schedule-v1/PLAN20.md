# `route_book_editor`: Redstone-I/O im Editor anlegen und im Schedule-Editor nutzbar machen

## Summary
Der Editor soll Redstone-I/Os nicht länger nur anzeigen, sondern **vollständig anlegen und bearbeiten** können. Damit das Feature praktisch nutzbar ist, reicht es nicht, nur `station.redstone_outputs` editierbar zu machen: Die bestehende Schedule-UI kann aktuell nur den **ersten Entry** und dessen **erste Wait-Condition** bearbeiten. Deshalb muss das Update zwei zusammenhängende Dinge liefern:

1. **Stationen** bekommen einen echten I/O-Editor für `redstone_outputs`.
2. **Schedules** bekommen in ihrer bestehenden vereinfachten Edit-Maske die Möglichkeit, den ersten Wait-Condition-Eintrag optional mit einem dieser Outputs zu verknüpfen.

Bewusste Scope-Grenze:
- **Kein** generischer Voll-Editor für beliebig viele Schedule-Entries, Wait-Gruppen und Conditions.
- Stattdessen ein sauberer, vollständiger Ausbau des **bereits existierenden vereinfachten Schedule-Editors**:
  - `route`
  - `seconds`
  - `cyclic`
  - neu: `redstone.output`
  - neu: `redstone.mode`

Damit ist das Feature sofort benutzbar, ohne eine zweite Großbaustelle aufzumachen.

## Verifizierte Ist-Lage
### 1. Stationen speichern Outputs bereits, aber nur read-only
`Add Station` erzeugt schon:
```lua
current_state.book.STATIONS[values.id] = {
  display_name = values.name ~= "" and values.name or values.id,
  x = tonumber(values.x) or 0,
  y = tonumber(values.y) or 64,
  z = tonumber(values.z) or 0,
  detector_ids = collect_detector_ids(values),
  redstone_outputs = {},
}
```

`Edit Station` lässt `redstone_outputs` unberührt, rendert sie aber nur in der Detailansicht:
```lua
detail_lines[#detail_lines + 1] = ("  %s -> %s strength=%s pulse_ticks=%s active_high=%s"):format(...)
```

### 2. Schedule-Editor ist heute absichtlich vereinfacht
Aktuell bearbeitet `Edit Schedule` nur:
```lua
make_text_field({key = "route", label = "First Route", ...})
make_text_field({key = "seconds", label = "Wait Seconds", ...})
make_text_field({key = "cyclic", label = "Cyclic", ...})
```

Und speichert nur den ersten Entry / die erste Condition:
```lua
schedule.entries[1] = {
  route = values.route,
  wait = {
    groups = {
      {
        {
          type = "time_passed",
          seconds = tonumber(values.seconds) or 0,
        },
      },
    },
  },
}
```

### 3. Datenmodell für Redstone ist schon definiert
`station.redstone_outputs` wird in [`lib/redstone_io.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/redstone_io.lua) validiert und verwendet:

```lua
redstone_outputs = {
  loader = {
    side = "north",
    strength = 15,
    pulse_ticks = 20,
    active_high = true,
  },
}
```

`condition.redstone` ist in [`lib/station_schedule.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/station_schedule.lua) bereits Teil des Wait-Modells:

```lua
redstone = {
  output = "loader",
  mode = "while_pending" or "on_departure_pulse",
}
```

Das heißt: Das Runtime-Modell ist bereits komplett vorhanden. Es fehlt nur die Editoroberfläche.

## Implementierungsänderungen
### A. Neues Modal-Feld für wiederholbare Objektgruppen
Die bestehende Modal-Infrastruktur unterstützt aktuell:
- `text`
- `repeatable_text`

Für `redstone_outputs` reicht `repeatable_text` nicht, weil ein Output mehrere Unterfelder hat:
- Name
- Side
- Strength
- Pulse Ticks
- Active High

Deshalb ein neues Feldkind einführen:

```lua
{
  kind = "repeatable_group",
  key = "redstone_outputs",
  label = "Redstone I/Os",
  add_label = "+",
  items = {
    {
      fields = {
        { key = "name", label = "Name", value = "loader", cursor = 7, scroll_x = 0 },
        { key = "side", label = "Side", value = "north", cursor = 6, scroll_x = 0 },
        { key = "strength", label = "Strength", value = "15", cursor = 3, scroll_x = 0 },
        { key = "pulse_ticks", label = "Pulse", value = "20", cursor = 3, scroll_x = 0 },
        { key = "active_high", label = "Active High", value = "true", cursor = 5, scroll_x = 0 },
      },
    },
  },
  min_items = 0,
}
```

Neue Helper in [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua):
- `make_repeatable_group_field(spec)`
- `redstone_output_rows_from_station(station)`
- `collect_redstone_outputs(values)`
- `build_group_item_fields(spec, item)`
- `group_field_by_key(item, key)`

Exakte Builder-Funktion:

```lua
local function build_group_item_fields(defs, item)
  local fields = {}
  for _, def in ipairs(defs or {}) do
    local value = tostring(item and item[def.key] or def.default or "")
    fields[#fields + 1] = {
      key = def.key,
      label = def.label,
      value = value,
      cursor = #value + 1,
      scroll_x = 0,
    }
  end
  return fields
end

local function make_repeatable_group_field(spec)
  local items = {}
  for _, item in ipairs(spec.items or {}) do
    items[#items + 1] = {
      fields = build_group_item_fields(spec.item_fields, item),
    }
  end
  return {
    kind = "repeatable_group",
    key = spec.key,
    label = spec.label,
    add_label = spec.add_label or "+",
    item_fields = spec.item_fields,
    items = items,
    min_items = spec.min_items or 0,
  }
end
```

### B. Redstone-Output-Daten zwischen UI und Route Book transformieren
Neue Helper:

```lua
local function redstone_output_rows_from_station(station)
  local rows = {}
  local names = sorted_keys(station and station.redstone_outputs or {})
  for _, name in ipairs(names) do
    local output = station.redstone_outputs[name] or {}
    rows[#rows + 1] = {
      name = name,
      side = tostring(output.side or ""),
      strength = tostring(output.strength ~= nil and output.strength or 15),
      pulse_ticks = tostring(output.pulse_ticks ~= nil and output.pulse_ticks or 20),
      active_high = tostring(output.active_high ~= false),
    }
  end
  return rows
end

local function collect_redstone_outputs(values)
  local outputs = {}
  for _, item in ipairs(values.redstone_outputs or {}) do
    local name = trim(item.name)
    if name ~= "" then
      outputs[name] = {
        side = trim(item.side),
        strength = tonumber(item.strength) or 15,
        pulse_ticks = tonumber(item.pulse_ticks) or 20,
        active_high = trim(item.active_high):lower() ~= "false",
      }
    end
  end
  return outputs
end
```

Wichtig:
- Leere `name`-Einträge werden verworfen.
- `active_high` interpretiert nur `"false"` als `false`, alles andere als `true`.
- Doppelte Namen: **letzter Eintrag gewinnt nicht stillschweigend**, sondern im Submit muss ein Fehler kommen.

Deshalb zusätzlicher Validator:
```lua
local function validate_redstone_output_rows(rows)
  local seen = {}
  for index, item in ipairs(rows or {}) do
    local name = trim(item.name)
    if name ~= "" then
      if seen[name] then
        return false, ("Redstone I/O name duplicated: %s"):format(name)
      end
      seen[name] = true
    end
  end
  return true
end
```

### C. Modal-Zeilenmodell auf Gruppen erweitern
`build_modal_rows(modal)` muss neben `text` und `repeatable_text` jetzt `repeatable_group` unterstützen.

Neues Row-Modell:
```lua
{
  kind = "group_item_field",
  field_index = field_index,
  item_index = item_index,
  subfield_index = subfield_index,
  field = field,
  item = item,
  subfield = subfield,
}
```

Und wie bisher:
```lua
{
  kind = "group_add",
  field_index = field_index,
  field = field,
}
```

Beispiel für einen I/O-Eintrag:
- `Redstone I/Os [1] Name: loader`
- `                 Side: north`
- `                 Strength: 15`
- `                 Pulse: 20`
- `                 Active High: true`
- rechts auf der ersten Zeile dieses Blocks: `[x]`
- danach `[+]`

Neue oder angepasste Helper:
- `build_modal_rows(modal)` erweitert
- `current_modal_text_cell(state)` muss bei `group_item_field` das aktuelle Subfield zurückgeben
- `insert_repeatable_item(...)` für `repeatable_group` verallgemeinern oder neue Funktion:
  - `insert_repeatable_group_item(modal, field_index, item_index)`
- `remove_repeatable_item(...)` für `repeatable_group` verallgemeinern

### D. Rendering des Gruppenfelds
In `render_modal(...)` neue Zweige ergänzen.

Für `group_item_field` rendern:
- erste Subfield-Zeile eines Items:
```lua
("Redstone I/Os [%d] %s: %s"):format(item_index, subfield.label, display)
```
- weitere Zeilen eingerückt auf Labelbreite:
```lua
("                 %s: %s"):format(subfield.label, display)
```

Konkrete Funktion:
```lua
local function group_item_field_visible_value(field, item_index, subfield, available, show_cursor, first_in_item)
  local head = first_in_item
    and ("%s [%d] %s: "):format(field.label, item_index, subfield.label)
    or (string.rep(" ", #tostring(field.label or "")) .. "     " .. subfield.label .. ": ")
  local viewport = math.max(available - #head - 1, 1)
  local display, next_scroll_x = inline_view(subfield.value or "", subfield.cursor, subfield.scroll_x, viewport, show_cursor)
  subfield.scroll_x = next_scroll_x
  return head .. display
end
```

Remove-Target:
- nur auf der ersten Subfield-Zeile eines Items anzeigen
- ID:
```lua
("modal:group:remove:%d:%d"):format(field_index, item_index)
```

Add-Target:
```lua
("modal:group:add:%d"):format(field_index)
```

### E. `collect_modal_values(...)` auf Gruppen erweitern
Aktuell gibt `repeatable_text` Arrays von Strings zurück. Für `repeatable_group` muss ein Array von Objekten zurückgegeben werden:

```lua
local function collect_modal_values(modal)
  local values = {}
  for _, field in ipairs(modal.fields or {}) do
    if field.kind == "repeatable_text" then
      local items = {}
      for _, item in ipairs(field.items or {}) do
        items[#items + 1] = item.value
      end
      values[field.key] = items
    elseif field.kind == "repeatable_group" then
      local items = {}
      for _, item in ipairs(field.items or {}) do
        local out = {}
        for _, subfield in ipairs(item.fields or {}) do
          out[subfield.key] = subfield.value
        end
        items[#items + 1] = out
      end
      values[field.key] = items
    else
      values[field.key] = field.value
    end
  end
  return values
end
```

### F. Station-Editor um Redstone-I/O-Feld erweitern
#### `Add Station`
Die `fields` erweitern von:
```lua
make_repeatable_text_field({key = "detector_ids", label = "Detector IDs", values = {""}, min_items = 1}),
```
zu:
```lua
make_repeatable_text_field({key = "detector_ids", label = "Detector IDs", values = {""}, min_items = 1}),
make_repeatable_group_field({
  key = "redstone_outputs",
  label = "Redstone I/Os",
  min_items = 0,
  item_fields = {
    {key = "name", label = "Name", default = ""},
    {key = "side", label = "Side", default = "north"},
    {key = "strength", label = "Strength", default = "15"},
    {key = "pulse_ticks", label = "Pulse", default = "20"},
    {key = "active_high", label = "Active High", default = "true"},
  },
  items = {},
}),
```

`on_submit` ergänzen:
```lua
local outputs_ok, outputs_error = validate_redstone_output_rows(values.redstone_outputs)
if not outputs_ok then
  return false, outputs_error
end
...
redstone_outputs = collect_redstone_outputs(values),
```

#### `Edit Station`
Gleiches Feld ergänzen, aber mit vorhandenen Daten:
```lua
make_repeatable_group_field({
  key = "redstone_outputs",
  label = "Redstone I/Os",
  min_items = 0,
  item_fields = {
    {key = "name", label = "Name", default = ""},
    {key = "side", label = "Side", default = "north"},
    {key = "strength", label = "Strength", default = "15"},
    {key = "pulse_ticks", label = "Pulse", default = "20"},
    {key = "active_high", label = "Active High", default = "true"},
  },
  items = redstone_output_rows_from_station(station),
}),
```

Submit:
```lua
local outputs_ok, outputs_error = validate_redstone_output_rows(values.redstone_outputs)
if not outputs_ok then
  return false, outputs_error
end
...
station.redstone_outputs = collect_redstone_outputs(values)
```

### G. Schedule-Editor um Redstone-Bindung erweitern
Da die bestehende Schedule-UI nur den ersten Entry/erste Condition bearbeitet, wird genau dort erweitert.

#### `Add Schedule`
Felder ergänzen:
```lua
make_text_field({key = "redstone_output", label = "Redstone Output", value = ""}),
make_text_field({key = "redstone_mode", label = "Redstone Mode", value = "while_pending"}),
```

Submit-Logik:
```lua
local first_station_id = values.route ~= "" and current_state.book.ROUTES[values.route]
  and current_state.book.ROUTES[values.route].waypoints
  and current_state.book.ROUTES[values.route].waypoints[#current_state.book.ROUTES[values.route].waypoints]

local redstone
if trim(values.redstone_output) ~= "" then
  redstone = {
    output = trim(values.redstone_output),
    mode = trim(values.redstone_mode) ~= "" and trim(values.redstone_mode) or "while_pending",
  }
end
```

Und dann in die Condition:
```lua
{
  type = "time_passed",
  seconds = tonumber(values.seconds) or 0,
  redstone = redstone,
}
```

Wichtig:
- Keine Routen-/Stationsauflösung im Editor erzwingen.
- Validation bleibt die Quelle der Wahrheit.
- Aber lokale Mini-Prüfung einbauen:
```lua
if trim(values.redstone_output) ~= "" then
  local mode = trim(values.redstone_mode)
  if mode ~= "while_pending" and mode ~= "on_departure_pulse" then
    return false, "Redstone Mode must be while_pending or on_departure_pulse"
  end
end
```

#### `Edit Schedule`
Bestehende Werte lesen aus:
```lua
local first_condition =
  schedule.entries[1]
  and schedule.entries[1].wait
  and schedule.entries[1].wait.groups
  and schedule.entries[1].wait.groups[1]
  and schedule.entries[1].wait.groups[1][1]
```

Neue Felder:
```lua
make_text_field({
  key = "redstone_output",
  label = "Redstone Output",
  value = tostring(first_condition and first_condition.redstone and first_condition.redstone.output or ""),
}),
make_text_field({
  key = "redstone_mode",
  label = "Redstone Mode",
  value = tostring(first_condition and first_condition.redstone and first_condition.redstone.mode or "while_pending"),
}),
```

Submit:
```lua
local redstone = nil
if trim(values.redstone_output) ~= "" then
  local mode = trim(values.redstone_mode)
  if mode ~= "while_pending" and mode ~= "on_departure_pulse" then
    return false, "Redstone Mode must be while_pending or on_departure_pulse"
  end
  redstone = {
    output = trim(values.redstone_output),
    mode = mode,
  }
end

schedule.entries[1] = {
  route = values.route,
  wait = {
    groups = {
      {
        {
          type = "time_passed",
          seconds = tonumber(values.seconds) or 0,
          redstone = redstone,
        },
      },
    },
  },
}
```

### H. Schedule- und Station-Details aktualisieren
#### Station-Details
Die bereits vorhandene read-only Ausgabe bleibt, wird aber nach dem Editieren natürlich die neuen Werte zeigen. Keine weitere Logik nötig.

#### Schedule Wait Conditions
Die vorhandene Zeile:
```lua
wait_lines[#wait_lines + 1] = ("redstone %s %s"):format(...)
```
bleibt richtig und ist nun erstmals direkt aus dem Editor befüllbar.

### I. Save / Validate-Hinweise anpassen
Die Zeile:
```lua
"Editor note: station redstone outputs are currently read-only here."
```
muss entfernt oder ersetzt werden.

Neue Version:
```lua
save_lines[#save_lines + 1] = "Editor supports station redstone outputs and first-entry schedule redstone binding."
save_lines[#save_lines + 1] = "Advanced multi-entry/group/condition editing is still manual."
```

Damit ist die UI-Aussage wieder wahr.

## Testplan
### `route_book_editor_emulator.lua`
Neue oder angepasste End-to-End-Fälle:

1. `add station supports redstone outputs`
- Station hinzufügen
- im Modal einen `Redstone I/Os`-Block anlegen
- Submit
- `state.book.STATIONS[id].redstone_outputs.loader.side == "north"`

2. `edit station persists multiple redstone outputs`
- Station mit 2 Outputs öffnen
- Werte ändern
- Submit
- beide Outputs bleiben erhalten und aktualisiert

3. `duplicate redstone output names rejected`
- zwei I/Os mit gleichem Namen
- Submit schlägt mit verständlicher Meldung fehl

4. `edit schedule stores first-condition redstone binding`
- Schedule öffnen
- `redstone_output = "loader"`
- `redstone_mode = "while_pending"`
- Submit
- `schedule.entries[1].wait.groups[1][1].redstone.output == "loader"`

5. `invalid redstone mode rejected`
- `redstone_mode = "bogus"`
- Submit schlägt mit verständlicher Meldung fehl

6. `station details render configured outputs`
- Detailansicht zeigt `loader -> north ...`

7. `schedule wait panel renders redstone binding`
- Wait-Panel zeigt `redstone loader while_pending`

8. `save tab no longer claims outputs are read-only`
- alte Zeile darf nicht mehr erscheinen
- neue Scope-Hinweise erscheinen

### Bestehende Tests beibehalten
- Repeatable detector IDs
- Repeatable waypoints
- Wrap-/Scroll-Tests
- Cursor nur auf aktiver Zeile
- Emulator-Lifecycle-/Leak-Tests

## Assumptions
- Ziel ist ein **benutzbares** Redstone-I/O-Feature im bestehenden V1-Editor, nicht ein vollständiger DSL-Editor für beliebige Schedule-Strukturen.
- Deshalb wird nur der bereits vorhandene vereinfachte Schedule-Editor erweitert.
- `redstone_outputs` bleiben stationbezogen.
- Schedule-Redstone-Bindings bleiben auf den ersten Entry / die erste Condition der bestehenden UI beschränkt.
- Seitennamen (`north`, `south`, `east`, `west`, `top`, `bottom`, `front`, `back`, `left`, `right`) werden als Freitext eingegeben und weiterhin durch die bestehende Validation geprüft; es wird in diesem Patch kein Dropdown-/Enum-Widget gebaut.
