# Handoff: Immersive Railroading / OpenComputers Planung nach PLAN25

## Projekt

Arbeitsrepo:

`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`

Wichtig: Die Planungssession ändert keine Dateien. Implementierung passiert normalerweise in einer separaten Agenten-Session über einen Hand-Off-/Prompt-Plan.

Inspect-only / nicht beschreiben:

`~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`

Hauptwelt-Computer:

`~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/HMMM/opencomputers/4e67b7ca-618d-4a67-8372-e46d2879544b`

Wichtige Welt-Dateien liegen dort unter:

`home/immersive_railroading/programs/`

## Grundregeln aus AGENTS.md

- Keine APIs oder Runtime-Felder erfinden.
- IR-/OC-Laufzeit immer aus Code, Logs, Emulator/Preview oder JAR-Befund ableiten.
- PrismLauncher-Instanz und Welt sind inspect-only.
- Produktive Logik bevorzugt in wiederverwendbaren Libs, nicht dupliziert in Editor/Dispatcher.
- Kommentare sollen vor allem das Warum erklären.
- Tests/Checks mit `luac -p` und `lua tests/previews/...`.
- Route-/Schedule-/Controller-Änderungen müssen sehr vorsichtig geplant werden, weil kleine Logikfehler echte Weltfahrten ruinieren können.

## Historischer Stand

### PLAN23

PLAN23 implementierte die Factorio-Schedule-V1-Basis:

- `programs/route_book.lua` bekam das eingefrorene Schema:
  - `AUGMENTS`
  - `STATIONS`
  - `ROUTES`
  - `SCHEDULES`
- Neue Libs:
  - `programs/lib/route_book_store.lua`
  - `programs/lib/augment_registry.lua`
  - `programs/lib/station_schedule.lua`
  - `programs/lib/redstone_io.lua`
  - `programs/lib/term_ui.lua`
- `programs/station_dispatch.lua` wurde echte Produktionsdatei.
- `programs/route_book_editor.lua` wurde mausorientierte Terminal-GUI.
- Detector-IDs sind stabile Referenzen:
  - rohe OC-Adresse nur in `AUGMENTS.DETECTORS[detector_id].address`
  - Stations referenzieren `detector_ids`
- Wait-Semantik:
  - OR zwischen Gruppen
  - AND innerhalb einer Gruppe
- Wagonbezogene Conditions ausschließlich über `detector.info()`.
- Redstone-Outputs stationsseitig:
  - `while_pending`
  - `on_departure_pulse`

Nicht zurückbauen.

### PLAN24

Aus Log `1oil1` kam ein Terminal-Stop-Bug:

- Zug überschoss Terminal-Stop-Ziel.
- `late_buffer_capture_late` aktivierte Stop-/No-Reverse-Pfad.
- Danach gab Controller bei niedriger Geschwindigkeit wieder Vorwärts-Throttle.
- Arrival wurde nie erreicht, weil physischer Buffer nicht in Toleranz war.
- Schedule kam nie bis `schedule_entry_arrived`/Wait.

PLAN24 fixte lokal in `train_controller.lua`:

- Terminal-Late-Capture darf nicht wieder in unkontrolliertes Vorwärtskriechen/Loop kippen.
- `hold`/Stop-first/Buffer-settle/Reverse-Korrektur wurden ergänzt.
- Late-buffer station arrival wurde abgesichert.
- Terminal-Stop-Logik ist jetzt empfindlich, aber grundsätzlich funktional.

Nicht zurückbauen.

### PLAN25

Aus `1oil3.1` kam die größere Architektur-Erkenntnis:

- Waypoints waren vorher faktisch “Laps” einer statischen Route.
- Nach Restart oder nach einem Stationshalt konnte der nächste statische Waypoint unplausibel sein.
- Waypoints sollen nicht weiche Stationshalte sein, sondern Guardrails, damit der Zug über problematische Gleisabschnitte geführt wird.
- Für Factorio-artige Fahrpläne braucht ein Schedule mehrere echte Stationshalte, nicht “eine Route pro Schedule”.

PLAN25 wurde implementiert.

Kernmodell jetzt:

- Schedule-Einträge sind Stationshalte.
- Routes sind gerichtete Kanten:
  - `from`
  - `to`
  - `via`
- `via` sind Guardrails, keine Stops.
- `entry.station` ist die Ziel-/Wait-Station.
- Dispatcher hält `current_station_id`.
- Wenn `entry.route` fehlt oder automatisch gewählt werden muss, wird Route von `current_station_id` nach `entry.station` aufgelöst.
- Cold-start/Restart nutzt schedule-globalen Guardrail-Picker:
  - Kandidaten vor dem Zug
  - Richtung via gespeicherte/fallback Axis plus Probe
  - Doppelschienen-Heuristik
  - `initial_leg_index` startet Route mitten im Guardrail-Pfad, wenn nötig.

