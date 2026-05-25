# PLAN25: Schedule-Graph, Guardrail-Waypoints und Pass-through-Regler

## Summary

`1oil3.1` zeigt zwei getrennte Probleme:

- Das Route-/Schedule-Modell ist noch zu “Runde mit statischer Waypoint-Liste”. Für Factorio-artige Fahrpläne müssen Schedule-Entries echte Stationshalte sein; Routes sind gerichtete Kanten zwischen Stationen; `via`-Waypoints sind nur Guardrails.
- Der speed-centric Controller hat zwei Pass-through-Schwächen: Moving-away bleibt in `auto` mit Throttle, und der D-Term kann nach Leg-/Achsenwechseln Service-Brake auslösen, obwohl der Zug klar unter Zielgeschwindigkeit fährt.

PLAN25 baut deshalb:
- neues primäres Route-Modell `from/to/via`
- explizite `entry.station`
- automatische Route-Auflösung zwischen Stations-Entries
- schedule-globalen Start-/Guardrail-Picker mit Richtungserkennung
- bumpless D-Term plus Pass-through-Brake-Gate

Keine native IR-Schienen-Topologie, keine Junction-/Block-Reservierung.

## Datenmodell und Route-Aufbau

### `programs/route_book.lua`: Schema-Gerüst

Produktions-`route_book.lua` bleibt leer, aber zeigt das neue Primärmodell:

```lua
return {
  AUGMENTS = {
    DETECTORS = {},
  },

  STATIONS = {
    -- [station_id] = {
    --   display_name = "...",
    --   x = 0, y = 0, z = 0,
    --   detector_ids = {},
    --   redstone_outputs = {},
    -- },
  },

  ROUTES = {
    -- [route_id] = {
    --   from = station_id,
    --   to = station_id,
    --   via = {
    --     { x = 0, y = 0, z = 0 },
    --   },
    --   cruise_kmh = 65,
    --   profile = "conservative",
    --   stop_buffer_m = 6,
    -- },
  },

  SCHEDULES = {
    -- [schedule_id] = {
    --   cyclic = true,
    --   entries = {
    --     {
    --       station = station_id,
    --       route = route_id,
    --       wait = { groups = { { { type = "time_passed", seconds = 0 } } } },
    --       redstone = { rules = {} },
    --     },
    --   },
    -- },
  },
}
```

### Beispiel, nicht Schema

Nur als Welt-Beispiel für deine Ölstrecke:

```lua
ROUTES = {
  ref_to_frack = {
    from = "1_oil_ref",
    to = "2_oil_frack",
    cruise_kmh = 65,
    profile = "conservative",
    stop_buffer_m = 6,
    via = {
      { x = -65, y = 69, z = 429 },
      { x = -28, y = 69, z = 456 },
      { x = 106, y = 70, z = 390 },
      { x = 130, y = 68, z = 224 },
      { x = 604, y = 68, z = -309 },
    },
  },

  frack_to_ref = {
    from = "2_oil_frack",
    to = "1_oil_ref",
    cruise_kmh = 65,
    profile = "conservative",
    stop_buffer_m = 6,
    via = {
      -- echte Rückweg-/Loop-Guardrails
    },
  },
}

SCHEDULES = {
  ["1_oil_1"] = {
    cyclic = true,
    entries = {
      {
        station = "1_oil_ref",
        route = "frack_to_ref",
        wait = { groups = { { { type = "time_passed", seconds = 0 } } } },
      },
      {
        station = "2_oil_frack",
        route = "ref_to_frack",
        wait = { groups = { { { type = "time_passed", seconds = 10 } } } },
      },
    },
  },
}
```

### `programs/train_controller.lua`: Route-Book-Normalisierung

`load_route_book()` erweitert Top-Level-Kompatibilität:

```lua
route_book_or_error.AUGMENTS = route_book_or_error.AUGMENTS or {}
route_book_or_error.AUGMENTS.DETECTORS = route_book_or_error.AUGMENTS.DETECTORS or {}
route_book_or_error.STATIONS = route_book_or_error.STATIONS or {}
route_book_or_error.ROUTES = route_book_or_error.ROUTES or {}
route_book_or_error.SCHEDULES = route_book_or_error.SCHEDULES or {}
```

Waypoint-Normalisierung ersetzen/ergänzen:

```lua
local function normalize_route_point(route_name, point_label, value, stations)
  local label = ("route %s %s"):format(route_name, tostring(point_label))
  if type(value) == "string" then
    local station = stations[value]
    if not station then
      error(("%s references unknown station: %s"):format(label, value))
    end
    return parse_cli_point(label, station)
  end
  if type(value) ~= "table" then
    error(("%s must be a station id or {x=..., y=..., z=...} table"):format(label))
  end
  return parse_cli_point(label, value)
end

local function normalize_route_waypoint(route_name, waypoint_index, value, stations)
  return normalize_route_point(route_name, ("waypoint %s"):format(tostring(waypoint_index)), value, stations)
end

local function build_named_route_points(route_name, route, stations)
  local has_edge_shape = route.from ~= nil or route.to ~= nil or route.via ~= nil
  local points = {}

  if has_edge_shape then
    if type(route.from) ~= "string" then
      error(("route %s with from/to/via must define from station id"):format(route_name))
    end
    if type(route.to) ~= "string" then
      error(("route %s with from/to/via must define to station id"):format(route_name))
    end
    if route.via ~= nil and type(route.via) ~= "table" then
      error(("route %s via must be a list when present"):format(route_name))
    end

    points[#points + 1] = normalize_route_point(route_name, "from", route.from, stations)
    for index, waypoint in ipairs(route.via or {}) do
      points[#points + 1] = normalize_route_point(route_name, ("via %d"):format(index), waypoint, stations)
    end
    points[#points + 1] = normalize_route_point(route_name, "to", route.to, stations)
    return points
  end

  if type(route.waypoints) ~= "table" or #route.waypoints == 0 then
    error(("route %s must define from/to/via or non-empty waypoints"):format(route_name))
  end
  for index, waypoint in ipairs(route.waypoints) do
    points[#points + 1] = normalize_route_waypoint(route_name, index, waypoint, stations)
  end
  return points
end
```

In `build_named_route_plan(...)`:

```lua
local waypoints = build_named_route_points(route_name, route, stations)
```

`build_route_plan(...)` bekommt optionalen Start-Leg:

```lua
local function build_route_plan(route_name, waypoints, cruise_kmh, stop_buffer_m, profile_name, initial_leg_index)
  ...
  return {
    name = route_name,
    cruise_kmh = cruise_kmh,
    stop_buffer_m = stop_buffer_m,
    profile_name = profile_name,
    legs = legs,
    initial_leg_index = initial_leg_index or 1,
  }
end
```

`execute_route_plan(...)` startet dort:

```lua
local start_index = math.max(1, math.min(route_plan.initial_leg_index or 1, #route_plan.legs))
for index = start_index, #route_plan.legs do
  local leg = route_plan.legs[index]
  ...
end
```

## Schedule-Semantik und Dispatcher

### `programs/lib/station_schedule.lua`

Primäre Stationsauflösung:

```lua
local function route_terminal_station_id(route)
  if type(route) ~= "table" then
    return nil
  end
  if type(route.to) == "string" then
    return route.to
  end
  local last_waypoint = route.waypoints and route.waypoints[#route.waypoints]
  if type(last_waypoint) == "string" then
    return last_waypoint
  end
  return nil
end

function M.resolve_entry_station_id(route_book, entry)
  if type(entry.station) == "string" then
    return entry.station
  end

  local route = route_book.ROUTES[entry.route]
  if type(route) ~= "table" then
    return nil, ("schedule entry references unknown route %s"):format(tostring(entry.route))
  end

  local station_id = route_terminal_station_id(route)
  if not station_id then
    return nil, ("route %s must end at a station id or entry.station must be set"):format(entry.route)
  end
  return station_id
end
```

Validation ergänzt:
- `entry.station`, wenn gesetzt, muss existieren.
- `entry.route`, wenn gesetzt, muss existieren.
- Falls `entry.station` und Route-Ziel beide gesetzt sind, müssen sie übereinstimmen.
- Entry ohne `route` ist nur erlaubt, wenn `station` gesetzt ist und Dispatcher später eindeutig `current_station -> station` auflösen kann.

### `programs/station_dispatch.lua`

Route-Resolver:

