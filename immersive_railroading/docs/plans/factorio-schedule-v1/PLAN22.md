# `route_book_editor`: Chain-basierter Schedule-Condition-Builder mit AND/OR-Chooser, Comparator-Menüs und Redstone-I/O-UX-Fixes

## Summary
Der Schedule-Editor bildet den ersten Schedule-Entry als echte Wait-Expression ab. Die UI zeigt eine Kette im Stil:

```text
[+] [condition] [+] [AND]
                  [OR]
```

Ablauf:
- Das erste `+` öffnet ein Menü mit verfügbaren Condition-Typen.
- Ein `+` nach einer bestehenden Condition öffnet zuerst einen Operator-Chooser (`AND` oder `OR`), danach wieder den Condition-Chooser.
- Für comparatorbasierte Conditions (`passengers`, `cargo_percent`, `fluid_percent`) folgt nach der Typwahl sofort ein Comparator-Chooser, erst danach kehrt die UI ins Hauptmenü zurück.
- Redstone bleibt **keine eigene parallele Condition-Kette**, sondern eine **optionale Eigenschaft einer einzelnen Wait-Condition**. Für Redstone wird derselbe Menü-Stil innerhalb der ausgewählten Condition verwendet: `Redstone [+] -> I/O-ID wählen -> Mode wählen`.
- Die bestehenden UX-Probleme im Stations-Editor werden gleichzeitig behoben:
  - leere `Redstone I/Os`-Add-Zeile zeigt ihr Label
  - Backspace/Delete in leeren Gruppen-Subfeldern löscht nicht mehr den ganzen I/O-Block

