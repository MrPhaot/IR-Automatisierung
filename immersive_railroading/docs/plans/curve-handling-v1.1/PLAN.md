# Curve Handling V1 Final Handoff: Deterministischer Terminal-Halt im gemeinsamen Route-Runner

## Zusammenfassung
- Dieser Plan ersetzt den aktuellen Stand in [PLAN.md](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/plans/curve-handling-v1/PLAN.md) vollständig.
- Fokus ist nur das verbleibende Kernproblem: der letzte Halt im `route`-Pfad ist noch nicht reproduzierbar genug. `goto` und `goto --via` werden automatisch mitbehoben, weil sie denselben Route-/Leg-Runner nutzen.
- Die Streckenführung bis zum letzten Leg ist weitgehend richtig. Der Fix sitzt im Terminal-Leg, besonders im Übergang `route_guidance -> stop_guidance` und im Endspiel nach Eintritt in `guidance_mode=stop`.
- Ziel ist ein reproduzierbarer gepufferter Halt für beide Profile:
  - `fast` darf kleine sichere Overshoots kontrolliert zurückholen
  - `conservative` darf sichtbare Undershoots nicht mehr kommentarlos akzeptieren
  - Erfolg wird nur noch freigegeben, wenn Stop-Target und physischer Buffer beide passen

## Kontext, der im Handoff enthalten sein muss
- Projektwurzel: `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- Schreibbereich: nur `/home/mrphaot/Dokumente/lua/minecraft`
- Save/PrismLauncher sind inspect-only:
  - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
  - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`
- Produktionsdatei bleibt ausschließlich [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua)
- Vor jeder Implementation zuerst lesen:
  - [runtime.md](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/runtime.md)
  - [control-model.md](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/control-model.md)
  - [train_controller.lua](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua)
- Reale Logs zuerst lesen, nicht Screenshots. Wichtig für diese Phase:
  - `path_test16.log`
  - `path_test17.log`
- Wichtige bestätigte Implementationsfakten im aktuellen Code:
  - gemeinsamer Route-Runner für `route`, `goto`, `goto --via`
  - `guidance_mode=route|stop`
  - `terminal_stop_target`
  - `terminal_brake_snapshot_mps2`
  - `terminal_buffer_brake_active`
  - `buffer_settle_active`
  - `physical_buffer_error`
  - `terminal_success_consistent`
- Der Logger ist bereits stark genug. Kein Logging-Redesign planen.

## Aktuelle Diagnose
- Das Problem ist nicht mehr Kurvenführung vor dem letzten Leg, nicht OpenOS-Argumente, nicht Deployment-Mismatch und nicht fehlende Waypoints.
- `path_test17.log` zeigt zwei komplementäre Fehlerbilder im gleichen Terminalsystem:
  - `fast` mit `stop_buffer_m=6` überschießt trotz aktivem `terminal_buffer_brake`
  - `conservative` mit `stop_buffer_m=6` endet zu früh mit `arrived_within_v1_limit` bei `physical_distance=7.83m` und `physical_buffer_error=1.83m`
- Hauptursache:
  - Das Terminal-Endspiel ist asymmetrisch
  - Vorwärts-Nachziehen und Erfolgskriterium greifen nicht sauber zusammen
  - Kleine sichere Overshoots haben keinen engen kontrollierten Reverse-Korridor
  - `terminal_success_consistent` ist zu grob und trennt Stop-Target-Konsistenz und physische Buffer-Konsistenz nicht sauber

## Implementierungsplan
- **Unverändert lassen**
  - Keine Änderung an CLI, Route-Book-Schema oder Waypoint-Semantik
  - Keine neue automatische Gleisfindung
  - Keine neue Spezialbehandlung nur für `goto`
  - Keine Änderungen an Pass-through-Legs, außer wenn zwingend für den Eintritt in den Terminal-Leg nötig
  - Kein Logger-Umbau

- **Terminal-Erfolg in zwei explizite Prüfungen aufteilen**
  - Die bestehende grobe Konsistenzprüfung nicht mehr als alleinige Wahrheitsquelle verwenden
  - Stattdessen zwei Teilprüfungen führen:
    - `terminal_success_stop_ok`
      Bedeutung: Halt ist relativ zu `terminal_stop_target` plausibel
    - `terminal_success_physical_ok`
      Bedeutung: physische Distanz zum Ziel passt plausibel zu `stop_buffer_m`
  - `terminal_success_consistent` wird dann ausschließlich als `stop_ok and physical_ok` abgeleitet
  - `arrived_at_target` und `arrived_within_v1_limit` nur erlauben, wenn beide Teilprüfungen `true` sind

- **Terminal-Endspiel in explizite Settle-Modi gliedern**
  - Im Terminal-Leg nach Eintritt in `guidance_mode=stop` die Entscheidung in drei exklusive Modi aufteilen:
    - `buffer_settle_mode=none`
    - `buffer_settle_mode=forward`
    - `buffer_settle_mode=reverse`
  - `final_forward_crawl` darf nicht parallel als eigener konkurrierender Endmodus bestehen
  - Umsetzungsvorgabe:
    - `final_forward_crawl` in `buffer_settle_mode=forward` integrieren oder eindeutig darunter subsumieren
    - niemals gleichzeitig `buffer_settle_active` und unabhängiges `final_forward_crawl`

