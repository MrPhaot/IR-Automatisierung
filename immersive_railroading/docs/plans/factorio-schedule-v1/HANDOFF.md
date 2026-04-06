# Factorio Schedule V1 Handoff

## Status
- Repo root:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- Diese Planstufe ist noch nicht implementiert.
- Dieses Handoff friert die Architektur- und Randbedingungen für die nächste Implementierungssession ein.
- Am Produktionscode wurde für dieses Handoff nichts geändert.

## Wichtige Pfade
- Projekt:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- Produktiver Controller:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua`
- Route-Book:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book.lua`
- Geplantes Handoff-Paket:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/plans/factorio-schedule-v1/`
- PrismLauncher-Instanz, nur zum Inspizieren:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
- Testwelt, nur zum Inspizieren:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`

## Verifizierte Fakten
- `programs/train_controller.lua` exportiert bereits:
  - `load_route_book`
  - `build_named_route_plan`
  - `execute_route_plan`
- `load_route_book()` initialisiert aktuell nur `STATIONS` und `ROUTES`, ignoriert aber zusätzliche Top-Level-Schlüssel nicht aktiv weg.
- `build_named_route_plan(...)` arbeitet nur mit `route_book.ROUTES[*]` und `route_book.STATIONS`.
- Zusätzliche Top-Level-Metadaten wie `AUGMENTS` oder `SCHEDULES` sind deshalb kompatibel, solange bestehende Route-/Station-Semantik intakt bleibt.

## Verifizierter IR-Befund
Aus lokaler JAR- und Laufzeitanalyse:
- Karte und Detector nutzen beide `CommonAPI`
- `CommonAPI.info()` liefert wagenbezogene Felder
- `CommonAPI.consist()` liefert Aggregate plus `locomotives`, aber keine vollständige Wagenliste
- `ir_train_overhead` liefert:
  - `event_name`
  - `net_address`
  - `augment_type`
  - `stock_uuid`

Konsequenz:
- wagonbezogene Wait-Conditions müssen über Detector-`info()` laufen
- `consist()` ist nicht ausreichend für Whole-Train-Wait-Logik

## Verifizierte Runtime-Felder
Aus realen Logs vorhanden oder bestätigt:
- `cargo_percent`
- `cargo_size`
- `fluid_amount`
- `fluid_max`
- `passengers`
- `weight_kg`
- `total_traction_N`

## Verifizierter OpenComputers-Redstone-Befund
Aus lokaler OC-JAR:
- `component.redstone`
- `getInput`
- `getOutput`
- `setOutput`

Konsequenz:
- Stationscomputer kann Output-only-Redstone in V1 zuverlässig ansteuern
- Redstone-Input bleibt bewusst außerhalb dieses Scopes

## Eingefrorenes Datenmodell
`route_book.lua` soll vier Top-Level-Bereiche tragen:
- `AUGMENTS`
- `STATIONS`
- `ROUTES`
- `SCHEDULES`

Detector-Adressregel:
- rohe OC-Adresse wird genau einmal gespeichert:
  - `AUGMENTS.DETECTORS[detector_id].address`
- alle anderen Referenzen laufen über `detector_id`

Station-Detector-Regel:
- `STATIONS[id].detector_ids` ist die einzige Stationsbindung
- keine umgekehrte Stationsreferenz im Detector

Stations-Redstone-Regel:
- `STATIONS[id].redstone_outputs[name]` definiert benannte Ausgänge
- Wait-Conditions referenzieren nur den Output-Namen

## Eingefrorene Wait-Semantik
- `wait.groups` ist DNF:
  - OR zwischen Gruppen
  - AND innerhalb einer Gruppe
- V1-Condition-Typen:
  - `time_passed`
  - `inactivity`
  - `passengers`
  - `fluid_percent`
  - `cargo_percent`
- Detector-Scope:
  - `station_any_detector`
  - `station_all_detectors`
  - `{ detector_id = "<id>" }`

## Eingefrorene Redstone-Semantik
- Condition kann optional haben:

```lua
redstone = {
  output = "loader",
  mode = "while_pending"
}
```

Zulässige Modi:
- `while_pending`
- `on_departure_pulse`

