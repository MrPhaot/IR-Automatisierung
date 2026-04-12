# `route_book_editor` Stabilisieren: Exit-Funnel, saubere Statuszeile und Tier-2-Layout

## Summary
Der Terminalkontext ist jetzt grundsätzlich korrekt aufgebaut: `renderer=term-gpu`, `tty_gpu=yes`, `invoke_set_ok=yes`, und der lokale Framebuffer ist sauber. Ich habe `build_screen(...)` und `term_ui.render_lines(...)` lokal geprüft; Outer Box, Titel und Tabs werden korrekt erzeugt. Die sichtbaren Defekte in den Screenshots entstehen daher nicht primär in `build_screen`, sondern durch den Laufzeitpfad danach.

Es bleiben drei konkrete Probleme:

1. Der normale Start schreibt noch die vollständige Diagnose in die Statuszeile und zerstört damit die letzte UI-Zeile.
2. `80x25` wird noch als `comfort` behandelt; für Tier-2 ist das zu aggressiv und führt zu einem überbreiten Layout.
3. Beendigungen laufen nicht durch einen zentralen Cleanup-Funnel. Shell-Ausgaben wie `terminated` landen dadurch auf dem Fullscreen-Frame und scrollen die UI sichtbar nach oben. Das sieht wie ein Renderfehler oder Crash aus, obwohl der Framebuffer selbst korrekt ist.

## Wichtige Änderungen
### 1. Exit-Funnel in [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua)
- Den Main-Loop in zwei Ebenen aufteilen:
  - `run_loop(state, context, mode_name)` enthält nur die eigentliche Event-/Render-Schleife.
  - `run(argv)` ist der Wrapper, der CLI-Modus, Initialisierung, Fehlerfang und Finalisierung steuert.
- Ein strukturiertes Exit-Ergebnis verwenden, z. B.:
  - `{kind="ok"}`
  - `{kind="interrupted"}`
  - `{kind="terminated", code=...}`
  - `{kind="error", message=...}`
- Alle bisherigen direkten Exits im Laufpfad ersetzen:
  - `return true`
  - `return nil, err`
  - implizite Abbrüche aus Event-/Flush-Pfaden
  durch Rückgabe eines solchen Exit-Ergebnisses an `run()`.

### 2. Zentralen Cleanup-Pfad einführen
- Neue Funktion in `route_book_editor.lua`, z. B. `finalize_exit(context, exit_result)`.
- Diese Funktion wird immer aufgerufen, unabhängig davon, ob der Loop normal endet, `interrupted` erhält oder ein Fehler auftritt.
- Cleanup-Schritte:
  - den Editorbereich aktiv leer rendern, z. B. per `term_ui.flush(..., {}, origin_x, origin_y)` mit leerem Buffer über die volle Viewport-Fläche
  - danach den Framecache in [`term_ui.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/term_ui.lua) zurücksetzen
  - Cursor auf `1,1` setzen
  - optional einmal `term.clear()` verwenden, falls der leere Flush allein nicht reicht
- Danach Exit umsetzen:
  - `ok` und `interrupted` als kontrollierten Erfolg beenden
  - `terminated` ebenfalls nach Cleanup als kontrollierten Exit behandeln, nicht wieder als Tabelle hochwerfen
  - nur echte Fehler als Fehlertext an `lua.lua` zurückgeben

### 3. `terminated` technisch sauber umleiten
- In `run()` den Aufruf von `run_loop(...)` mit `xpcall(...)` kapseln.
- Im Fehlerhandler drei Fälle unterscheiden:
  - normales Lua-Error-Objekt oder String: echter Fehler
  - Tabelle `{reason="terminated", code=...}`: kontrollierte Termination
  - sonstige unerwartete Werte: als Fehler behandeln
- `terminated` nicht ungefiltert an die Shell weiterreichen.
- Stattdessen:
  - in `{kind="terminated", code=...}` übersetzen
  - Cleanup ausführen
  - danach mit Erfolg zurückkehren, damit keine zusätzliche Shell-Ausgabe den Frame hochscrollt

### 4. Statuszeile von Diagnose trennen
- `apply_startup_status(...)` nicht mehr im normalen Lauf auf `diagnostic_summary(...)` setzen.
- Neues Verhalten:
  - normaler Start: `state.message` bleibt fachlich, z. B. `Ready` oder `load fallback: ...`
  - `diagnose-ui`: nur dort die vollständige Diagnose ausgeben
  - Fehlerfall außerhalb von Diagnose: kurze menschenlesbare Meldung
- Resizes oder Kontext-Refresh dürfen ebenfalls keine Voll-Diagnose in `state.message` schreiben.
- Die Statuszeile bleibt ausschließlich für Editorstatus, nicht für Renderer-Telemetrie.

### 5. Layoutschwellen an Monitorgrößen anpassen
- `layout_for(width, height)` neu staffeln:
  - `minimum`: unverändert bei `<54` oder `<18`
  - `compact`: alles unter `100x30`
  - `comfort`: ab `100x30`
- Konsequenz:
  - `80x25` wird `compact`
  - `160x50` bleibt `comfort`
- Die bestehenden `compact`-Layouts weiterverwenden; keine neue Layoutfamilie einführen.

### 6. Kleine API-Ergänzung in [`term_ui.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/term_ui.lua)
- Öffentliche kleine Helper-Funktion ergänzen, z. B. `reset_cache()` oder `clear_cache()`, die `_frame_cache` zurücksetzt.
- `flush(...)` unverändert als Renderpfad behalten.
- Cleanup im Editor soll diese Cache-Funktion nach dem finalen Leer-Flush aufrufen, damit ein Neustart nicht mit stale Frame-Deltas arbeitet.

