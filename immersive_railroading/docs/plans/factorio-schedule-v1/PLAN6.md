# Fix-Plan Für Den Weiterhin Defekten `route_book_editor`

## Zusammenfassung
Der Deploy ist jetzt synchron; der Fehler ist also im **aktuellen Code**. Ich habe dabei einen harten Laufzeitbug gefunden, der die bisherigen grünen Preview-Tests nicht abdecken:

- `resolve_terminal_context()` behandelt `tty.getViewport()` falsch.
- In OpenOS liefert `tty.getViewport()` **6 Werte** zurück: `width, height, dx, dy, x, y`.
- Der Editor jagt das durch `parse_size(...)`, und diese Hilfsfunktion nimmt bei 4+ Zahlen **das 3./4. Paar**.
- Ergebnis: aus `54, 18, 0, 0, 1, 1` wird effektiv `0, 0` statt `54, 18`.
- Das ist ein echter Codefehler und erklärt, warum der neue Resolver trotz korrekter Dateien weiter scheitern kann.
- Zusätzlich bleibt ein zweites strukturelles UI-Problem bestehen: `term_ui.flush(...)` rendert immer ab `(1, y)` und ignoriert die tatsächliche Terminal-Position/Global-Area. Selbst wenn der Startfehler weg ist, kann die GUI deshalb weiter scuffed erscheinen.

Die bisherigen Tests sind falsch positiv, weil sie `getViewport()` nur mit **2 Rückgabewerten** mocken und damit die reale OpenOS-Signatur nicht nachbilden.

## Implementierungsänderungen
### 1. Resolver-Fix in `route_book_editor.lua`
- `parse_size(...)` nicht mehr generisch für unterschiedliche API-Formate verwenden.
- Stattdessen zwei explizite Parser einführen:
  - `parse_wh(a, b)` für `gpu.getResolution()` und `tty.getViewport()`
  - `parse_global_area(x, y, w, h)` für `term.getGlobalArea()`
- Für `tty.getViewport()` nur **die ersten beiden Werte** verwenden.
- Für `term.getGlobalArea()` explizit `w, h` aus dem 3./4. Wert lesen.
- `resolve_terminal_context()` soll zusätzlich die Terminal-Ursprungskoordinate speichern:
  - `origin_x`
  - `origin_y`
- Quelle dafür:
  - primär `term.getGlobalArea()`
  - falls nicht vorhanden: `origin_x = 1`, `origin_y = 1`

### 2. Render-Fix in `term_ui.lua`
- `flush(...)` darf nicht mehr hart `gpu.set(1, y, line)` verwenden.
- Entweder:
  - `flush(term_api, gpu_api, width, height, buffer, origin_x, origin_y)`
  - oder `flush(...)` bekommt ein `frame`/`context`-Objekt
- Der Renderer muss Zeilen an `origin_x, origin_y + y - 1` schreiben.
- `gpu.fill(...)` zum Leeren ebenfalls mit Ursprung berücksichtigen.
- Damit rendert die UI im tatsächlichen OpenOS-Terminalbereich statt blind links oben am physischen Screen.

### 3. Diagnose verbessern
- `--diagnose-ui` soll zusätzlich ausgeben:
  - rohes `tty.getViewport()`-Ergebnis
  - `origin=<x>,<y>`
  - `viewport=<w>x<h>`
- So wird sofort sichtbar, ob wieder ein Signatur-/Parsingproblem vorliegt.

## Testplan
- `term_ui_preview.lua` anpassen, damit `getViewport()` realistisch mocked wird:
  - `return 54, 18, 0, 0, 1, 1`
- Neue Assertions:
  - `resolve_terminal_context(...).viewport_width == 54`
  - `resolve_terminal_context(...).viewport_height == 18`
  - nicht `0,0`
- Neuer Render-Test mit Ursprung:
  - `origin_x = 4`, `origin_y = 2`
  - prüfen, dass `gpu.set(4, 2, line1)` statt `gpu.set(1, 1, line1)` aufgerufen wird
- Regressions-Test:
  - `term.getGlobalArea() -> 4, 2, 54, 18`
  - `tty.getViewport() -> 54, 18, 0, 0, 1, 1`
  - Layouttier muss `compact` sein und Renderkoordinaten müssen innerhalb des Origins liegen

## Annahmen
- Der aktuelle OC-Ordner ist korrekt synchronisiert; ein weiterer Redeploy desselben Stands allein löst das Problem nicht.
- Der primäre aktuelle Codebug ist das falsche Parsing von `tty.getViewport()`.
- Das zweite, weiterhin relevante UI-Problem ist der fehlende Render-Offset für die tatsächliche Terminalfläche.
