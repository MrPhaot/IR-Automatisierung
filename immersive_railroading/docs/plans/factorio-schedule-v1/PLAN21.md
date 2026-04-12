# `route_book_editor` + `station_dispatch`: Mehrere adressierte Redstone-I/Os mit `ID` und `Address`

## Summary
Der bisherige Redstone-I/O-Plan reicht nicht aus, weil er implizit von **einer** globalen `component.redstone`-Primary ausgeht. Wenn mehrere Redstone-Module existieren, muss jedes I/O im Editor nicht nur `Side/Strength/Pulse/Active High`, sondern auch:

- eine **logische ID** für Schedule-Referenzen
- eine **Komponentenadresse** für das konkrete Redstone-Modul

bekommen.

Daraus folgen drei gekoppelte Änderungen:

1. **Stations-Editor**
   `Redstone I/Os` wird auf ein echtes Gruppenfeld mit `ID`, `Address`, `Side`, `Strength`, `Pulse`, `Active High` ausgebaut.

2. **Schedule-Editor**
   Das bisherige Feld `Redstone Output` wird inhaltlich zu einer Referenz auf die **I/O-ID** der Zielstation. Die Label sollten das klar machen.

3. **Runtime**
   [`station_dispatch.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/station_dispatch.lua) und [`lib/redstone_io.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/redstone_io.lua) dürfen nicht mehr einen einzigen Redstone-Proxy für alles verwenden. Sie müssen Ausgänge pro `address` auflösen und cachen.

Wichtige Designentscheidung:
- Die Datenstruktur bleibt **rückwärtskompatibel**:
  - `station.redstone_outputs` bleibt eine Map
  - der Map-Key ist die **I/O-ID**
  - neu kommt pro Output `address` dazu
- Alte Bücher ohne `address` bleiben gültig und verwenden weiterhin die Primary-Redstone-Komponente als Fallback.

## Datenmodell und öffentliche Interfaces
### 1. Route-Book-Schema
Bisher:
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

Neu:
```lua
redstone_outputs = {
  loader = {
    address = "redstone-12345678",
    side = "north",
    strength = 15,
    pulse_ticks = 20,
    active_high = true,
  },
  departure = {
    address = "redstone-abcdef",
    side = "east",
    strength = 15,
    pulse_ticks = 10,
    active_high = false,
  },
}
```

Wichtig:
- `loader` / `departure` bleiben die **IDs**, auf die Schedules verweisen.
- `address` ist optional für Altbestände, aber in der neuen Editor-UI ein reguläres Feld.
- Wenn `address == ""`, wird beim Speichern `nil` geschrieben und zur Laufzeit Primary-Fallback verwendet.

### 2. Schedule-Datenmodell
Bleibt strukturell gleich:
```lua
redstone = {
  output = "loader",
  mode = "while_pending",
}
```

Aber:
- `output` ist jetzt explizit die **I/O-ID** der Zielstation.
- Im Editor-Label nicht mehr nur `Redstone Output`, sondern `Redstone I/O ID`.

### 3. `redstone_io.make_controller(...)`
Aktueller Vertrag:
```lua
function M.make_controller(redstone_proxy, log_fn, now_fn)
```

Neuer Vertrag:
```lua
function M.make_controller(resolve_redstone_proxy, log_fn, now_fn, component_api)
```

Dabei ist:
- `resolve_redstone_proxy(config) -> proxy|nil, err`
- `config` ist der jeweilige Output-Config-Eintrag
- `component_api` wird an `oc_proxy.invoke(...)` durchgereicht

Der Controller darf keinen einzelnen `self.redstone`-Proxy mehr halten.

## Implementierungsänderungen
### A. `route_book_editor.lua`: Gruppenfeld für Redstone-I/Os erweitern
Die vorhandene Gruppen-UI ist schon da. Sie muss nur um `ID` und `Address` ergänzt und die Labels angepasst werden.