```lua
local function resolve_route_for_entry(route_book, current_station_id, entry)
  if type(entry.route) == "string" then
    return entry.route
  end

  if not current_station_id then
    return nil, "first schedule entry must define route when current station is unknown"
  end
  if type(entry.station) ~= "string" then
    return nil, "schedule entry without route must define station"
  end

  local matches = {}
  for route_id, route in pairs(route_book.ROUTES or {}) do
    if route.from == current_station_id and route.to == entry.station then
      matches[#matches + 1] = route_id
    end
  end
  table.sort(matches)

  if #matches == 0 then
    return nil, ("no route from %s to %s"):format(current_station_id, entry.station)
  end
  if #matches > 1 then
    return nil, ("multiple routes from %s to %s: %s"):format(current_station_id, entry.station, table.concat(matches, ", "))
  end
  return matches[1]
end
```

`run(...)` führt `current_station_id`:

```lua
local current_station_id = nil
...
local route_id, route_error = resolve_route_for_entry(route_book, current_station_id, entry)
if not route_id then
  return nil, route_error
end
...
current_station_id = station_id
```

Alle Logs verwenden `route_id`, nicht blind `entry.route`.

## Schedule-Globaler Start-/Guardrail-Picker

Ziel: Beim Kaltstart wird aus allen Waypoints aller Schedule-Routen der plausibelste Punkt **vor dem Zug** gewählt. Annahme: Zug steht bereits auf dem richtigen Streckenabschnitt, nicht in einem fernen Depot.

### Richtungsermittlung

In `train_controller.lua` exportieren:

```lua
local function sample_heading(remote, fallback_axis, logger)
  local p0, err = read_position(remote)
  if not p0 then
    return fallback_axis, "fallback_position_error:" .. tostring(err)
  end

  local ok = pcall(apply_controls, remote, {
    throttle = 0.03,
    reverser = 1,
    brake = 0,
    independent_brake = 0,
  })
  sleep_for(0.45)
  pcall(apply_safe_stop, remote, DEFAULTS.hold_brake)

  local p1 = select(1, read_position(remote))
  if not ok or not p1 then
    return fallback_axis, "fallback_probe_failed"
  end

  local measured = vector_sub(p1, p0)
  measured.y = 0
  local measured_axis = vector_length(measured) >= 0.20 and normalize(measured) or nil

  if measured_axis and fallback_axis and abs_dot(measured_axis, fallback_axis) < 0.55 then
    return measured_axis, "measured_over_fallback_conflict"
  end
  return measured_axis or fallback_axis, measured_axis and "measured" or "fallback"
end
```

Export:
```lua
sample_heading = sample_heading,
```

### Kandidatenwahl

In `station_dispatch.lua` oder als exportierter Controller-Helper implementieren. Empfehlung: als Controller-Helper exportieren, Dispatcher ruft ihn nur auf.

```lua
local function horizontal_axis(axis)
  if not axis then
    return nil
  end
  return normalize({x = axis.x, y = 0, z = axis.z})
end

local function forward_lateral(position, heading, point)
  local offset = vector_sub(point, position)
  offset.y = 0
  local forward = vector_dot(offset, heading)
  local lateral_signed = heading.x * offset.z - heading.z * offset.x
  local distance = vector_length(offset)
  return forward, lateral_signed, distance
end

local function straight_pair_tolerance(forward_m)
  return math.max(1.75, math.min(3.0, 0.10 * math.max(forward_m or 0, 0)))
end

local function choose_forward_guardrail(candidates, position, heading)
  heading = horizontal_axis(heading)
  if not heading then
    return nil, "missing_heading"
  end

  local forward = {}
  for _, candidate in ipairs(candidates or {}) do
    local s, l, d = forward_lateral(position, heading, candidate.point)
    if s > 0.25 then
      forward[#forward + 1] = {
        candidate = candidate,
        forward_m = s,
        lateral_m = l,
        distance_m = d,
      }
    end
  end
  table.sort(forward, function(a, b)
    if math.abs(a.forward_m - b.forward_m) > 0.5 then
      return a.forward_m < b.forward_m
    end
    return a.distance_m < b.distance_m
  end)

  if #forward == 0 then
    return nil, "no_forward_candidate"
  end
  if #forward == 1 then
    return forward[1].candidate, "single_forward_candidate"
  end

  local a = forward[1]
  local b = forward[2]
  local tol = straight_pair_tolerance(math.min(a.forward_m, b.forward_m))
  local pair_lateral = (a.lateral_m + b.lateral_m) / 2

  if math.abs(a.lateral_m) <= tol and math.abs(b.lateral_m) <= tol then
    return (a.distance_m <= b.distance_m and a.candidate or b.candidate), "straight_pair_nearest"
  end

  if pair_lateral > tol then
    return (a.distance_m >= b.distance_m and a.candidate or b.candidate), "left_curve_farther"
  end

  if pair_lateral < -tol then
    return (a.distance_m <= b.distance_m and a.candidate or b.candidate), "right_curve_nearest"
  end

  return (a.distance_m <= b.distance_m and a.candidate or b.candidate), "mixed_pair_nearest"
end
```

