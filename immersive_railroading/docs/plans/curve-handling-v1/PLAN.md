# Curve Handling V1.11: Letzten `fast`-Restfehler unter 0.5 m austrimmen

## Zusammenfassung
- `path_test16.log` zeigt: Der aktuelle `fast`-Pfad ist grundsätzlich erfolgreich und hält den Buffer jetzt fast sauber ein.
- Relevanter Zielzustand:
  - `arrived_at_target`
  - `stop_guidance_entry` bei `physical_distance=5.30m`
  - Abschluss bei `physical_distance=3.41m`
  - `physical_buffer_error=0.41m`
- Das ist kein Architektur- oder Sicherheitsproblem mehr, sondern nur noch ein kleiner Endphasen-Trim im letzten Meter.

## Wichtige Änderungen
- In [`train_controller.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua) den `fast`-spezifischen `buffer_settle`-Pfad feiner abstimmen, statt neue Geometrie oder neue Capture-Regeln einzuführen.
- Ziel:
  - Buffer-Fehler im erfolgreichen `fast`-Fall weiter verkleinern
  - keine Regression bei Kurvenfahrt, Handoffs oder Stop-Capture
- Der Eingriff bleibt auf `guidance_mode=stop` und nur auf den letzten Meter beschränkt.

## Implementierungsdetails
- `fast`-Parameter für die letzte Nachregelung leicht nachziehen:
  - `buffer_settle_speed_mps` etwas kleiner
  - `buffer_settle_throttle_limit` etwas kleiner
  - optional engeres `buffer_settle_max_longitudinal_m`, damit die Nachregelung nur ganz nah am Stop-Target greift
- `buffer_settle` nur dann aktiv lassen, wenn der Zug noch sauber vorwärts zum gepufferten Stop-Target arbeitet:
  - kein Eingriff bei Overshoot/Stop-first/Near-target-correction
  - keine Änderung an `conservative`
- `arrived_at_target`/`arrived_within_v1_limit` unverändert semantisch lassen, aber den `fast`-Pfad so trimmen, dass der Halt vor der Freigabe noch etwas näher an `stop_buffer_m` kommt.
- Logging nur minimal ergänzen, falls nötig:
  - `buffer_settle` soll im nächsten Run klar erkennbar sein
  - kein neuer Log-Umbau, solange die bestehenden Felder reichen

## Testplan
- Referenzfall aus [path_test16.log](/home/mrphaot/.local/share/PrismLauncher/instances/HBM%20NTM%202/minecraft/saves/TEST%20(1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/path_test16.log):
  - `fast`, Route `1_zu_2`, `stop_buffer_m=3`
  - Erfolgreicher Abschluss soll erhalten bleiben
  - `physical_buffer_error` soll kleiner werden als die aktuellen `0.41m`
- Regression:
  - kein Rückfall auf `terminal_limit_exit`
  - kein neues Pendeln oder `reverser_mismatch`
  - kein späteres `late_buffer_capture`
  - `goto`, `goto --via` und `route` bleiben unverändert
- Statische Checks:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
  - Preview um einen `fast`-Erfolgsfall ergänzen, der einen Buffer-Fehler in der Größenordnung von `0.4m` als verbesserungswürdig, aber grundsätzlich stabilen Zielpfad abbildet

## Annahmen
- Der unvollständige `conservative`-Abschnitt in `log16` blockiert den nächsten Schritt nicht.
- Priorität ist jetzt ein kleiner, regressionsarmer Feinschliff des erfolgreichen `fast`-Pfads.
- Ein Eingriff nur im `buffer_settle`-Fenster ist der höchste Hebel bei geringstem Risiko.