#### 1. `redstone_output_rows_from_station(station)` anpassen
Aktuell:
```lua
rows[#rows + 1] = {
  name = name,
  side = tostring(output.side or ""),
  strength = tostring(output.strength ~= nil and output.strength or 15),
  pulse_ticks = tostring(output.pulse_ticks ~= nil and output.pulse_ticks or 20),
  active_high = tostring(output.active_high ~= false),
}
```

Ersetzen durch:
```lua
rows[#rows + 1] = {
  id = name,
  address = tostring(output.address or ""),
  side = tostring(output.side or ""),
  strength = tostring(output.strength ~= nil and output.strength or 15),
  pulse_ticks = tostring(output.pulse_ticks ~= nil and output.pulse_ticks or 20),
  active_high = tostring(output.active_high ~= false),
}
```

#### 2. `collect_redstone_outputs(values)` anpassen
Aktuell arbeitet die Funktion mit `item.name`. Neu muss sie mit `item.id` arbeiten und `address` mitspeichern:

```lua
local function collect_redstone_outputs(values)
  local outputs = {}
  for _, item in ipairs(values.redstone_outputs or {}) do
    local id = trim(item.id)
    if id ~= "" then
      local address = trim(item.address)
      outputs[id] = {
        address = address ~= "" and address or nil,
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

#### 3. Duplikatprüfung auf `id` umstellen
Aktuell:
```lua
local name = trim(item.name)
...
return false, ("Redstone I/O name duplicated: %s"):format(name)
```

Neu:
```lua
local id = trim(item.id)
if id ~= "" then
  if seen[id] then
    return false, ("Redstone I/O ID duplicated: %s"):format(id)
  end
  seen[id] = true