## Öffentliche/Interne Interfaces
- Neuer interner Exit-Contract in `route_book_editor.lua`:
  - `run_loop(...) -> exit_result`
  - `finalize_exit(context, exit_result) -> ok | nil, err`
- Neue kleine Public-API in `term_ui.lua`:
  - `reset_cache()` oder `clear_cache()`
- Keine Änderung am Dateiformat des Route Books und keine Änderung an den UI-Datenstrukturen.

## Testplan
### Lokale Render-/Layouttests
- `build_screen(..., 80, 25)` muss `compact` ergeben.
- `build_screen(..., 160, 50)` muss `comfort` ergeben.
- Für beide Größen müssen die ersten Zeilen in `render_lines(...)` weiterhin Outer Box und Tabs enthalten.

### Status-/Diagnosetests
- Im normalen Run darf die Statuszeile keine `renderer=...`-Diagnose enthalten.
- `diagnose-ui` muss weiterhin die vollständige Diagnose als reine Diagnoseausgabe liefern.
- Ein Kontext-Refresh im Lauf darf die fachliche Statuszeile nicht überschreiben.

### Exit-/Cleanup-Tests
- Normaler Exit: Frame wird geleert, Cursor zurückgesetzt, kein verbleibender UI-Rest.
- `interrupted`: derselbe Cleanup-Pfad wie beim normalen Exit.
- Simulierter `{reason="terminated"}`-Pfad: Cleanup läuft, danach kein erneutes Hochreichen der Terminationstabelle.
- Echte Fehler im Renderpfad: Cleanup läuft trotzdem, danach erst Fehlerausgabe.

### Regression
- Bestehende Viewport-/Origin-/Proxy-Zugriffstests bleiben aktiv.
- [`tests/previews/term_ui_preview.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/previews/term_ui_preview.lua) um Exit-/Cache-Reset-Szenarien erweitern.

## Annahmen und Defaults
- Die in den Screenshots fehlenden oberen Zeilen sind ein Nach-Exit-Artefakt, nicht ein Fehler in `build_screen`.
- `terminated` soll für diesen Editor als kontrollierter Abbruch behandelt werden, nicht als erneut an die Shell weiterzureichender Sonderfehler.
- Tier-2 wird künftig bewusst als `compact` behandelt; Tier-3 bleibt `comfort`.