Pass-through-Regler nach PLAN25:

- Primärfix: bumpless D-Term bei Axis-/Leg-Wechsel.
- Safety-Fix: Moving-away darf nicht weiter `auto` mit Throttle fahren, sondern wird `full_brake`.
- Actuator-Sanity: Pass-through darf bei klarer Untergeschwindigkeit nicht durch negativen D-Ausreißer Service-Brake geben.
- Das war bewusst mehr als PID-Tuning, weil der Fehler aus Zustands-/Messachsenwechseln kam, nicht nur aus schlechten PID-Werten.

Nicht zurückbauen.

## Aktuelle wichtige Dateien

Unbedingt zuerst lesen:

1. `AGENTS.md`
2. `docs/plans/factorio-schedule-v1/PLAN25.md`
3. `docs/plans/factorio-schedule-v1/PLAN24.md`
4. `docs/plans/factorio-schedule-v1/PROMPT1.md`
5. `programs/train_controller.lua`
6. `programs/station_dispatch.lua`
7. `programs/lib/station_schedule.lua`
8. `programs/route_book.lua`
9. relevante Preview-Tests unter `tests/previews/`

Aktuelle relevante Tests existieren:

- `tests/previews/controller_preview.lua`
- `tests/previews/test_outside_capture_window.lua`
- `tests/previews/test_late_buffer_terminal_stop.lua`
- `tests/previews/route_book_graph_preview.lua`
- `tests/previews/schedule_multi_stop_preview.lua`
- `tests/previews/pass_through_pid_guard_preview.lua`
- `tests/previews/station_dispatch_preview.lua`
- `tests/previews/station_schedule_preview.lua`

## Aktueller Welt-Route-Book-Stand

In der Hauptwelt ist das Öl-Schedule-Modell nach PLAN25 etwa so:

Stations:

- `1_oil_ref`
  - Ölraffinerie
  - Koordinaten ungefähr `x=-50, y=69, z=402`
- `2_oil_frack`
  - Fracking Tower
  - Koordinaten ungefähr `x=658, y=68, z=-458`

Routes:

- `1_oil_1`
  - `from = "1_oil_ref"`
  - `to = "2_oil_frack"`
  - `cruise_kmh = 65`
  - `profile = "conservative"`
  - `stop_buffer_m = 6`
  - `via` enthält Guardrails Richtung Frack.
- `2_oil_1`
  - `from = "2_oil_frack"`
  - `to = "1_oil_ref"`
  - gleiche Fahrparameter
  - `via` enthält Rückweg-/Loop-Guardrails Richtung Raffinerie.

Schedule:

- `SCHEDULES["1_oil_1"]`
  - `cyclic = true`
  - Entry 1:
    - route `1_oil_1`
    - station `2_oil_frack`
    - wait `time_passed = 10`
  - Entry 2:
    - route `2_oil_1`
    - station `1_oil_ref`
    - wait `time_passed = 10`

Bedeutung von `station` im Schedule:

- `station` ist die Station, an der der Zug ankommen und warten soll.
- `route` ist nur der Weg dorthin.
- `via` sind nur Guardrails unterwegs.
- `station` ist kein Detector-Scope und kein Redstone-Output selbst, sondern die semantische Haltestelle für Wait-/Departure-Logik.

## Log-Historie und Interpretation

### `1oil1`

Alter PLAN24-Bug.

Befund:

- Terminal-Leg spät gefangen.
- Stop-Ziel bereits überfahren.
- Physischer Buffer passte nicht.
- Controller gab wieder Throttle.
- Zug loopte weg.
- Kein `schedule_entry_arrived`.

Status:

- Durch PLAN24 adressiert.
- Nicht erneut als aktueller Bug behandeln, solange neuer Log nicht dasselbe nach PLAN24 zeigt.

### `1oil3`

Zwischenbeobachtung.

User sah:

- Ein Waypoint vor Station Vollgas.
- Danach Bremsung.
- Danach Bremsung aufgegeben und normale Fahrt.

Spätere Einordnung:

- Teilweise normales Verhalten, weil alte statische Route erst nächsten Waypoint “abarbeiten” musste.
- Architekturproblem lag in Waypoint-/Schedule-Modell.
- Führte zu PLAN25.

### `1oil3.1`

Wichtiger Architektur-Log.

User ließ zwei Runden laufen:

- Start vor Ölraffinerie.
- Am Ende stoppte Zug an `2_oil_frack`, wartete korrekt, fuhr wieder.
- In zweitem Durchgang bremste er zu viel, als seien Waypoints weiche Stationen.

Befund:

- Terminal-Stop/Wait nach PLAN24 funktionierten grundsätzlich.
- Statisches Waypoint-Modell war falsch.
- Pass-through-Regler hatte Moving-away-/D-Term-Probleme.

Status:

- Durch PLAN25 adressiert.

### `1oil4`

Nach PLAN25.

User zuerst:

- Fix scheint zu funktionieren.
- Bei `oil_frack` blieb Zug scheinbar in Stillstand-Coast.
- Manuelle Intervention half.

Danach Korrektur des Users:

- Zug war nach `oil_frack`.
- Expected: Route 2 zur Raffinerie.
- Er kam an Raffinerie, wartete, fuhr weiter.
- Er kam via Route 1 wieder an `oil_frack` und konnte scheinbar nicht weiter.
- Später: vermutlich Micro-Crash/OC-Problem durch volle virtuelle Festplatte mit Logs.
- User sagte explizit: “Vergiss es. Es war möglicherweise ein Micro-Crash durch das Überfüllen der virtuellen Festplatte mit Logs. Es ist kein Problem mit dem Programm, nur mit OC selbst. PLAN25 wurde implementiert übrigens.”

Eigene Log-Inspektion zeigte:

- Sichtbarer `1oil4`-Teil enthält:
  - `schedule_start_guardrail`
  - `schedule_entry_start entry=2 route=2_oil_1 station=1_oil_ref`
  - `route_start route_name=2_oil_1`
  - sauberen Terminal-Stop an `1_oil_ref`
  - `schedule_entry_arrived`
  - Wait-Ticks
- Sichtbarer Log enthielt nicht sauber den vermuteten späteren `oil_frack`-Fehlerabschnitt.
- `aborted_by_user` ist laut User meist nur manuelles Stoppen, damit Log nicht weiterwächst.

Status:

- Nicht als Programm-Bug behandeln.
- Wenn dazu wieder gearbeitet wird: frischen kurzen Log verlangen/analysieren.
- Bessere nächste Absicherung wäre Log-Rotation oder Log-Limit.

## Aktuelle konkrete offene Risiken

### 1. Log-Füllung / OC-Disk

Das ist der einzige klare offene praktische Risikopunkt.

Problem:

- Controller und Dispatcher loggen sehr ausführlich.
- OpenComputers-Dateisystem kann durch lange Logs volllaufen.
- Dadurch können Micro-Crashs oder seltsames Runtime-Verhalten entstehen.
- Das kann echte Programmfehler vortäuschen.

Aktuelle Logger-Situation:

- `train_controller.lua` hat eigenen `make_logger`, `emit_line`, `resolve_log_path`.
- `station_dispatch.lua` hat eigene einfachere Logger-Funktionen.
- Beide öffnen/append/write pro Zeile.
- Keine Rotation.
- Keine Größenbegrenzung.
- `train_controller.lua` meldet Schreibfehler defensiv nach stderr.
- `station_dispatch.lua` ignoriert fehlgeschlagene Writes eher still.

Naheliegende spätere Planung:

- gemeinsame Lib `programs/lib/log_writer.lua`
- Rotation nach Größe
- Default-Limit bei `--log`
- kompatible CLI:
  - `--log`
  - `--log=<path>`
  - optional `--log-max-kb`
  - optional `--log-max-files`
- stdout weiter unverändert.
- Bei Schreibfehlern File-Logging deaktivieren, Programm nicht abbrechen.

Noch nicht implementiert.

### 2. Regressionsgefahr bei Schedule/Route-Semantik

Bei neuen Features muss erhalten bleiben:

- Schedule entry = Halt.
- Route = gerichteter Weg.
- Via = Guardrail.
- `entry.station` ist Ziel.
- Route `to` muss zur Zielstation passen.
- Multi-stop cyclic Schedule muss funktionieren.
- Legacy `waypoints` darf lesbar bleiben, solange vorgesehen.

### 3. Regressionsgefahr bei Controller Safety

Nicht entfernen/vereinfachen ohne starke neue Beweise:

- Terminal-Late-Capture-Hold/Buffer-Settle aus PLAN24.
- Moving-away-Full-Brake.
- Bumpless D-Term.
- Pass-through-Brake-Suppression bei klarer Untergeschwindigkeit.
- `initial_leg_index`.

## Gute Checks bei fast jeder Änderung

Syntax:

```sh
luac -p programs/train_controller.lua
luac -p programs/station_dispatch.lua
luac -p programs/route_book_editor.lua
luac -p programs/lib/station_schedule.lua