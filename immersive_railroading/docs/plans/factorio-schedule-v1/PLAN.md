# Factorio-Fahrplan V1 Mit Mausorientierter Stations-GUI, Detector-Registry Und Redstone-I/O

## Ziel
Diese Ausbaustufe ergänzt den bestehenden Bewegungscontroller um eine eigenständige Stations- und Fahrplanschicht nach Factorio-Vorbild, ohne die Fahrdynamik in `programs/train_controller.lua` neu zu entwerfen.

V1 umfasst:
- ein erweitertes `programs/route_book.lua`
- einen eigenständigen Editor `programs/route_book_editor.lua`
- einen Dispatcher `programs/station_dispatch.lua`
- Detector-Registry, Schedule-Logik und Redstone-I/O als Libs unter `programs/lib/`
- Vorschau-/Validierungstests

Nicht-Ziele:
- keine Junction-/Graph-/Tag-Routing-Implementierung
- keine Blockreservierungen
- kein Redstone-Input als Wait-Bedingung
- keine whole-train-Wagenliste über `consist()`
- kein Redesign der lokalen Fahrphysik

## Verifizierte Randbedingungen
- `programs/train_controller.lua` exportiert bereits:
  - `load_route_book`
  - `build_named_route_plan`
  - `execute_route_plan`
- Der bestehende Controller ignoriert zusätzliche Top-Level-Metadaten in `route_book.lua`, solange `STATIONS` und `ROUTES` intakt bleiben.
- JAR- und Laufzeitbefund:
  - `CommonAPI.info()` liefert wagenbezogene Felder
  - `CommonAPI.consist()` liefert Aggregate plus `locomotives`, aber keine vollständige Wagenliste
  - `ir_train_overhead` liefert `event_name, net_address, augment_type, stock_uuid`
- Für wagenbezogene Wait-Conditions ist deshalb `ir_augment_detector.info()` der belastbare Pfad.
- OpenComputers-Redstone-I/O ist lokal bestätigt:
  - `component.redstone`
  - `getInput`
  - `getOutput`
  - `setOutput`

## Datenmodell
`programs/route_book.lua` liefert kanonisch:

```lua
return {
  AUGMENTS = {
    DETECTORS = {
      ["mine_front"] = {
        address = "7f3a2c10-aaaa-bbbb-cccc-1234567890ab",
        label = "Mine Front",
        sort_order = 10
      },
      ["unload_rear"] = {
        address = "8e4b3d21-bbbb-cccc-dddd-2345678901bc",
        label = "Unload Rear",
        sort_order = 20
      }
    }
  },

  STATIONS = {
    ["1"] = {
      x = 427, y = 64, z = -148,
      display_name = "Mine Load",
      detector_ids = {"mine_front"},
      redstone_outputs = {
        ["loader"] = {
          side = "north",
          strength = 15,
          active_high = true
        },
        ["departure"] = {
          side = "south",
          strength = 15,
          active_high = true,
          pulse_ticks = 20
        }
      }
    },
    ["2"] = {
      x = 238, y = 64, z = -77,
      display_name = "Base Unload",
      detector_ids = {"unload_rear"},
      redstone_outputs = {}
    }
  },

  ROUTES = {
    ["1_zu_2"] = {
      waypoints = {
        "1",
        {x = 398, y = 64, z = -210},
        "2"
      },
      cruise_kmh = 55,
      stop_buffer_m = 3,
      profile = "fast"
    }
  },

  SCHEDULES = {
    ["ore_loop"] = {
      cyclic = true,
      entries = {
        {
          route = "1_zu_2",
          wait = {
            groups = {
              {
                {
                  type = "cargo_percent",
                  scope = "station_any_detector",
                  comparator = "<=",
                  value = 5,
                  redstone = {
                    output = "loader",
                    mode = "while_pending"
                  }
                },
                {
                  type = "inactivity",
                  seconds = 3
                }
              },
              {
                {
                  type = "time_passed",
                  seconds = 30,
                  redstone = {
                    output = "departure",
                    mode = "on_departure_pulse"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

Top-Level-Reihenfolge:
- `AUGMENTS`
- `STATIONS`
- `ROUTES`
- `SCHEDULES`

Verantwortlichkeiten:
- `AUGMENTS.DETECTORS[detector_id]` speichert nur `address`, `label`, `sort_order`
- `STATIONS[id]` speichert Stationsdaten, `detector_ids` und `redstone_outputs`
- `ROUTES[name]` bleibt reine Geometrie/Fahrparameter
- `SCHEDULES[name]` enthält die betriebliche Abarbeitungslogik

Invarianten:
- jede `detector_id` in `STATIONS[*].detector_ids` muss in `AUGMENTS.DETECTORS` existieren
- dieselbe `detector_id` darf in höchstens einer Station vorkommen
- jede `address` in `AUGMENTS.DETECTORS[*].address` muss global eindeutig sein
- jede Route, die in einem Schedule verwendet wird, muss mit einer Stations-ID enden
- `redstone_outputs` sind stationslokal benannte Ausgänge
- `redstone.output` in einer Condition muss auf einen Output der Zielstation zeigen

Defaults:
- `display_name` optional, Fallback ist Stations-ID
- `detector_ids` default `{}`
- `cyclic` default `false`
- `profile` default `conservative`

## Wait-Semantik
`wait.groups` ist disjunktive Normalform:
- OR zwischen Gruppen
- AND innerhalb einer Gruppe

Unterstützte Bedingungen:
- `time_passed { seconds }`
- `inactivity { seconds }`
- `passengers { scope, comparator, value }`
- `fluid_percent { scope, comparator, value }`
- `cargo_percent { scope, comparator, value }`

Comparatoren:
- `<`
- `<=`
- `>`
- `>=`
- `==`

`scope` für detectorbasierte Conditions:
- `"station_any_detector"`
- `"station_all_detectors"`
- `{ detector_id = "<detector_id>" }`

Semantik:
- `station_any_detector`: mindestens ein gebundener Detector erfüllt die Bedingung
- `station_all_detectors`: alle gebundenen Detectors erfüllen die Bedingung
- `detector_id`: nur dieser Detector zählt

Metrikquelle:
- `passengers`: `detector.info().passengers`
- `fluid_percent`: `detector.info().fluid_amount / detector.info().fluid_max * 100`
- `cargo_percent`: `detector.info().cargo_percent`

`inactivity`:
- detectorbasiert
- resetet bei materieller Änderung relevanter Wait-Metriken
- Schwellwerte:
  - `cargo_percent`, `fluid_percent` ab `0.5`
  - `passengers` ab `1`

Nicht vorgesehen:
- globale Wagenlisten aus `consist()`
- whole-train-Prozentaggregation
- cargo-item-spezifische Conditions
- redstone-input-basierte Conditions

## Redstone-I/O
Stationsseitige Outputs:
- `STATIONS[id].redstone_outputs[name] = { side, strength, active_high, pulse_ticks? }`

Seitenmenge:
- `bottom`
- `top`
- `back`
- `front`
- `right`
- `left`
- `north`
- `south`
- `west`
- `east`

Condition-Erweiterung:

```lua
redstone = {
  output = "loader",
  mode = "while_pending"
}
```

Erlaubte Modi:
- `while_pending`
- `on_departure_pulse`

Semantik:
- `while_pending`: aktiv, solange mindestens eine referenzierende Condition aktuell `false` ist
- `on_departure_pulse`: pulst genau einmal bei erfolgreicher Wait-Komplettierung und Abfahrt

Polarität:
- `active_high = true`: aktiv = `strength`, inaktiv = `0`
- `active_high = false`: aktiv = `0`, inaktiv = `strength`

Fehlerverhalten:
- unbekannter Output in einer Condition = Validierungsfehler
- fehlendes `component.redstone` bei konfigurierte Outputs = klarer Laufzeitfehler
- Outputs werden beim Start und beim Abbruch/Ende inaktiv gesetzt

## Programme
Neue Programme:
- `programs/route_book_editor.lua`
- `programs/station_dispatch.lua`

Neue Libs:
- `programs/lib/route_book_store.lua`
- `programs/lib/augment_registry.lua`
- `programs/lib/station_schedule.lua`
- `programs/lib/redstone_io.lua`
- `programs/lib/term_ui.lua`

Geänderte Dateien:
- `programs/route_book.lua`
- `programs/install_manifest.lua`
- `programs/train_controller.lua`
- `README.md`
- `docs/README.md`
- `docs/runtime.md`
- `docs/operations/download-and-run.md`
- `docs/signals-and-blocks.md`

Neue Tests:
- `tests/previews/augment_registry_preview.lua`
- `tests/previews/route_book_store_preview.lua`
- `tests/previews/station_schedule_preview.lua`
- `tests/previews/station_dispatch_preview.lua`
- `tests/previews/redstone_io_preview.lua`
- `tests/previews/term_ui_preview.lua`

## Dispatcher
CLI:
- `station_dispatch run <schedule> [--log[=path]]`
- `station_dispatch validate [schedule]`
- `station_dispatch inspect <schedule>`
- `station_dispatch detectors`

Ablauf von `run`:
1. `route_book.lua` laden
2. komplett validieren
3. Schedule suchen
4. jede Entry nacheinander fahren
5. Route mit `build_named_route_plan(...)` bauen
6. Route mit `execute_route_plan(...)` fahren
7. Zielstation aus letztem Stations-Waypoint bestimmen
8. Wait-Loop mit gebundenen Detectors und Redstone-Regeln ausführen
9. bei `cyclic=true` wieder am Anfang beginnen

Runtime:
- Detectoren werden über `component.proxy(address)` gelesen
- Wait-Daten kommen aus `detector.info()`
- `detector.consist()` dient nur Diagnose
- `ir_train_overhead` dient zur Laufzeitzuordnung von `stock_uuid`
- `last_stock_uuid` und `last_seen` werden nicht persistiert

Logging:
- `schedule_start`
- `schedule_entry_start`
- `schedule_entry_arrived`
- `schedule_wait_tick`
- `schedule_wait_complete`
- `schedule_cycle_restart`
- `schedule_complete`
- `detector_overhead_seen`
- `redstone_output_active`
- `redstone_output_inactive`
- `redstone_output_pulse`

## GUI
Primärbedienung:
- Maus

Tastatur nur für:
- Texteingabe
- `Esc`
- `Enter`
- optional `Tab`

Keine Kernbedienung über:
- `j/k`
- Pfeiltasten
- Drag-and-drop

Tabs:
- `Detectors`
- `Stations`
- `Routes`
- `Schedules`
- `Save / Validate`

Visuelle Regeln:
- ausgewählter Eintrag mit `>`
- Hover mit Farb-/Hintergrundwechsel
- Buttons klar sichtbar
- Disabled-Zustände abgeschwächt

### Orientierungsmockups

**Routes**
```text
+----------------------------------------------------------------------------------+
| IR Schedule Editor                                              route_book [*]   |
| [ Detectors ] [ Stations ] [> Routes <] [ Schedules ] [ Save / Validate ]       |
+----------------------------------------------------------------------------------+