Mathe-Begründung:
- `forward > 0.25m`: echter vorderer Halbraum, aber robust gegen Positionsrauschen.
- `tol = max(1.75, min(3.0, 0.10 * forward))`: unter 1.75m zu empfindlich; über 3m verschmilzt Doppelschiene zu leicht; 0.10 entspricht ca. 5.7 Grad Korridor.
- links/rechts über horizontales Kreuzprodukt relativ zur Zugrichtung.

Dispatcher baut `candidates` aus allen Routen des Schedules:
```lua
{
  point = leg.target,
  entry_index = entry_index,
  route_id = route_id,
  leg_index = leg.index,
}
```

Beim Kaltstart:
- Position lesen.
- Fallback-Achse aus erster/aktueller Route ableiten, falls vorhanden.
- `sample_heading(...)` ausführen.
- `choose_forward_guardrail(...)`.
- `start_entry_index = candidate.entry_index`
- `route_plan.initial_leg_index = candidate.leg_index`
- erster Cycle beginnt bei `start_entry_index`; danach normale Entry-Reihenfolge.

Wenn Heading fehlt oder kein Kandidat vorne liegt:
- keine geometrische Ratefahrt.
- Controller hält und meldet klaren Fehler.

## Pass-through-Regler

### Moving-away Force-Mode

In `run_route_leg(...)`, nach `terminal_buffer_brake_active`, vor `terminal_stop_first_force_mode(...)`:

```lua
if speed_plan_force_mode == "auto" and moving_away_brake_allowed then
  speed_plan_force_mode = "full_brake"
  speed_plan_desired_reverser = state.active_reverser
  planner_reason = "moving_away_from_target"
  state.phase = "tracking"
end
```

Damit können `1oil3.1`-Zustände mit `moving_away_confidence=1.00`, `throttle=1.00`, `speed_plan_force_mode=auto` nicht bleiben.

### Bumpless D-Term

Neue Defaults:

```lua
controller_speed_axis_rebase_alignment = 0.92,
pass_through_brake_suppress_margin_mps = 0.75,
```

`begin_leg(...)` ergänzt:

```lua
controller_speed_initialized = false,
controller_speed_axis = nil,
pass_through_brake_suppressed = false,
```

Controller-Speed-Filter ersetzen:

```lua
local rebase_controller_speed = false
if not state.controller_speed_initialized then
  rebase_controller_speed = true
elseif state.controller_speed_axis and abs_dot(state.controller_speed_axis, motion_axis) < DEFAULTS.controller_speed_axis_rebase_alignment then
  rebase_controller_speed = true
end

if rebase_controller_speed then
  state.controller_speed_mps = speed_toward_target_mps
  state.previous_controller_speed_mps = speed_toward_target_mps
  state.controller_speed_initialized = true
else
  state.previous_controller_speed_mps = state.controller_speed_mps
  state.controller_speed_mps = ema(
    state.controller_speed_mps,
    speed_toward_target_mps,
    DEFAULTS.speed_filter_memory_s,
    dt_s
  ) or speed_toward_target_mps
end
state.controller_speed_axis = motion_axis
```

### Pass-through Brake-Gate

```lua
local function limit_pass_through_effort(leg_mode, force_mode, effort_cmd, speed_error_mps)
  if leg_mode ~= "pass_through" then
    return effort_cmd, false
  end
  if force_mode ~= "auto" then
    return effort_cmd, false
  end
  if speed_error_mps >= DEFAULTS.pass_through_brake_suppress_margin_mps and effort_cmd < 0 then
    return 0, true
  end
  return effort_cmd, false
end
```

