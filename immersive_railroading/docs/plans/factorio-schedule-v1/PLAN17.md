# `route_book_editor`: Wiederholbare Detector-/Waypoint-Felder Mit Scrollbarem Modal und klare Fahrplan-Hilfe

## Summary
Der nächste Patch erweitert den Editor so, dass Stationen mehrere `detector_ids` und Routen mehrere `waypoints` **als echte wiederholbare Eingabefelder** bearbeiten können, statt als einzelnes Freitextfeld. Die UI bekommt dafür eine kleine generische Repeatable-Field-Modal-Logik mit `+`-Zeile, optionalem Entfernen einzelner Zeilen und vertikalem Scrollen im Dialog.

Gleichzeitig wird die aktuelle Betriebsweise für Fahrpläne im UI sichtbar gemacht: Es gibt derzeit **keine persistente Zug-zu-Fahrplan-Zuweisung** im Route Book. Ein Fahrplan wird zur Laufzeit über [`station_dispatch.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/station_dispatch.lua) gestartet und läuft gegen den aktuell verfügbaren `component.ir_remote_control`. Diese Information soll im Save/Validate-Tab als kurze Hilfe erscheinen.

## Zielverhalten
- `Stations -> Add/Edit`:
  - `Detector IDs` ist kein einzelnes Textfeld mehr.
  - Es rendert als Liste einzelner Zeilen:
    - `Detector IDs [1]: 1`
    - `             [2]: 2`
    - `             [+]`
- `Routes -> Add/Edit`:
  - `Waypoints` ist kein einzelnes Textfeld mehr.
  - Es rendert als Liste einzelner Zeilen:
    - `Waypoints [1]: 427,64,-148`
    - `          [2]: 398,64,-210`
    - `          [+]`
- Das Modal wächst nur bis zu einer festen Maximalhöhe; bei mehr Zeilen wird im Modal selbst gescrollt.
- Bereits kaputte/alte Route-Strings wie `"[427,64,-148],[398,64,-210]"` werden beim Öffnen **in zwei Waypoint-Zeilen aufgespalten**, damit bestehende Daten reparierbar sind.
- Im Save/Validate-Tab steht eine kurze Laufzeithilfe:
  - `Run schedule: station_dispatch run <schedule>`
  - `Run route directly: train_controller route <route>`
  - optional dritter Satz: `Schedules are not assigned persistently; they run on the active ir_remote_control train.`

## Implementierungsänderungen
### 1. Modal-Datenmodell in [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua) erweitern
Die bestehende flache Modalstruktur:
```lua
state.modal = {
  title = spec.title,
  fields = fields,
  active_index = 1,
  on_submit = spec.on_submit,
}
```
wird auf ein row-basiertes Modell erweitert:
```lua
state.modal = {
  title = spec.title,
  fields = fields,
  active_row = 1,
  scroll_y = 0,
  on_submit = spec.on_submit,
}
```

Feldtypen:
```lua
-- normales Einzelfeld
{
  kind = "text",
  key = "name",
  label = "Name",
  value = "Station 1",
  cursor = 10,
  scroll_x = 0,
}

-- wiederholbares Feld
{
  kind = "repeatable_text",
  key = "detector_ids",
  label = "Detector IDs",
  add_label = "+",
  item_label = "Detector IDs",
  items = {
    { value = "1", cursor = 2, scroll_x = 0 },
    { value = "2", cursor = 2, scroll_x = 0 },
  },
  min_items = 1,
}
```

Pflicht-Helper:
- `make_text_field(spec)`
- `make_repeatable_text_field(spec)`
- `build_modal_rows(modal)`
- `current_modal_row(state)`
- `current_modal_text_cell(state)`
- `move_modal_row(state, step)`
- `ensure_modal_row_visible(modal, body_height)`
- `insert_repeatable_item(modal, field_index, item_index)`
- `remove_repeatable_item(modal, field_index, item_index)`
- `collect_modal_values(modal)`

`collect_modal_values(modal)` soll für `repeatable_text` **Arrays** zurückgeben:
```lua
values.detector_ids = {"1", "2"}
values.waypoints = {"427,64,-148", "398,64,-210"}
```

### 2. Rendering des Modals auf sichtbare Zeilen umstellen
Die bisherige Schleife in `render_modal(...)` über `modal.fields` wird ersetzt durch:
```lua
local rows = build_modal_rows(modal)
local body_height = height - 5
ensure_modal_row_visible(modal, body_height)
for visible_index = 1, body_height do
  local row = rows[modal.scroll_y + visible_index]
  ...
end
```

Exakte Row-Typen aus `build_modal_rows(modal)`:
```lua
{ kind = "text", field_index = 1, field = field }
{ kind = "repeat_item", field_index = 5, item_index = 1, field = field, item = item }
{ kind = "repeat_add", field_index = 5, field = field }
```

Renderregeln:
- `text`: wie bisher `Label: value|`
- `repeat_item`:
  - erste Zeile: `Waypoints [1]: 427,64,-148|`
  - weitere Zeilen: eingerückt, gleiche Spaltenflucht
  - wenn `#field.items > field.min_items`, rechts ein kleines `[x]`-Target rendern
- `repeat_add`:
  - rendern als `            [+]`
  - klickbar
  - per `Enter` aktivierbar, wenn diese Zeile selektiert ist
- Buttons `Confirm`/`Cancel` bleiben unten fixiert und scrollen nicht mit.

Konkrete Target-IDs:
```lua
modal:row:<row_index>
modal:repeat:add:<field_index>
modal:repeat:remove:<field_index>:<item_index>
modal:confirm
modal:cancel
```

### 3. Keyboard-/Scroll-Verhalten des Modals
`KEY` ergänzen:
```lua
up = 200,
down = 208,
```

`handle_key_down(...)` für offene Modals anpassen:
- `Up` / `Down`:
  - wechseln zwischen Modal-Zeilen, nicht zwischen Tabs/Listen
- `Left` / `Right` / `Home` / `End` / `Backspace` / `Delete`:
  - bearbeiten nur die aktive Textzelle
- `Tab`:
  - springt zur nächsten **editierbaren** Zeile
  - `repeat_add`-Zeilen werden von `Tab` übersprungen
- `Enter`:
  - auf `repeat_add` -> neue leere Item-Zeile einfügen und fokussieren
  - auf normaler Text-/Repeat-Zeile -> nächste editierbare Zeile
  - wenn keine weitere editierbare Zeile existiert -> `submit_modal(state)`
- `Delete` oder `Backspace` auf leerer `repeat_item`-Zeile:
  - wenn `#field.items > field.min_items`, aktuelle Zeile entfernen
- `Esc`:
  - unverändert `close_modal(state, "Canceled")`

`handle_scroll(state, direction)`:
- wenn `state.modal` aktiv ist:
  - nicht die Hintergrundliste scrollen
  - stattdessen `modal.scroll_y` innerhalb der Modalzeilen bewegen
- nur wenn kein Modal offen ist, das bisherige Listen-Scrolling beibehalten

### 4. Klickverhalten im Modal
`handle_click(...)` für Modals erweitern:
- Klick auf `modal:row:*`:
  - `state.modal.active_row = row_index`
- Klick auf `modal:repeat:add:*`:
  - `insert_repeatable_item(...)`
  - neue Zeile aktivieren
- Klick auf `modal:repeat:remove:*`:
  - `remove_repeatable_item(...)`
  - Fokus auf sinnvolle Nachbarzeile setzen
- `modal:confirm` / `modal:cancel` unverändert

### 5. Station- und Route-Editor auf Repeatable-Felder umstellen
#### Stationen
In `open_action_modal(...)` bei `Add Station` und `Edit Station`:
- bisher:
```lua
{key = "detector_ids", label = "Detector IDs", value = ...}
```
- neu:
```lua
make_repeatable_text_field({
  key = "detector_ids",
  label = "Detector IDs",
  values = station and station.detector_ids or {},
  min_items = 1,
})
```

Submit-Regel:
```lua
local function collect_detector_ids(values)
  local out = {}
  for _, raw in ipairs(values.detector_ids or {}) do
    local trimmed = tostring(raw or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed ~= "" then
      out[#out + 1] = trimmed
    end
  end
  return out
end
```

Wichtig:
- Für `detector_ids` **nicht mehr** `parse_waypoints(...)` verwenden.
- `station.detector_ids` muss direkt ein String-Array bleiben.

#### Routen
In `Add Route` und `Edit Route`:
- bisher:
```lua
{key = "waypoints", label = "Waypoints", value = table.concat(..., ";")}
```
- neu:
```lua
make_repeatable_text_field({
  key = "waypoints",
  label = "Waypoints",
  values = route and waypoint_rows_from_route(route.waypoints) or {},
  min_items = 1,
})
```

Neue Helper:
```lua
local function split_legacy_waypoint_string(raw)
  -- "[427,64,-148],[398,64,-210]" -> {"427,64,-148", "398,64,-210"}
end

local function waypoint_rows_from_route(waypoints)
  -- wandelt route.waypoints in editierbare Stringzeilen um
end

local function collect_waypoints(values)
  -- {"427,64,-148", "398,64,-210"} -> { {x=427,y=64,z=-148}, {x=398,y=64,z=-210} }
  -- nicht-koordinatenartige Zeilen bleiben Strings
end
```

Exakte Parsing-Regel für `collect_waypoints(values)`:
- trimmen
- wenn Zeile `^%[?%s*([^,%]]+)%s*,%s*([^,%]]+)%s*,%s*([^,%]]+)%s*%]?$` matcht:
  - `x = tonumber(a)`, `y = tonumber(b)`, `z = tonumber(c)`
  - nur wenn alle drei numerisch sind -> `{x=x,y=y,z=z}`
  - sonst String behalten
- leere Zeilen verwerfen

Legacy-Reparatur:
- Wenn ein vorhandener String mehrere Klammergruppen `%b[]` enthält, jede Gruppe als eigener Waypoint
- Sonst Eintrag 1:1 übernehmen

### 6. Save/Validate-Tab um kurze Laufzeit-Hilfe ergänzen
Im `Save / Validate`-Tab unterhalb des Validation-Blocks zusätzliche, feste Zeilen rendern:
```lua
Run schedule: station_dispatch run <schedule>
Run route:    train_controller route <route>
Schedules run on the active ir_remote_control train.
```

Das beantwortet die aktuelle Nutzerfrage direkt im Programm.

Wichtig:
- **Keine** neue persistente Zug-zu-Schedule-Zuweisung implementieren.
- Das wäre eine separate Funktion und bleibt für diesen Patch ausdrücklich außerhalb des Scopes.

## Tests
### `route_book_editor_emulator.lua`
Neue End-to-End-Fälle:
- `edit station modal supports multiple detector ids`
  - Station-Edit öffnen
  - `Detector IDs [1]` vorhanden
  - `Enter` oder Klick auf `[+]`
  - zweite Zeile erscheint
  - Submit speichert `{"1","2"}`
  - Save/Validate meldet **keinen** kombinierten `unknown detector_id 1, 2`-Fehler mehr
- `edit route modal supports multiple waypoints`
  - Route-Edit öffnen
  - `[+]` fügt zweite Waypoint-Zeile hinzu
  - Submit speichert zwei getrennte Waypoints
  - Detailansicht zeigt `[1] ...` und `[2] ...`
- `legacy combined bracket waypoint string is split into multiple modal rows`
  - vorhandene Route mit `"[427,64,-148],[398,64,-210]"` öffnen
  - Modal zeigt zwei Waypoint-Zeilen statt einer kaputten Gesamtzeile
- `modal scroll works when repeatable rows exceed dialog height`
  - viele Detector IDs / Waypoints
  - `scroll` verschiebt Modalinhalt
  - `Confirm`/`Cancel` bleiben sichtbar
- `repeatable row remove works`
  - zweite Zeile hinzufügen, dann entfernen
  - Fokus bleibt stabil

### `term_ui_preview.lua`
Neue Unit-/Helper-Tests:
- `build_modal_rows(...)` flacht `text` und `repeatable_text` korrekt zu Zeilen ab
- `ensure_modal_row_visible(...)` setzt `scroll_y` korrekt
- `collect_waypoints(...)` parst:
  - `427,64,-148`
  - `[427,64,-148]`
  - `"[427,64,-148],[398,64,-210]"` via Split-Helper
- `collect_detector_ids(...)` entfernt Leerzeilen und trimmt sauber

## Current Schedule Assignment
Aktueller Stand im Code:
- Ein Fahrplan wird nicht im Editor “einem Zug zugewiesen”.
- Stattdessen startet [`station_dispatch.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/station_dispatch.lua) einen Schedule explizit:
```text
station_dispatch run <schedule>
```
- Dieser Lauf verwendet den aktuell verfügbaren `component.ir_remote_control`.
- Einzelne Routen lassen sich direkt starten über:
```text
train_controller route <name>
```

Das ist in diesem Patch nur **dokumentiert**, nicht funktional geändert.

## Assumptions
- Scope dieses Patches:
  - mehrere `detector_ids` für Stationen
  - mehrere `waypoints` für Routen
  - scrollbares Modal
  - kleine In-App-Hilfe für Schedule-Start
- Außerhalb des Scopes:
  - neue UI für Schedule-Entries
  - persistente Zug-zu-Schedule-Zuweisung
  - Ausbau des Dispatchers zu einem Train-Roster-/Binding-System