+----------------------------------+  +-------------------------------------------+
| Routes                           |  | Route Details                              |
|                                  |  | Name:         [ 1_zu_2                 ]  |
| > 1_zu_2                         |  | Cruise km/h:  [ 55                     ]  |
|   2_zu_1                         |  | Stop buffer:  [ 3                      ]  |
|   yard_loop                      |  | Profile:      [ fast v                 ]  |
|                                  |  |                                           |
| [ + Add ] [ Rename ] [ Delete ]  |  | Waypoints                                  |
|                                  |  | > [1] Station   1   (Mine Load)         |
|                                  |  |   [2] Point     398,64,-210             |
|                                  |  |   [3] Station   2   (Base Unload)       |
|                                  |  |                                           |
|                                  |  | [ + Add ] [ Edit ] [ Delete ]           |
|                                  |  | [ Move Up ] [ Move Down ]               |
+----------------------------------+  +-------------------------------------------+
```

**Detectors**
```text
+----------------------------------------------------------------------------------+
| IR Schedule Editor                                              route_book [*]   |
| [> Detectors <] [ Stations ] [ Routes ] [ Schedules ] [ Save / Validate ]       |
+----------------------------------------------------------------------------------+

+------------------------------------------+  +-----------------------------------+
| Known Detectors                          |  | Detector Details                   |
|                                          |  | ID:           [ mine_front      ] |
| > Mine Front                             |  | Label:        [ Mine Front      ] |
|   Unload Rear                            |  | Address:      7f3a2c10-aaaa-...  |
|   Yard Mid                               |  | Assigned to:  Station 1          |
|                                          |  | Last stock:   9d3f...ab12        |
|   mine_front                             |  | Last seen:    12s ago            |
|   unload_rear                            |  |                                   |
|   yard_mid                               |  | [ Rename ] [ Bind ] [ Unbind ]   |
|                                          |  | [ Move Up ] [ Move Down ]        |
|                                          |  | [ Rescan ]                        |
+------------------------------------------+  +-----------------------------------+
```

**Stations**
```text
+----------------------------------------------------------------------------------+
| IR Schedule Editor                                              route_book [ ]   |
| [ Detectors ] [> Stations <] [ Routes ] [ Schedules ] [ Save / Validate ]       |
+----------------------------------------------------------------------------------+