end
```

#### 4. Station-Modalfelder erweitern
In `Add Station` und `Edit Station` den `make_repeatable_group_field(...)`-Block von:
```lua
item_fields = {
  {key = "name", label = "Name", default = ""},
  {key = "side", label = "Side", default = "north"},
  {key = "strength", label = "Strength", default = "15"},
  {key = "pulse_ticks", label = "Pulse", default = "20"},
  {key = "active_high", label = "Active High", default = "true"},
}
```

auf:
```lua
item_fields = {
  {key = "id", label = "ID", default = ""},
  {key = "address", label = "Address", default = ""},
  {key = "side", label = "Side", default = "north"},
  {key = "strength", label = "Strength", default = "15"},
  {key = "pulse_ticks", label = "Pulse", default = "20"},
  {key = "active_high", label = "Active High", default = "true"},
}
```

umstellen.

#### 5. Station-Details auf neue Felder umstellen
Aktuelle Ausgabe:
```lua
("  %s -> %s strength=%s pulse_ticks=%s active_high=%s"):format(...)
```

Neu:
```lua
detail_lines[#detail_lines + 1] = ("  %s @ %s -> %s strength=%s pulse_ticks=%s active_high=%s"):format(
  output_name,
  tostring(output.address or "<primary>"),
  tostring(output.side or "?"),
  tostring(output.strength ~= nil and output.strength or 15),
  tostring(output.pulse_ticks ~= nil and output.pulse_ticks or 20),
  tostring(output.active_high ~= false)
)
```

### B. `route_book_editor.lua`: Schedule-UI klar auf I/O-ID ausrichten
#### 1. Feldlabels anpassen
In `Add Schedule` und `Edit Schedule`:
```lua
make_text_field({key = "redstone_output", label = "Redstone Output", ...})
```
ersetzen durch:
```lua
make_text_field({key = "redstone_output", label = "Redstone I/O ID", ...})
```

`Redstone Mode` bleibt.

#### 2. Save-Tab-Hinweis präzisieren
Die aktuellen Hilfetexte zum Redstone-Feature ergänzen um:
```lua
save_lines[#save_lines + 1] = "Schedule redstone binds by I/O ID to the destination station."
save_lines[#save_lines + 1] = "Station I/O address selects which redstone module is used."
```

#### 3. Wait-Condition-Anzeige präzisieren
Die bestehende Zeile:
```lua
("redstone %s %s"):format(output, mode)
```

ersetzen durch:
```lua
("redstone io=%s mode=%s"):format(
  tostring(first_condition.redstone.output or "?"),
  tostring(first_condition.redstone.mode or "?")
)
```

### C. `station_dispatch.lua`: von globalem Primary-Proxy auf adressierte Auflösung umstellen
#### 1. `get_redstone_proxy(route_book)` vollständig ersetzen
Die Funktion wird durch zwei Helper ersetzt:

```lua
local function get_redstone_component(address)
  if not component then
    return nil, "component API unavailable"
  end

  if type(address) == "string" and address ~= "" then
    if type(component.proxy) ~= "function" then
      return nil, ("component.proxy is unavailable for redstone address %s"):format(address)
    end
    local ok, proxy = pcall(component.proxy, address)
    if not ok or proxy == nil then
      return nil, ("redstone component address %s is unavailable"):format(address)
    end
    return proxy
  end

  local primary = get_primary_component("redstone")
  if not primary then
    return nil, "component.redstone is required for configured station outputs"
  end
  return primary
end

local function make_redstone_proxy_resolver(route_book)
  local cache = {}
  local required = false

  for _, station in pairs(route_book.STATIONS or {}) do
    if next(station.redstone_outputs or {}) ~= nil then
      required = true
      break
    end
  end

  if not required then
    return function()
      return nil
    end
  end

  return function(config)
    local address = config and config.address or nil
    local cache_key = address ~= nil and address ~= "" and address or "__primary__"
    if cache[cache_key] ~= nil then
      return cache[cache_key]
    end

    local proxy, err = get_redstone_component(address)
    if not proxy then
      return nil, err
    end
    cache[cache_key] = proxy
    return proxy
  end
end
```

#### 2. `run(...)` auf Resolver umstellen
Aktuell:
```lua
local redstone_proxy, redstone_error = get_redstone_proxy(route_book)
if redstone_error then
  return nil, redstone_error
end

local io_controller = redstone_io.make_controller(redstone_proxy, function(event_name, payload)
  emit_event(logger, event_name, payload)
end, uptime)
```

Neu:
```lua
local resolve_redstone_proxy = make_redstone_proxy_resolver(route_book)

local io_controller = redstone_io.make_controller(
  resolve_redstone_proxy,
  function(event_name, payload)
    emit_event(logger, event_name, payload)
  end,
  uptime,
  component
)
```

Wichtig:
- Die alte globale Redstone-Vorprüfung über `get_redstone_proxy(route_book)` entfällt.
- Fehler entstehen jetzt genau bei dem Output, dessen `address` oder Fallback fehlt.

### D. `lib/redstone_io.lua`: Controller auf Proxy-Resolver umstellen
#### 1. `oc_proxy` einbinden
Am Dateianfang ergänzen:
```lua
local oc_proxy = require("lib.oc_proxy")
```

#### 2. Signatur ändern
Aktuell:
```lua
function M.make_controller(redstone_proxy, log_fn, now_fn)
```

Neu:
```lua
function M.make_controller(resolve_redstone_proxy, log_fn, now_fn, component_api)
```

Controller-Struktur:
```lua
local controller = {
  resolve_redstone_proxy = resolve_redstone_proxy,
  component = component_api,
  log = log_fn or function() end,
  now = now_fn or os.clock,
  states = {},
  pulses = {},
}
```

#### 3. `set_output(...)` anpassen
Aktuell:
```lua
if not self.redstone then
  error("component.redstone is required for configured station outputs")
end
...
self.redstone.setOutput(side, target)
```

Neu:
```lua
local redstone, proxy_error = self.resolve_redstone_proxy and self.resolve_redstone_proxy(config)
if not redstone then
  error(proxy_error or ("component.redstone is required for output %s"):format(name))
end

local ok, invoke_error = oc_proxy.invoke(self.component, redstone, "setOutput", side, target)
if not ok then
  error(tostring(invoke_error))
end
```

#### 4. State-Key um Adresse erweitern
Aktuell:
```lua
local key = ("%s:%s"):format(name, side)
```

Neu:
```lua
local address_key = tostring((config and config.address and config.address ~= "") and config.address or "<primary>")
local key = ("%s:%s:%s"):format(address_key, name, side)
```

Das verhindert, dass zwei Outputs mit gleichem Namen auf unterschiedlichen Modulen denselben Zustands-Slot teilen.

#### 5. Validation auf `address` erweitern
In `validate_outputs(outputs)` ergänzen:
```lua
if output.address ~= nil and type(output.address) ~= "string" then
  errors[#errors + 1] = ("redstone output %s.address must be a string when present"):format(name)
end
```

Leere Strings bleiben erlaubt, weil sie Primary-Fallback bedeuten.

### E. Editor-Hinweise und Texte anpassen
Folgende Texte ändern:
- `Redstone Output` -> `Redstone I/O ID`
- `Editor supports station redstone outputs and first-entry schedule redstone binding.` bleibt okay
- ergänzen:
  - `Each station I/O may target a different redstone component address.`
  - `Leave Address empty to use the primary redstone component.`

Diese Hinweise in den Save/Validate-Tab aufnehmen.

## Testplan
### `route_book_editor_emulator.lua`
Neue oder angepasste Tests:
1. `station redstone io editor stores id and address`
- Station öffnen
- `Redstone I/Os`-Eintrag mit `id=loader`, `address=redstone-2`
- Submit
- Erwartung:
```lua
station.redstone_outputs.loader.address == "redstone-2"
```

2. `duplicate redstone io ids rejected`
- zwei I/O-Einträge mit gleicher `ID`
- Submit schlägt mit:
```text
Redstone I/O ID duplicated: loader
```
fehl

3. `schedule editor stores redstone io id`
- Schedule-Edit
- `Redstone I/O ID = loader`
- Submit
- Erwartung:
```lua
schedule.entries[1].wait.groups[1][1].redstone.output == "loader"
```

4. `station details show address`
- Detailansicht enthält:
```text
loader @ redstone-2 -> north ...
```

### `station_dispatch_emulator.lua`
Bestehende Suite erweitern:
1. `addressed redstone output uses matching component proxy`
- zwei Redstone-Komponenten registrieren:
  - `redstone-a`
  - `redstone-b`
- Stationoutput `loader.address = "redstone-b"`
- Schedulelauf / Controllerpfad muss auf `redstone-b` schreiben, nicht auf die Primary

2. `empty address falls back to primary redstone`
- `address = nil` oder `""`
- Write geht an Primary

3. `missing addressed redstone component returns friendly error`
- Output mit `address = "missing-redstone"`
- erwarteter Fehler:
```text
redstone component address missing-redstone is unavailable
```

4. `state tracking separates same output names on different addresses`
- zwei Outputs mit gleichem Namen auf verschiedenen Adressen
- State-Collision darf nicht auftreten

### `station_dispatch_preview.lua`
Das statische Vorschau-Book um `address` erweitern:
```lua
loader = {address = "redstone-a", side = "north", strength = 15, active_high = true}
```
und die Validation muss weiter grün bleiben.

## Assumptions
- `ID` ist die logische Kennung eines Redstone-I/Os und entspricht dem Key in `station.redstone_outputs`.
- `Address` ist optional; leer bedeutet Fallback auf die Primary-Redstone-Komponente.
- Mehrere I/Os dürfen dieselbe `address` verwenden.
- `condition.redstone.output` bleibt absichtlich nur eine I/O-ID; dort wird **keine** Adresse doppelt eingetragen, damit die Adresse nur an einer Stelle gepflegt wird.
- Der Patch erweitert den bestehenden vereinfachten Schedule-Editor nur für den ersten Entry / die erste Wait-Condition, nicht für beliebig komplexe Gruppen.