Die Semantik bleibt exakt wie in [`station_schedule.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/station_schedule.lua):
- Conditions innerhalb einer Gruppe sind **AND**
- Gruppen sind **OR**

## Implementierungsänderungen
### 1. Redstone-I/O-UX-Fixes im Stations-Editor
In [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua):

`repeatable_add_visible_value(...)` von
```lua
local function repeatable_add_visible_value(field)
  local indent = string.rep(" ", #tostring(field.label or "")) .. " "
  return indent .. "[" .. tostring(field.add_label or "+") .. "]"
end
```
auf
```lua
local function repeatable_add_visible_value(field, show_label)
  local add_text = "[" .. tostring(field.add_label or "+") .. "]"
  if show_label then
    return ("%s %s"):format(tostring(field.label or ""), add_text)
  end
  local indent = string.rep(" ", #tostring(field.label or "")) .. " "
  return indent .. add_text
end
```
umstellen.

In `render_modal(...)` bei `repeat_add` und `group_add`:
```lua
local show_label = #(row.field.items or {}) == 0
render_text(buffer, x + 2, row_y, prefix .. repeatable_add_visible_value(row.field, show_label), width - 4)
```

Ergebnis bei leerem Feld:
```text
>Redstone I/Os [+]
```

Backspace/Delete-Logik trennen. Aktuell wird `group_item_field` fälschlich mit entfernt. Ersetzen durch:
```lua
if key_code == KEY.backspace then
  if not field then
    return false
  end
  if row and row.kind == "repeat_item" and trim(field.value) == "" and #row.field.items > (row.field.min_items or 1) then
    return remove_repeatable_item(state.modal, row.field_index, row.item_index)
  end
  delete_left(field)
  return true
end

if key_code == KEY.delete then
  if not field then
    return false
  end
  if row and row.kind == "repeat_item" and trim(field.value) == "" and #row.field.items > (row.field.min_items or 1) then
    return remove_repeatable_item(state.modal, row.field_index, row.item_index)
  end
  delete_right(field)
  return true
end
```

Damit gilt:
- `repeat_item` darf weiter implizit entfernt werden
- `group_item_field` darf **nie** implizit entfernt werden
- Redstone-I/O-Gruppen werden nur über `[x]` gelöscht

Fokus nach Remove stabilisieren. Neuen Helper ergänzen:
```lua
local function find_modal_row_index(modal, predicate)
  local rows = build_modal_rows(modal)
  for row_index, row in ipairs(rows) do
    if predicate(row) then
      return row_index
    end
  end
  return nil
end
```

`remove_repeatable_item(...)` danach so ändern:
- zuerst gleiche Position im selben Feld
- sonst vorheriger Eintrag
- sonst Add-Zeile des Feldes
- nicht mehr nur `clamp(...)`

### 2. Neues Feldkind `condition_chain`
Der flache Schedule-Editor (`route`, `seconds`, `redstone_output`, `redstone_mode`) wird durch ein spezialisiertes Feldkind ersetzt:

```lua
{
  kind = "condition_chain",
  key = "wait_chain",
  entry_route = make_text_field({key = "route", label = "First Route", value = ""}),
  groups = {},
  selected_group_index = nil,
  selected_condition_index = nil,
  chooser = nil,
  pending_insert = nil,
  pending_condition = nil,
}
```

Wichtig:
- Der Editor bleibt für diesen Patch beim **ersten Entry** des Schedules.
- Die Wait-Struktur dieses ersten Entries wird aber vollständig als Gruppen-/Condition-Kette editiert.
- Redstone ist Teil einer Condition:
```lua
condition.redstone = {
  output = "loader",
  mode = "while_pending",
}
```
nicht eigene Parallelstruktur.

### 3. Editor-Zwischenmodell für Conditions
Interner Condition-Knoten:
```lua
{
  type = "time_passed" | "inactivity" | "passengers" | "cargo_percent" | "fluid_percent",
  seconds = "0",
  comparator = ">=",
  value = "0",
  scope = "station_any_detector",
  redstone = nil or {
    output = "loader",
    mode = "while_pending" | "on_departure_pulse",
  },
}
```

Interne Gruppenstruktur:
```lua
groups = {
  {
    conditions = {
      {...},
      {...},
    },
  },
  {
    conditions = {
      {...},
    },
  },
}
```

Mapping:
- `groups[n].conditions[*]` = AND
- mehrere `groups` = OR

### 4. Neue Konstanten und Helper
In [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua) ergänzen:

```lua
local SCHEDULE_CONDITION_TYPES = {
  "time_passed",
  "inactivity",
  "passengers",
  "cargo_percent",
  "fluid_percent",
}

local SCHEDULE_COMPARATORS = {"<", "<=", ">", ">=", "=="}
local SCHEDULE_REDSTONE_MODES = {"while_pending", "on_departure_pulse"}
```

Neue Helper:
```lua
local function make_chain_condition(condition)
local function make_condition_chain_field(schedule)
local function chain_tokens_from_groups(groups)
local function render_chain_tokens(buffer, targets, x, y, width, field)
local function route_destination_station_id(book, route_id)
local function available_redstone_ids_for_route_destination(book, route_id)
local function runtime_condition_from_editor(condition)
local function runtime_groups_from_chain(field)
```

`make_chain_condition(condition)`:
```lua
local function make_chain_condition(condition)
  condition = condition or {}
  return {
    type = condition.type or "time_passed",
    seconds = tostring(condition.seconds or 0),
    comparator = tostring(condition.comparator or ">="),
    value = tostring(condition.value or 0),
    scope = scope_to_editor_text(condition.scope),
    redstone = type(condition.redstone) == "table" and {
      output = tostring(condition.redstone.output or ""),
      mode = tostring(condition.redstone.mode or "while_pending"),
    } or nil,
  }
end
```

`make_condition_chain_field(schedule)`:
- lädt `schedule.entries[1]`
- übernimmt `route` aus `entries[1].route`
- übernimmt `wait.groups`
- wenn leer, startet mit `groups = {}` und erstem Start-`+`

### 5. Ketten-Rendering
`build_modal_rows(modal)` um neue Zeilentypen erweitern:
```lua
{ kind = "chain_route", field_index = field_index, field = field, route_field = field.entry_route }
{ kind = "chain_tokens", field_index = field_index, field = field }
{ kind = "chain_condition_detail", field_index = field_index, field = field, group_index = g, condition_index = c, detail = "type"|"seconds"|"comparator"|"value"|"scope"|"redstone" }
{ kind = "chain_chooser", field_index = field_index, field = field }
```

Die Kette selbst wird als Flow-Zeile mit klickbaren Tokens gerendert. Tokens:
```lua
{
  {kind = "plus", slot = "start"},
  {kind = "condition", group_index = 1, condition_index = 1, label = "[time_passed 5s]"},
  {kind = "plus", slot = "after", group_index = 1, condition_index = 1},
  {kind = "operator", operator = "AND", group_index = 1, after_condition_index = 1},
  {kind = "condition", group_index = 1, condition_index = 2, label = "[cargo_percent >= 90]"},
  {kind = "plus", slot = "after", group_index = 1, condition_index = 2},
  {kind = "operator", operator = "OR", after_group_index = 1},
  {kind = "condition", group_index = 2, condition_index = 1, label = "[inactivity 10s]"},
}
```

Renderregeln:
- Condition-Chip:
  - `time_passed`: `[time_passed 5s]`
  - `inactivity`: `[inactivity 10s]`
  - comparatorbasiert: `[cargo_percent >= 90 station_all]`
  - mit Redstone: `[cargo_percent >= 90 | io=loader while_pending]`
- Plus-Chip: `[+]`
- Operator-Chips: `[AND]`, `[OR]`

Die Operatoranzeige soll dem vom Nutzer beschriebenen Modell entsprechen:
- nach einem Condition-`+` erscheint ein Operator-Chooser mit beiden Optionen gleichzeitig
- z. B.
```text
Add after [cargo_percent >= 90]
[x] AND   [ ] OR
```
oder entsprechend mit Unterstreichung/Formatmarker, aber Entscheidung vollständig sichtbar

Wenn Tokens umbrechen, müssen sie flow-layout-artig auf weitere Zeilen verteilt werden, ohne Klickbarkeit zu verlieren.

### 6. Condition-Hinzufügen: exakter Menüfluss
#### Erste Condition
Klick auf Start-`+`:
```lua
field.chooser = {
  kind = "condition_type",
  anchor = {slot = "start"},
  options = SCHEDULE_CONDITION_TYPES,
  selected = 1,
}
```

Nach Auswahl:
- `time_passed` / `inactivity`:
  - Condition sofort einfügen
  - Detailansicht der neuen Condition aktivieren
  - zurück zur Hauptansicht
- `passengers` / `cargo_percent` / `fluid_percent`:
  - noch nicht einfügen
  - zuerst Comparator-Chooser öffnen

#### Weitere Condition nach bestehender Condition
Klick auf `+` hinter bestehender Condition:
```lua
field.chooser = {
  kind = "operator",
  anchor = {group_index = g, condition_index = c},
  options = {"AND", "OR"},
  selected = 1,
}
```

Nach Operatorwahl:
```lua
field.pending_insert = {
  operator = "AND" or "OR",
  group_index = g,
  condition_index = c,
}
field.chooser = {
  kind = "condition_type",
  anchor = {group_index = g, condition_index = c},
  options = SCHEDULE_CONDITION_TYPES,
  selected = 1,
}
```

Nach Typwahl:
- `AND`:
  - neue Condition in dieselbe Gruppe direkt hinter Referenz-Condition einfügen
- `OR`:
  - neue Gruppe nach aktueller Gruppe einfügen
  - neue Condition wird deren erste Condition

Für comparatorbasierte Typen zuerst:
```lua
field.pending_condition = {
  type = selected_type,
  seconds = "0",
  comparator = ">=",
  value = "0",
  scope = "station_any_detector",
  redstone = nil,
}
field.chooser = {
  kind = "comparator",
  options = SCHEDULE_COMPARATORS,
  selected = 4,
}
```

Nach Comparatorwahl:
- `pending_condition.comparator = selected`
- dann erst einfügen
- neue Condition selektieren
- zurück zur Hauptansicht

### 7. Condition-Details der ausgewählten Condition
Unterhalb der Kette wird immer die selektierte Condition vollständig bearbeitet.

Für `time_passed` / `inactivity`:
```text
Type: time_passed
Seconds: 5
Redstone: [+]
```

Für comparatorbasierte Conditions:
```text
Type: cargo_percent
Comparator: >=
Value: 90
Scope: station_any_detector
Redstone: [+]
```

Bearbeitbarkeit:
- `Type` bleibt im Detailblock read-only bzw. reine Anzeige
- Typwechsel nur über Neuanlage
- `Seconds`, `Value`, `Scope` bleiben Textfelder
- `Comparator` ist Choice-Feld
- `Redstone` nutzt eigenen Menüfluss

Sichtbarkeitsregeln:
- `Seconds` nur für `time_passed`, `inactivity`
- `Comparator`, `Value`, `Scope` nur für `passengers`, `cargo_percent`, `fluid_percent`
- `Redstone` immer sichtbar als `+` oder bestehender Eintrag

### 8. Redstone-Menüfluss pro Condition
Redstone bleibt Eigenschaft einer Condition.

Darstellung:
- ohne Redstone:
```text
Redstone: [+]
```
- mit Redstone:
```text
Redstone: [loader while_pending] [x]
```

Klick auf `Redstone [+]`:
1. I/O-ID-Menü:
```lua
field.chooser = {
  kind = "redstone_output",
  condition_ref = {group_index = g, condition_index = c},
  options = available_redstone_ids_for_route_destination(book, field.entry_route.value),
  selected = 1,
}
```
2. Nach Auswahl direkt Mode-Menü:
```lua
field.chooser = {
  kind = "redstone_mode",
  condition_ref = {group_index = g, condition_index = c},
  options = SCHEDULE_REDSTONE_MODES,
  selected = 1,
}
```
3. Danach:
```lua
condition.redstone = {
  output = selected_output,
  mode = selected_mode,
}
```

Klick auf Redstone-`[x]`:
```lua
condition.redstone = nil
```

Wenn keine Zielstations-I/Os bekannt sind:
- Menü zeigt keine leeren Werte
- stattdessen Hinweiszeile:
```text
No destination-station Redstone I/Os available.
```

`available_redstone_ids_for_route_destination(book, route_id)`:
- Zielstation der Route bestimmen
- `sorted_keys(station.redstone_outputs or {})` zurückgeben
- keine Fallbacks auf globale Liste

### 9. Tastatur- und Klickverhalten
Klick auf Tokens:
- Condition-Chip selektiert Condition
- Start-/After-`+` öffnet jeweils richtigen Chooser
- Operator-Chip selbst nur Anzeige, kein Direktwechsel
- Redstone-`+` öffnet Redstone-Chooser
- Redstone-`[x]` entfernt Redstone
- Remove-`[x]` bei I/O-Gruppen entfernt nur explizit

Tastatur:
- `Up` / `Down` bewegt sich durch Modal-Zeilen wie bisher
- `Left` / `Right`
  - in Choice-Feldern Werte wechseln
  - im Operator-/Comparator-/Type-Chooser Auswahl wechseln
- `Enter`
  - bestätigt Auswahl im aktiven Chooser
  - auf Condition-Chip selektiert bzw. springt zu Details
- `Space`
  - optional ebenfalls Confirm in Choosern
- `Backspace` / `Delete`
  - bearbeiten nur Textfelder
  - löschen nie implizit Chain-Conditions oder Gruppen
- Entfernen von Conditions/Gruppen weiterhin nur über explizite `[x]`

### 10. Add/Edit Schedule umstellen
`Add Schedule`:
```lua
fields = {
  make_text_field({key = "id", label = "Schedule ID"}),
  make_text_field({key = "cyclic", label = "Cyclic", value = "false"}),
  make_condition_chain_field(nil),
}
```

`Edit Schedule`:
```lua
fields = {
  make_text_field({key = "cyclic", label = "Cyclic", value = tostring(schedule.cyclic == true)}),
  make_condition_chain_field(schedule),
}
```

Der bisherige Top-Level-Feldsatz entfällt:
- `route`
- `seconds`
- `redstone_output`
- `redstone_mode`

Stattdessen:
- `route` steckt in `condition_chain.entry_route`
- Wait-/Redstone-Struktur steckt komplett in `condition_chain.groups`

### 11. Submit-Logik
`collect_modal_values(modal)` muss `condition_chain` unterstützen:
```lua
elseif field.kind == "condition_chain" then
  values[field.key] = {
    route = trim(field.entry_route.value),
    groups = runtime_groups_from_chain(field),
  }
```

`runtime_condition_from_editor(condition)`:
```lua
local function runtime_condition_from_editor(condition)
  local out = {type = condition.type}

  if condition.type == "time_passed" or condition.type == "inactivity" then
    out.seconds = tonumber(condition.seconds) or 0
  else
    out.comparator = condition.comparator or ">="
    out.value = tonumber(condition.value) or 0
    out.scope = scope_from_editor_text(condition.scope)
  end

  if condition.redstone and trim(condition.redstone.output) ~= "" then
    out.redstone = {
      output = trim(condition.redstone.output),
      mode = condition.redstone.mode or "while_pending",
    }
  end

  return out
end
```

`runtime_groups_from_chain(field)`:
```lua
local function runtime_groups_from_chain(field)
  local groups = {}
  for _, group in ipairs(field.groups or {}) do
    local runtime_group = {}
    for _, condition in ipairs(group.conditions or {}) do
      runtime_group[#runtime_group + 1] = runtime_condition_from_editor(condition)
    end
    if #runtime_group > 0 then
      groups[#groups + 1] = runtime_group
    end
  end
  if #groups == 0 then
    groups[1] = {
      {type = "time_passed", seconds = 0},
    }
  end
  return groups
end
```

Schedule-Submit:
```lua
schedule.entries[1] = {
  route = values.wait_chain.route,
  wait = {
    groups = values.wait_chain.groups,
  },
}
schedule.cyclic = values.cyclic == "true"
```

Scope bleibt über vorhandene Helper:
- `station_any_detector`
- `station_all_detectors`
- `detector:<id>`

### 12. Save-/Detail-Hinweise aktualisieren
Alte Aussage entfernen:
```text
Advanced multi-entry/group/condition editing is still manual.
```

Neue Hinweise im Save-Tab:
```text
Conditions in a group are AND.
Groups are OR.
Click [+] to add a condition, then choose AND or OR before the next one.
Comparator-based conditions open a comparator chooser before returning.
Redstone is attached per condition via the Redstone field.
```

Die Schedule-Wait-Zusammenfassung in der Read-Only-Ansicht auf alle Conditions ausweiten, nicht nur `group[1][1]`:
```lua
for group_index, group in ipairs(entry.wait.groups or {}) do
  wait_lines[#wait_lines + 1] = ("Group %s"):format(string.char(64 + group_index))
  for condition_index, condition in ipairs(group or {}) do
    wait_lines[#wait_lines + 1] = ("  [%d] %s"):format(condition_index, condition.type)
    ...
  end
end
```

## Testplan
### `route_book_editor_emulator.lua`
Neue oder angepasste Tests:

1. `empty redstone io add row shows label`
- leeres `Redstone I/Os`
- Modal zeigt `Redstone I/Os [+]`

2. `backspace on empty redstone group field does not delete item`
- leeres `ID`- oder `Address`-Subfeld
- Backspace/Delete
- I/O-Block bleibt erhalten

3. `first chain plus opens condition chooser`
- Klick auf Start-`+`
- Condition-Type-Menü erscheint

4. `adding next condition opens operator chooser before condition chooser`
- bestehende Condition
- Klick auf `+` danach
- zuerst `AND/OR`
- danach Condition-Menü

5. `and inserts condition into same group`
- `AND` wählen
- Resultat: `groups[1].conditions` enthält beide Conditions

6. `or inserts condition into next group`
- `OR` wählen
- Resultat: zweite Gruppe entsteht

7. `comparator condition opens comparator chooser before insertion`
- Typ `cargo_percent`
- Comparator-Menü erscheint
- erst danach wird Condition angelegt

8. `selected condition details show correct fields for time condition`
- `time_passed`
- `Seconds` sichtbar
- `Comparator`, `Value`, `Scope` unsichtbar

9. `selected condition details show correct fields for comparator condition`
- `cargo_percent`
- `Comparator`, `Value`, `Scope` sichtbar
- `Seconds` unsichtbar

10. `redstone chooser flow attaches output and mode`
- `Redstone [+]`
- I/O-ID-Menü
- danach Mode-Menü
- `condition.redstone` korrekt gesetzt

11. `redstone remove x clears condition redstone`
- vorhandenes Redstone
- Klick auf `[x]`
- `condition.redstone == nil`

12. `wait summary renders all groups and conditions`
- mehrere Gruppen/Conditions
- Read-Only-Wait-Panel zeigt vollständige Struktur statt nur erster Condition

13. `condition tokens wrap without losing targets`
- lange Kette
- Flow bricht um
- Klicktargets bleiben korrekt

14. `focus remains stable after io remove`
- I/O per `[x]` gelöscht
- Fokus geht auf Nachbar oder Add-Zeile, nicht unkontrolliert

### Bestehende Tests beibehalten
- Repeatable detector IDs
- Repeatable waypoints
- Redstone I/O ID + Address Roundtrip
- Duplicate Redstone I/O IDs rejected
- Cursor nur auf aktiver Zeile
- Wrap-/Scroll-Tests
- Emulator-Lifecycle-/Leak-Tests

## Assumptions
- Dieser Patch bearbeitet weiterhin nur den **ersten Entry** eines Schedules, nicht mehrere Entries.
- `Redstone` bleibt immer Eigenschaft einer einzelnen Wait-Condition und wird nicht als eigener OR/AND-Zweig modelliert.
- Comparatorbasierte Typen sind genau:
  - `passengers`
  - `cargo_percent`
  - `fluid_percent`
- `time_passed` und `inactivity` verwenden ausschließlich `seconds`.
- `Scope` bleibt ein Textfeld mit den bereits validierten Formen:
  - `station_any_detector`
  - `station_all_detectors`
  - `detector:<id>`
- Wenn die Kette leer bleibt, wird beim Submit weiterhin auf:
```lua
{{{type = "time_passed", seconds = 0}}}
```
zurückgefallen, damit das bestehende Laufzeitmodell gültig bleibt.
