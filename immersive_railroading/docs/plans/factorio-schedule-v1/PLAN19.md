# `station_dispatch` Redstone-Primary-Fix und Editor-Hinweise für Redstone-Anforderungen

## Summary
Der aktuelle Fehler ist **kein** Redstone-Logikfehler, sondern ein OpenOS-Komponentenzugriffsfehler: [`station_dispatch.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/station_dispatch.lua) greift direkt auf `component.redstone` und `component.ir_remote_control` zu. Unter OpenOS wirft `component.<type>` aber bei fehlender Primary-Komponente einen Fehler statt `nil` zurück. Deshalb crasht schon die Prüfung selbst mit:

```text
boot/04_component.lua:68: no primary 'redstone' available
```

Zusätzlich zeigt der Editor aktuell keine hilfreichen Redstone-Hinweise:
- Stationen haben zwar `redstone_outputs`, aber der Editor zeigt sie nicht an.
- Der Save-Tab zeigt nur Start-Hinweise für Schedules/Routes, aber nicht, ob `component.redstone` zur Laufzeit benötigt wird.
- Die Schedule-Detailansicht zeigt `condition.redstone` nicht an.
- Es gibt **keine** UI zum Editieren von `redstone_outputs`; diese Konfiguration bleibt vorerst read-only.

Der Plan behebt beides:
1. `station_dispatch` darf bei fehlender Redstone-Komponente nicht mehr in `boot/04_component.lua` crashen, sondern muss sauber mit einer verständlichen Fehlermeldung enden.
2. Der Editor muss sichtbar machen, **ob** Redstone benötigt wird, **wo** es konfiguriert ist und dass `redstone_outputs` derzeit nur read-only angezeigt werden.

## Verifizierte Ist-Stellen
### 1. Fehlerauslöser in `station_dispatch.lua`
Aktuell:

```lua
local function get_remote()
  if not component or not component.ir_remote_control then
    return nil, "component.ir_remote_control is not available"
  end
  return component.ir_remote_control
end

local function get_redstone_proxy(route_book)
  for _, station in pairs(route_book.STATIONS or {}) do
    if next(station.redstone_outputs or {}) ~= nil then
      if not component or not component.redstone then
        return nil, "component.redstone is required for configured station outputs"
      end
      return component.redstone
    end
  end
  return component and component.redstone or nil
end
```

Das ist unter OpenOS unsicher, weil schon `component.redstone` selbst assertet.

### 2. Editor zeigt Redstone nicht an
In [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua):
- Stationen werden mit `redstone_outputs = {}` angelegt:
```lua
current_state.book.STATIONS[values.id] = {
  ...
  detector_ids = collect_detector_ids(values),
  redstone_outputs = {},
}
```
- Beim Editieren werden bestehende `redstone_outputs` **nicht gelöscht**, aber auch **nirgends angezeigt oder bearbeitet**.
- Save-Tab zeigt aktuell nur:
```lua
save_lines[#save_lines + 1] = "Run schedule: station_dispatch run <schedule>"
save_lines[#save_lines + 1] = "Run route:    train_controller route <route>"
save_lines[#save_lines + 1] = "Schedules run on the active ir_remote_control train."
```

### 3. Relevanter Runtime-/Validierungsvertrag
In [`lib/station_schedule.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/station_schedule.lua) ist `condition.redstone` bereits Teil des Modells:

```lua
if condition.redstone ~= nil then
  ...
  if type(condition.redstone.output) ~= "string" then
    errors[#errors + 1] = "redstone.output must be a string"
  else
    local station = route_book.STATIONS[station_id]
    local outputs = station and station.redstone_outputs or {}
    if not outputs[condition.redstone.output] then
      errors[#errors + 1] = ("station %s does not define redstone output %s"):format(...)
    end
  end
  if condition.redstone.mode ~= "while_pending" and condition.redstone.mode ~= "on_departure_pulse" then
    errors[#errors + 1] = "redstone.mode must be while_pending or on_departure_pulse"
  end
end
```

Das heißt:
- Wenn Schedules Redstone nutzen, ist die Information bereits im Route Book vorhanden.
- Der Editor blendet diese Information aktuell nur nicht ein.

## Implementierungsänderungen
### A. `station_dispatch.lua`: sichere Primary-Komponentenauflösung
Direkt nach `sleep_for(...)` oder direkt vor `get_remote()` diese beiden Helper einfügen:

```lua
local function component_available(name)
  if not component then
    return false
  end
  if type(component.isAvailable) == "function" then
    local ok, value = pcall(component.isAvailable, name)
    return ok and value == true
  end
  local ok, value = pcall(function()
    return component[name]
  end)
  return ok and value ~= nil
end

local function get_primary_component(name)
  if not component_available(name) then
    return nil
  end
  if type(component.getPrimary) == "function" then
    local ok, proxy = pcall(component.getPrimary, name)
    if ok and proxy ~= nil then
      return proxy
    end
  end
  local ok, proxy = pcall(function()
    return component[name]
  end)
  if ok and proxy ~= nil then
    return proxy
  end
  return nil
end
```

Dann `get_remote()` exakt ersetzen durch:

```lua
local function get_remote()
  local remote = get_primary_component("ir_remote_control")
  if not remote then
    return nil, "component.ir_remote_control is not available"
  end
  return remote
end
```

Und `get_redstone_proxy(route_book)` exakt ersetzen durch:

```lua
local function get_redstone_proxy(route_book)
  local requires_redstone = false
  for _, station in pairs(route_book.STATIONS or {}) do
    if next(station.redstone_outputs or {}) ~= nil then
      requires_redstone = true
      break
    end
  end

  local redstone = get_primary_component("redstone")
  if requires_redstone and not redstone then
    return nil, "component.redstone is required for configured station outputs"
  end
  return redstone
end
```

Wichtig:
- **nirgendwo** in `station_dispatch.lua` darf danach noch direkt `component.redstone` oder `component.ir_remote_control` gelesen werden.
- Der gleiche Schutz gilt implizit auch für den `ir_remote_control`-Pfad, nicht nur für Redstone.

### B. `route_book_editor.lua`: Redstone-Runtime-Inspektion hinzufügen
Nahe bei den anderen lokalen Hilfsfunktionen einen neuen Helper einfügen:

```lua
local function inspect_redstone_runtime(book)
  local outputs = {}
  local condition_refs = {}

  for station_id, station in pairs(book.STATIONS or {}) do
    for output_name, output in pairs(station.redstone_outputs or {}) do
      outputs[#outputs + 1] = {
        station_id = station_id,
        output = output_name,
        side = tostring(output.side or "?"),
        strength = output.strength ~= nil and tostring(output.strength) or "15",
        pulse_ticks = output.pulse_ticks ~= nil and tostring(output.pulse_ticks) or "20",
        active_high = output.active_high == false and "false" or "true",
      }
    end
  end

  for schedule_id, schedule in pairs(book.SCHEDULES or {}) do
    for entry_index, entry in ipairs(schedule.entries or {}) do
      for group_index, group in ipairs(entry.wait and entry.wait.groups or {}) do
        for condition_index, condition in ipairs(group or {}) do
          if type(condition.redstone) == "table" then
            condition_refs[#condition_refs + 1] = {
              schedule = schedule_id,
              entry = entry_index,
              group = group_index,
              condition = condition_index,
              output = tostring(condition.redstone.output or "?"),
              mode = tostring(condition.redstone.mode or "?"),
            }
          end
        end
      end
    end
  end

  table.sort(outputs, function(a, b)
    if a.station_id ~= b.station_id then
      return tostring(a.station_id) < tostring(b.station_id)
    end
    return tostring(a.output) < tostring(b.output)
  end)

  table.sort(condition_refs, function(a, b)
    if a.schedule ~= b.schedule then
      return tostring(a.schedule) < tostring(b.schedule)
    end
    if a.entry ~= b.entry then
      return a.entry < b.entry
    end
    if a.group ~= b.group then
      return a.group < b.group
    end
    return a.condition < b.condition
  end)

  local component_present = false
  if component and type(component.isAvailable) == "function" then
    local ok, value = pcall(component.isAvailable, "redstone")
    component_present = ok and value == true
  end

  return {
    required = #outputs > 0,
    component_present = component_present,
    outputs = outputs,
    condition_refs = condition_refs,
  }
end
```

Regel:
- `required` orientiert sich an `station.redstone_outputs`, weil genau das `station_dispatch.run(...)` zur Laufzeit auswertet.
- `condition_refs` dient zur UI-Hilfe, nicht zur Runtime-Entscheidung.

### C. Station-Detailansicht: Redstone-Ausgänge read-only anzeigen
Im Stations-Zweig von `build_screen(...)` die `detail_lines` erweitern.

Aktuell:
```lua
detail_lines = {
  ("ID: %s"):format(selected.id),
  ("Name: %s"):format(station.display_name or selected.id),
  ("Pos: %s, %s, %s"):format(station.x, station.y, station.z),
  "Detectors:",
}
for _, detector_id in ipairs(station.detector_ids or {}) do
  detail_lines[#detail_lines + 1] = "  " .. detector_id
end
```

Ersetzen durch:

```lua
detail_lines = {
  ("ID: %s"):format(selected.id),
  ("Name: %s"):format(station.display_name or selected.id),
  ("Pos: %s, %s, %s"):format(station.x, station.y, station.z),
  "Detectors:",
}
for _, detector_id in ipairs(station.detector_ids or {}) do
  detail_lines[#detail_lines + 1] = "  " .. detector_id
end
if #(station.detector_ids or {}) == 0 then
  detail_lines[#detail_lines + 1] = "  (none)"
end

detail_lines[#detail_lines + 1] = "Redstone outputs:"
local output_names = sorted_keys(station.redstone_outputs or {})
if #output_names == 0 then
  detail_lines[#detail_lines + 1] = "  (none)"
else
  for _, output_name in ipairs(output_names) do
    local output = station.redstone_outputs[output_name] or {}
    detail_lines[#detail_lines + 1] = ("  %s -> %s strength=%s pulse_ticks=%s active_high=%s"):format(
      output_name,
      tostring(output.side or "?"),
      tostring(output.strength ~= nil and output.strength or 15),
      tostring(output.pulse_ticks ~= nil and output.pulse_ticks or 20),
      tostring(output.active_high ~= false)
    )
  end
end
```

Damit ist sichtbar:
- ob die Station Redstone-Ausgänge hat
- welche Ausgänge definiert sind
- dass der Editor sie zwar kennt, aber aktuell nicht editiert

### D. Schedule-Ansicht: Redstone-Condition-Hinweise anzeigen
Im `Schedules`-Zweig von `build_screen(...)` die `Wait Conditions`-Darstellung erweitern.

Aktuell:
```lua
if first_condition then
  render_text(buffer, ..., ("%s %s %s"):format(...), ...)
end
```

Ersetzen durch einen vorbereiteten `wait_lines`-Block, analog zum bereits vorhandenen Wrap-Plan:

```lua
local wait_lines = {}
for group_index, group in ipairs(first_entry.wait.groups or {}) do
  local first_condition = group[1]
  wait_lines[#wait_lines + 1] = ("Group %s"):format(string.char(64 + group_index))
  if first_condition then
    wait_lines[#wait_lines + 1] = ("%s %s %s"):format(
      first_condition.type,
      tostring(first_condition.comparator or ">="),
      tostring(first_condition.value or first_condition.seconds)
    )
    if type(first_condition.redstone) == "table" then
      wait_lines[#wait_lines + 1] = ("redstone %s %s"):format(
        tostring(first_condition.redstone.output or "?"),
        tostring(first_condition.redstone.mode or "?")
      )
    end
  end
end
```

Dann diese Zeilen über den vorhandenen wrapped-panel-Renderer ausgeben. Falls der Wrap/Panel-Scroll-Plan bereits umgesetzt wurde, diesen Renderer wiederverwenden; falls nicht, an derselben Stelle mit dem neuen Wrap-Block arbeiten.

### E. Save / Validate-Tab: Redstone-Runtime-Hinweise ergänzen
Im Save-Tab nach den bestehenden Schedule-/Route-Hinweisen zusätzliche Zeilen einfügen. Vorher `local runtime_info = inspect_redstone_runtime(state.book)` berechnen.

An `save_lines` anhängen:

```lua
save_lines[#save_lines + 1] = ""
save_lines[#save_lines + 1] = ("Redstone runtime: %s"):format(runtime_info.required and "required" or "not required")
save_lines[#save_lines + 1] = ("Primary component.redstone: %s"):format(runtime_info.component_present and "available" or "missing")

if runtime_info.required and not runtime_info.component_present then
  save_lines[#save_lines + 1] = "station_dispatch run <schedule> will fail until a redstone component is installed."
end

if #runtime_info.outputs > 0 then
  save_lines[#save_lines + 1] = "Editor note: station redstone outputs are currently read-only here."
end
```

Optional, aber empfohlen: die ersten 3 `condition_refs` knapp anzeigen, damit man die Zuordnung sieht:

```lua
for index = 1, math.min(#runtime_info.condition_refs, 3) do
  local item = runtime_info.condition_refs[index]
  save_lines[#save_lines + 1] = ("uses redstone: %s entry %d -> %s (%s)"):format(
    item.schedule,
    item.entry,
    item.output,
    item.mode
  )
end
if #runtime_info.condition_refs > 3 then
  save_lines[#save_lines + 1] = ("... and %d more redstone-linked conditions"):format(#runtime_info.condition_refs - 3)
end
```

### F. Editor-Scope bewusst begrenzen
In diesem Patch **keine** UI zum Editieren von `redstone_outputs` einbauen.

Stattdessen ausdrücklich so behandeln:
- read-only Anzeige in Station Details
- read-only Runtime-Hinweise im Save-Tab
- read-only Anzeige von `condition.redstone` in Schedule Wait Conditions

Das verhindert, dass der andere Agent versehentlich ein halbfertiges Redstone-Editorfeature anfängt.

## Tests
### `station_dispatch_emulator.lua`
Die bestehende Datei deckt Redstone nur grundsätzlich ab. Ergänzen:

1. `missing primary redstone returns friendly dispatcher error`
- Emulator mit `redstone = false`
- Test-Route-Book mit mindestens einer Station, die `redstone_outputs` definiert
- `run(...)` darf **nicht** mit `boot/04_component.lua`-ähnlichem Primärzugriffsfehler crashen
- Erwarteter Fehlerstring:
```text
component.redstone is required for configured station outputs
```

2. `missing ir_remote_control returns friendly dispatcher error`
- Emulator mit `ir_remote_control = false`
- `run(...)` muss sauber mit:
```text
component.ir_remote_control is not available
```
enden, nicht mit einem Primary-Zugriffsassert.

Wenn `station_dispatch.run(...)` wegen des aktuellen Dateiladepfads im Emulator nicht direkt isolierbar ist, dann diese beiden Helper zusätzlich im Modul exportieren:
```lua
_component_available = component_available,
_get_primary_component = get_primary_component,
_get_redstone_proxy = get_redstone_proxy,
_get_remote = get_remote,
```
Diese Exporte sind nur für Tests gedacht und bleiben intern dokumentiert.

### `route_book_editor_emulator.lua`
Neue Fälle:
1. `save tab shows redstone runtime status`
- Station mit `redstone_outputs`
- Save-Tab rendern
- sichtbare Zeilen enthalten:
  - `Redstone runtime: required`
  - `Primary component.redstone: available` oder `missing`

2. `station detail shows configured redstone outputs`
- Station mit mindestens einem Output
- Stations-Detailpanel zeigt `Redstone outputs:` plus Output-Zeile

3. `schedule wait panel shows redstone condition summary`
- Schedule mit `condition.redstone`
- Wait-Panel zeigt `redstone <output> <mode>`

4. `editor warns that redstone outputs are read-only`
- Save-Tab enthält:
```text
Editor note: station redstone outputs are currently read-only here.
```

### Manuelle Akzeptanz
Nach Implementierung muss folgendes gelten:
- `station_dispatch run 1` ohne Redstone-Primary zeigt eine kurze verständliche Fehlermeldung statt Stacktrace aus `boot/04_component.lua`
- Der Editor macht sichtbar:
  - ob Redstone zur Laufzeit benötigt wird
  - ob `component.redstone` aktuell verfügbar ist
  - welche Stationen Outputs definiert haben
  - welche Schedule-Wartebedingungen Redstone referenzieren
- Der Editor suggeriert **nicht**, dass man `redstone_outputs` dort bereits bearbeiten kann

## Assumptions
- Die aktuelle Fehlermeldung bedeutet, dass im geladenen Route Book mindestens eine Station `redstone_outputs` definiert und `station_dispatch run ...` deshalb Redstone zur Laufzeit benötigt.
- Dieses Patchset fügt nur **Sichtbarkeit und robuste Fehlerbehandlung** hinzu, nicht die vollständige Bearbeitung von `redstone_outputs` im Editor.
- Der Stil von `component_available(...)` orientiert sich bewusst an [`train_controller.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua), damit kein vierter Komponenten-Zugriffsstil entsteht.