- **`conservative`-Undershoot aktiv korrigieren**
  - Wenn der Zug nach `stop_guidance` noch vor dem Stop-Target steht:
    - positiver Stop-Längsfehler
    - kleine Geschwindigkeit
    - lateral kontrollierbar
    - physischer Buffer noch nicht im Zielkorridor
  - Dann `buffer_settle_mode=forward` aktivieren
  - In diesem Modus:
    - sehr kleine Zielgeschwindigkeit
    - kleine feste Mindestzugkraft
    - harte Obergrenze für Zugkraft
    - keine Erfolgsfreigabe, solange `terminal_success_physical_ok == false`
  - Dadurch darf `conservative` nicht mehr wie in `path_test17.log` mit sichtbarem Undershoot direkt erfolgreich enden

- **`fast`-Overshoot in engem sicheren Korridor zurückholen**
  - Wenn der Zug nach `stop_guidance` den Stop-Target knapp überschritten hat:
    - negativer Stop-Längsfehler
    - Overshoot-Betrag klein
    - lateraler Fehler klein
    - Geschwindigkeit sehr klein
    - kein `near_target_correction`
    - kein grober Off-target-Line-Fall
  - Dann `buffer_settle_mode=reverse` aktivieren
  - In diesem Modus:
    - sehr kleine Rückwärts-Zielgeschwindigkeit
    - kleine Rückwärtsfreigabe
    - harter Abbruch des Modus, sobald Overshoot oder lateraler Fehler zu groß wird
  - Größere Overshoots bleiben bei der bestehenden sicheren Failure-/Recovery-Logik

- **Stop-Capture nur leicht nachschärfen, nicht neu erfinden**
  - `can_enter_stop_guidance(...)` bleibt snapshot-basiert und geschwindigkeitsbewusst
  - Nur so weit verschärfen, dass der Eintritt ins Endspiel nicht zu früh oder mit unplausibler Restgeschwindigkeit erfolgt
  - Keine neue Geometrie, keine neue Capture-Strategie
  - Haupthebel bleibt die symmetrische Nachregelung nach `guidance_mode=stop`

- **Profilparameter ergänzen**
  - Für beide Profile explizit pflegen:
    - `terminal_success_buffer_tolerance_m`
    - `buffer_settle_forward_speed_mps`
    - `buffer_settle_forward_throttle_limit`
    - `buffer_settle_forward_max_longitudinal_m`
    - `buffer_settle_reverse_speed_mps`
    - `buffer_settle_reverse_throttle_limit`
    - `buffer_settle_reverse_max_overshoot_m`
    - `buffer_settle_max_lateral_m`
  - Default:
    - `conservative`: Reverse-Settle effektiv deaktiviert
    - `fast`: enger Reverse-Settle-Korridor erlaubt
  - Die bestehenden `terminal_buffer_*`-Anflugswerte bleiben erhalten und werden nicht ersetzt

- **Terminal-Hold und Failure-Reihenfolge festziehen**
  - Reihenfolge im Terminal-Leg nach `guidance_mode=stop`:
    1. `terminal_success_stop_ok` und `terminal_success_physical_ok` prüfen
    2. falls nicht erfolgreich: `buffer_settle_mode=forward` prüfen
    3. falls nicht erfolgreich: `buffer_settle_mode=reverse` prüfen
    4. falls nichts zulässig: bestehende sichere Failure-/Recovery-Pfade
  - `near_target_correction`, `stop_first` und echte Sicherheitsgrenzen bleiben höher priorisiert als kleine Settle-Korrekturen

## Minimale Log-Ergänzungen
- Bestehende Felder beibehalten
- Nur diese zusätzlichen Felder ergänzen:
  - `buffer_settle_mode=none|forward|reverse`
  - `buffer_settle_eligible`
  - `buffer_settle_block_reason`
  - `terminal_success_stop_ok`
  - `terminal_success_physical_ok`
- Keine weitere Logger-Arbeit in dieser Phase

## Tests
- **Referenzfälle aus `path_test17.log`**
  - `fast`, `stop_buffer_m=6`
    - kleiner Overshoot soll, wenn sicher, in `buffer_settle_mode=reverse` landen
    - kein sichtbares unkontrolliertes Überschießen mehr
  - `conservative`, `stop_buffer_m=6`
    - der Fall mit `physical_distance=7.83m` darf nicht mehr als Erfolg enden
    - stattdessen Vorwärts-Nachregelung oder sauber blockierter Zustand

- **Referenzfall aus `path_test16.log`**
  - `fast`, `stop_buffer_m=3`
  - der gute Lauf mit kleinem Bufferfehler muss erhalten bleiben oder besser werden
  - kein Rückfall auf `terminal_limit_exit`

- **Startpositionsrobustheit**
  - Mehrere `route`-Läufe mit gleichem Ziel und gleichem Buffer, aber verschiedenen Startpunkten
  - Endabstand zum physischen Ziel soll deutlich enger streuen als bisher

- **Regression**
  - Keine neue Oszillation auf der Endkurve
  - Kein neuer `reverser_mismatch`
  - `goto`, `goto --via` und `route` nur als Regression prüfen, ohne Speziallogik

- **Statische Prüfungen**
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - Preview ergänzen für:
    - `conservative`-Undershoot, der noch kein Erfolg ist
    - `fast`-Kleinstovershoot mit erlaubtem Reverse-Settle
    - Erfolg nur wenn `terminal_success_stop_ok` und `terminal_success_physical_ok` beide `true` sind

## Annahmen und Defaults
- Das verbleibende Problem sitzt ausschließlich im Terminal-Endspiel des gemeinsamen Route-Runners
- `goto`-Varianten sollen automatisch mitbehoben werden
- Ein kleiner, langsamer Reverse-Korridor für `fast` ist akzeptabel, solange er nicht oszilliert
- `conservative` soll nicht rückwärts nachregeln
- Ein strengerer, konsistenter Erfolgskorridor ist wichtiger als frühe Erfolgsmeldung