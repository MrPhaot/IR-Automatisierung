```markdown
Du arbeitest im Projekt:

`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`

Du setzt die Implementierung nach PLAN24 fort. PLAN24 ist bereits implementiert und darf nicht zurückgebaut werden.

Arbeitsziel:

`docs/plans/factorio-schedule-v1/PLAN25.md`

## Lies in dieser Reihenfolge
1. `AGENTS.md`
2. `docs/plans/factorio-schedule-v1/PLAN25.md`
3. `docs/plans/factorio-schedule-v1/PLAN24.md`
4. `programs/train_controller.lua`
5. `programs/station_dispatch.lua`
6. `programs/lib/station_schedule.lua`
7. `programs/route_book_editor.lua`
8. `programs/route_book.lua`
9. `tests/previews/controller_preview.lua`
10. `tests/previews/test_late_buffer_terminal_stop.lua`
11. Hauptwelt-Log:
   `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/HMMM/opencomputers/4e67b7ca-618d-4a67-8372-e46d2879544b/home/immersive_railroading/programs/1oil3.1`

## Kontext
`1oil3.1` zeigt:
- Terminal-Stop und Wait funktionieren nach PLAN24.
- Nach Schedule-Restart fährt der Zug teils vom Ziel weg und gibt trotzdem Throttle.
- Pass-through-D-Term bremst teils hart, obwohl der Zug unter Zielgeschwindigkeit ist.
- Das größere Architekturproblem ist: Routes sind noch statische Waypoint-Runden statt Factorio-artige Kanten zwischen Stationshalten.

## Implementiere
1. Neues Route-Primärmodell `from/to/via`, Legacy `waypoints` kompatibel halten.
2. Neues Schedule-Primärmodell mit `entry.station`.
3. Dispatcher mit `current_station_id` und Auto-Route-Auflösung `from -> to`.
4. Schedule-globalen Kaltstart-/Guardrail-Picker:
   - nur Waypoints vor dem Zug
   - Richtung aus gespeicherter Achse plus Probe-Anrollen
   - Doppelschienen-Heuristik nach PLAN25
   - kein Raten bei fehlender Richtung
5. Controller:
   - Route-Plan kann bei `initial_leg_index` starten.
   - Moving-away setzt `full_brake`.
   - Bumpless D-Term bei Leg-/Achsenwechsel.
   - Pass-through-Brake-Gate unter Zielgeschwindigkeit.
6. Editor und Doku auf `from/to/via` und Multi-Entry-Station-Schedules aktualisieren.
7. Tests aus PLAN25 hinzufügen und alle dort genannten Checks ausführen.

## Nicht tun
- Keine native IR-Schienen-Topologie erfinden.
- Keine Junction-/Block-Reservierung.
- Keine Redstone-Input-Features.
- PLAN24-Terminal-Late-Capture nicht zurückbauen.
- PID-Fix nicht durch globale Cruise-Speed-Reduktion ersetzen.
- Keine rohe Detector-Adresse mehrfach speichern.

## Akzeptanz
- `moving_away_confidence=1.00` darf nicht mit `speed_plan_force_mode=auto` und `throttle=1.00` weiterfahren.
- Pass-through darf bei klarer Untergeschwindigkeit nicht service-braken, außer ein Force-Mode greift.
- Mehrere Stationshalte pro cyclic Schedule funktionieren.
- Via-Punkte sind Guardrails, keine Stops.
- Legacy Route-Books bleiben lesbar.
- Alle PLAN25-Checks sind grün.

## Abschlussbericht
Berichte knapp:
- geänderte produktive Dateien
- neue/geänderte Tests
- alle ausgeführten Checks
- welche Annahmen erst in der Hauptwelt validiert sind oder noch validiert werden müssen
```