Semantik:
- `while_pending`: aktiv, solange eine referenzierende Condition noch nicht erfüllt ist
- `on_departure_pulse`: ein einmaliger Puls beim erfolgreichen Verlassen des Wait-Zustands

## Geplante Produktionsdateien
Neu:
- `programs/route_book_editor.lua`
- `programs/station_dispatch.lua`
- `programs/lib/route_book_store.lua`
- `programs/lib/augment_registry.lua`
- `programs/lib/station_schedule.lua`
- `programs/lib/redstone_io.lua`
- `programs/lib/term_ui.lua`

Ändern:
- `programs/route_book.lua`
- `programs/install_manifest.lua`
- `programs/train_controller.lua`
- `README.md`
- `docs/README.md`
- `docs/runtime.md`
- `docs/operations/download-and-run.md`
- `docs/signals-and-blocks.md`

Neu unter `tests/previews/`:
- `augment_registry_preview.lua`
- `route_book_store_preview.lua`
- `station_schedule_preview.lua`
- `station_dispatch_preview.lua`
- `redstone_io_preview.lua`
- `term_ui_preview.lua`

## Acceptance-Kriterien
- `route_book.lua` unterstützt das neue Schema inklusive `AUGMENTS` und `SCHEDULES`
- Dispatcher kann einen Schedule validieren und abfahren
- Dispatcher kann Detector-gebundene Wait-Conditions auswerten
- Dispatcher kann konfigurierte Redstone-Outputs während des Wartens und bei Abfahrt ansteuern
- Editor kann Detectors, Stations, Routes, Schedules und Redstone-Outputs pflegen
- rohe OC-Adressen werden nicht redundant gespeichert
- GUI ist mausorientiert
- bestehende Controller-Preview-Tests bleiben grün
- neue Preview-Tests decken Registry, Store, Schedule, Dispatcher, Redstone und UI-Helfer ab

## Verbindliche GUI-Richtung
Die folgenden ASCII-Beispiele sind keine lose Inspiration, sondern die gewünschte visuelle Richtung:

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

## Validierungsbefehle für die Umsetzung
- `luac -p programs/train_controller.lua`
- `luac -p programs/route_book_editor.lua`
- `luac -p programs/station_dispatch.lua`
- `luac -p programs/lib/route_book_store.lua`
- `luac -p programs/lib/augment_registry.lua`
- `luac -p programs/lib/station_schedule.lua`
- `luac -p programs/lib/redstone_io.lua`
- `luac -p programs/lib/term_ui.lua`
- `lua tests/previews/controller_preview.lua`
- `lua tests/previews/test_outside_capture_window.lua`
- `lua tests/previews/augment_registry_preview.lua`
- `lua tests/previews/route_book_store_preview.lua`
- `lua tests/previews/station_schedule_preview.lua`
- `lua tests/previews/station_dispatch_preview.lua`
- `lua tests/previews/redstone_io_preview.lua`
- `lua tests/previews/term_ui_preview.lua`

## Risiken
- OpenOS-Maus- und GPU-Verfügbarkeit kann zwischen Testwelt und Zielrechner variieren
- UI muss mit degradierten Terminalgrößen noch lesbar bleiben
- `ir_train_overhead` ist hilfreich für Zuordnung, aber nicht die einzige Wahrheit für persistente Konfiguration
- Detector-basierte Conditions hängen an realer Stationsplatzierung und Wagenüberfahrt über dem Augment

## Unbedingt nicht tun
- keine doppelte Detector-Station-Relation
- keine rohe OC-Adresse mehrfach als Referenz speichern
- keine wagonbezogenen Conditions über `ir_remote_control.consist()`
- keine keyboard-first GUI
- keine Junction-/Graph-/Block-Implementierung in dieser Stufe

## Kurzfassung für den nächsten Agenten
Baue die Stations- und Schedule-Schicht oberhalb des vorhandenen Controllers. Nutze Detector-IDs als stabile Referenzen, speichere rohe Adressen nur in der Detector-Registry, werte wagonbezogene Wait-Conditions über `detector.info()` aus und implementiere Redstone-Output als optionale Stationsfunktion. Die GUI ist mausorientiert und soll sich an den Mockups oben orientieren.
