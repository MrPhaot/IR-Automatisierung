# Factorio Schedule V1 Prompt

Du arbeitest im Projekt:

`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`

Dein Arbeitsziel ist die Implementierung der Planstufe:

`docs/plans/factorio-schedule-v1/PLAN.md`

Dein unmittelbarer Kontext ist:

`docs/plans/factorio-schedule-v1/HANDOFF.md`

## Wichtige Regeln
- Du darfst nur innerhalb von `/home/mrphaot/Dokumente/lua/minecraft` schreiben.
- Die PrismLauncher-Instanz und die Testwelt sind inspect-only:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`
- Erfinde keine APIs oder Laufzeitfelder.
- Kommentare sollen vor allem das Warum erklären.
- Halte Produktionslogik in wiederverwendbaren Libs, statt Regeln in Editor und Dispatcher zu duplizieren.
- Die GUI ist mausorientiert. Baue keine keyboard-first Oberfläche.
- Speichere rohe OC-Detektoradressen nur einmal in der Detector-Registry.

## Lies in dieser Reihenfolge
1. `AGENTS.md`
2. `docs/plans/factorio-schedule-v1/HANDOFF.md`
3. `docs/plans/factorio-schedule-v1/PLAN.md`
4. `docs/runtime.md`
5. `docs/control-model.md`
6. `docs/signals-and-blocks.md`
7. `docs/operations/download-and-run.md`
8. `programs/train_controller.lua`
9. `programs/route_book.lua`
10. `programs/install_manifest.lua`
11. `tests/previews/controller_preview.lua`
12. `tests/previews/test_outside_capture_window.lua`

## Verifizierte technische Basis
- `programs/train_controller.lua` exportiert:
  - `load_route_book`
  - `build_named_route_plan`
  - `execute_route_plan`
- Zusätzliche Top-Level-Schlüssel im `route_book.lua` sind mit dem bestehenden Controller kompatibel, solange `STATIONS` und `ROUTES` korrekt bleiben.
- IR-Befund:
  - `CommonAPI.info()` liefert wagenbezogene Felder
  - `CommonAPI.consist()` liefert keine vollständige Wagenliste
  - `ir_train_overhead` liefert `event_name, net_address, augment_type, stock_uuid`
- OC-Befund:
  - `component.redstone`
  - `getInput`
  - `getOutput`
  - `setOutput`

## Implementiere genau das
1. Erweitere `programs/route_book.lua` auf das eingefrorene Schema mit:
   - `AUGMENTS`
   - `STATIONS`
   - `ROUTES`
   - `SCHEDULES`
2. Ergänze Libs unter `programs/lib/`:
   - `route_book_store.lua`
   - `augment_registry.lua`
   - `station_schedule.lua`
   - `redstone_io.lua`
   - `term_ui.lua`
3. Implementiere `programs/station_dispatch.lua` als echte Produktionsdatei:
   - `run`
   - `validate`
   - `inspect`
   - `detectors`
4. Implementiere `programs/route_book_editor.lua` als mausorientierte Terminal-GUI.
5. Nutze Detector-IDs als stabile Referenzen:
   - `AUGMENTS.DETECTORS[detector_id].address`
   - `STATIONS[*].detector_ids`
   - `scope = { detector_id = "..." }`
6. Implementiere Wait-Semantik exakt als DNF:
   - OR zwischen Gruppen
   - AND innerhalb einer Gruppe
7. Werte wagonbezogene Conditions ausschließlich über `detector.info()` aus.
8. Implementiere stationsseitige Redstone-Outputs:
   - `while_pending`
   - `on_departure_pulse`
9. Ergänze die Doku:
   - `README.md`
   - `docs/README.md`
   - `docs/runtime.md`
   - `docs/operations/download-and-run.md`
   - `docs/signals-and-blocks.md`
   - `docs/station-schedules.md`
10. Ergänze Preview-Tests für Registry, Store, Schedule, Dispatcher, Redstone und UI.

## Nicht tun
- keine doppelte Detector-Station-Relation
- keine rohe OC-Adresse mehrfach als Referenz speichern
- keine wagonbezogenen Conditions über `ir_remote_control.consist()`
- keine Junction-/Graph-/Block-Implementierung
- kein Redstone-Input in V1
- keine GUI, die primär über `j/k` oder Pfeile bedient wird
- kein Drag-and-drop als Pflichtinteraktion

## GUI-Richtung
Orientiere dich an den Mockups in:
- `docs/plans/factorio-schedule-v1/PLAN.md`
- `docs/plans/factorio-schedule-v1/HANDOFF.md`

Verpflichtende Richtung:
- Tabs:
  - `Detectors`
  - `Stations`
  - `Routes`
  - `Schedules`
  - `Save / Validate`
- ausgewählter Eintrag mit `>`
- sichtbare Buttons für `Add`, `Edit`, `Delete`, `Move Up`, `Move Down`
- Maus als Primärbedienung
- Tastatur nur für Textinput, `Esc`, `Enter`, optional `Tab`

## Validierung
Führe nach der Implementierung mindestens aus:
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

## Abschlussbericht
Wenn du fertig bist, berichte knapp:
- welche produktiven Dateien hinzugekommen oder geändert wurden
- welche Tests und Syntaxchecks grün sind
- welche Laufzeitanahmen weiter nur über JAR/Log und nicht in der Welt verifiziert sind