Nach `slew_limit_effort(...)`, vor `allocate_effort_to_controls(...)`:

```lua
effort_cmd, state.pass_through_brake_suppressed = limit_pass_through_effort(
  leg.mode,
  speed_plan.force_mode,
  effort_cmd,
  speed_error
)
```

Logging um `pass_through_brake_suppressed=%s` erweitern.

Control-Rationale:
- PID bleibt der normale Regler.
- Der D-Term wird nicht global geschwächt.
- D-State wird bei Messbasiswechsel sauber neu initialisiert.
- Service-Brake unter klarer Zielgeschwindigkeit ist im Pass-through-Auto-Modus verboten.
- Force-Brakes bleiben erlaubt: Moving-away, Reverser-Mismatch, Terminal/Stop-Guidance.

## Editor und Doku

`route_book_editor.lua`:
- Routes-Tab schreibt Primärmodell `from/to/via`.
- Legacy `waypoints` darf gelesen/angezeigt werden.
- Schedules-Tab erlaubt mehrere Entries.
- Entry-Felder: `Station`, `Route`, `Wait`, `Redstone`.
- Route-Auswahl bevorzugt Routes, deren `to` zur Entry-Station passt.
- `Move Up/Move Down` für Entries bleibt sichtbar.

Doku:
- `docs/station-schedules.md`: Entries sind Stationshalte; Routes sind Wege.
- `docs/control-model.md`: Via-Waypoints sind Guardrails, nur Route-Ende ist Terminal.
- `docs/runtime.md`: keine native Schienengraph-API; Graph liegt manuell im Route-Book.

## Tests

Neue/erweiterte Tests:

```sh
lua tests/previews/route_book_graph_preview.lua
lua tests/previews/schedule_multi_stop_preview.lua
lua tests/previews/pass_through_pid_guard_preview.lua
```

Pflichtfälle:
- `from/to/via` erzeugt `from + via + to`.
- Legacy `waypoints` bleibt lesbar.
- `entry.station` wird bevorzugt.
- `route.to` muss zu `entry.station` passen.
- Dispatcher kann `current_station -> station` automatisch eindeutig auflösen.
- Mehrdeutige Auto-Route ist Fehler.
- Schedule-Kaltstart wählt nur Kandidaten vor dem Zug.
- Gerade Doppelschienen-Paarung nimmt nächstes Ziel.
- Linkskurve nimmt weiter entfernten Punkt im Paar.
- Rechtskurve nimmt näheren Punkt im Paar.
- Fehlende Heading/Kandidaten führen zu Hold/Error, nicht Raten.
- Moving-away erzeugt `full_brake`.
- Pass-through-D-Term erzeugt unter Zielgeschwindigkeit keine Service-Brake.
- PLAN24-Tests bleiben grün.

Gesamtlauf:

```sh
luac -p programs/train_controller.lua
luac -p programs/station_dispatch.lua
luac -p programs/route_book_editor.lua
luac -p programs/lib/station_schedule.lua
lua tests/previews/controller_preview.lua
lua tests/previews/test_outside_capture_window.lua
lua tests/previews/test_late_buffer_terminal_stop.lua
lua tests/previews/route_book_graph_preview.lua
lua tests/previews/schedule_multi_stop_preview.lua
lua tests/previews/pass_through_pid_guard_preview.lua
```

## Akzeptanz

- `1oil3.1`-Fehlerform kann nicht mehr auftreten:
  - kein `moving_away_confidence=1.00` mit `speed_plan_force_mode=auto` und `throttle=1.00`
  - keine harte Pass-through-Bremse bei klarer Untergeschwindigkeit
- Zwei Stationen innerhalb eines cyclic Schedule können echte Waits haben.
- Waypoints/Via lösen keine Waits und keine Terminal-Stop-Guidance aus.
- Kaltstart auf richtigem Streckenabschnitt wählt plausiblen vorderen Guardrail.
- Keine Ratefahrt bei fehlender Richtung.
- Legacy Route-Books bleiben kompatibel.
- Editor schreibt neues Primärmodell.
- Bestehende PLAN24-Terminal-Late-Capture-Semantik bleibt intakt.