+----------------------------------+  +-------------------------------------------+
| Stations                         |  | Station Details                            |
|                                  |  | ID:           [ 1                      ]  |
| > 1  Mine Load                   |  | Name:         [ Mine Load              ]  |
|   2  Base Unload                 |  | X:            [ 427                    ]  |
|   3  Yard Wait                   |  | Y:            [ 64                     ]  |
|                                  |  | Z:            [ -148                   ]  |
| [ + Add ] [ Rename ] [ Delete ]  |  |                                           |
|                                  |  | Detectors                                  |
|                                  |  | > Mine Front   mine_front              |
|                                  |  |   Mine Rear    mine_rear               |
|                                  |  |                                           |
|                                  |  | [ Assign ] [ Remove ]                   |
|                                  |  | [ Move Up ] [ Move Down ]               |
|                                  |  |                                           |
|                                  |  | Redstone Outputs                            |
|                                  |  | > loader     north 15 active-high      |
|                                  |  |   departure  south 15 pulse 20         |
|                                  |  | [ + Add ] [ Edit ] [ Delete ]          |
+----------------------------------+  +-------------------------------------------+
```

**Schedules**
```text
+----------------------------------------------------------------------------------+
| IR Schedule Editor                                              route_book [ ]   |
| [ Detectors ] [ Stations ] [ Routes ] [> Schedules <] [ Save / Validate ]       |
+----------------------------------------------------------------------------------+

+--------------------------+ +---------------------------+ +----------------------+
| Schedules                | | Entries                    | | Wait Conditions      |
|                          | |                            | |                      |
| > ore_loop               | | > [1] 1_zu_2 -> Base      | | Group A              |
|   fuel_loop              | |   [2] 2_zu_1 -> Mine      | | > cargo_percent <= 5 |
|                          | |                            | |   output: loader     |
| [ + Add ] [ Rename ]     | | [ + Add ] [ Edit ]        | | Group B              |
| [ Delete ]               | | [ Delete ]                | |   time_passed >= 30s |
|                          | | [ Move Up ] [ Move Down ] | |   pulse: departure   |
+--------------------------+ +---------------------------+ +----------------------+
```

## Validierungsregeln
`AUGMENTS.DETECTORS`:
- `detector_id` nichtleer, ASCII, stabil, eindeutig
- `address` nichtleer und global eindeutig
- `label` nicht leer
- `sort_order` numerisch

`STATIONS`:
- jede ID in `detector_ids` existiert in `AUGMENTS.DETECTORS`
- dieselbe `detector_id` darf nur einer Station zugeordnet sein
- jeder `redstone_outputs`-Name ist stationslokal eindeutig
- `side` muss in der Seitentabelle liegen
- `strength` in `0..15`
- `pulse_ticks > 0`, falls gesetzt

`ROUTES`:
- `waypoints` nicht leer
- String-Wegpunkte müssen existierende Stationen referenzieren
- `cruise_kmh > 0`
- `stop_buffer_m >= 0`
- `profile` nur `conservative` oder `fast`
- wenn in Schedules verwendet: letzter Waypoint muss Stations-ID sein

`SCHEDULES`:
- `entries` nicht leer
- `groups` nicht leer
- Comparatoren nur `<`, `<=`, `>`, `>=`, `==`
- detectorbasierte Conditions nur bei passender Zielstation
- `{ detector_id = ... }` muss an Zielstation gebunden sein
- `redstone.output` muss in `redstone_outputs` der Zielstation existieren
- `redstone.mode` nur `while_pending` oder `on_departure_pulse`

## Doku- und Testpflicht
Zusätzlich zur Implementierung aktualisieren:
- `docs/runtime.md`
- `docs/README.md`
- `docs/operations/download-and-run.md`
- `docs/signals-and-blocks.md`
- `README.md`

Erforderliche Validierung:
- `luac -p` auf allen neuen/geänderten Lua-Dateien
- `lua tests/previews/controller_preview.lua`
- `lua tests/previews/test_outside_capture_window.lua`
- neue Preview-Tests für Registry, Store, Schedule, Dispatcher, Redstone und UI

