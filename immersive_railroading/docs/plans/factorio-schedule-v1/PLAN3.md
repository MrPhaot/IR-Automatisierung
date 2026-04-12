# Fix-Plan Für Die Weiterhin Kaputte `route_book_editor`-UI

## Zusammenfassung
Der neue Screenshot zeigt: Der Editor crasht aktuell zwar nicht, aber der reale OpenOS-Render ist immer noch unzuverlässig. Sichtbar sind fast nur Action-Buttons und die Statuszeile, während Tabs und Panels praktisch verschwinden. Das bedeutet:

- die lokalen Preview-Tests decken den tatsächlichen Darstellungsfehler nicht ab
- der Fix muss nicht nur Layout berechnen, sondern den **kompletten Raster-Renderpfad** prüfbar machen
- zusätzlich sollen **Clipboard-/Paste-Funktionen** in die Modalfelder kommen

Der Implementierungsagent soll daher drei Dinge zusammen fixen:
1. den Renderpfad testbar und deterministisch machen
2. das Tier‑2-/Kompaktlayout als echtes eigenes Layout bauen
3. Copy/Paste für Modalfelder ergänzen

## 1. Renderpfad in `term_ui.lua` entkoppeln und prüfbar machen
### Root Cause
Die aktuellen Tests prüfen vor allem:
- dass `buffer` existiert
- dass Targets existieren
- dass ein Fake-`gpu.set` aufgerufen wird

Sie prüfen **nicht**, wie der finale Bildschirm wirklich aussieht. Genau deshalb kann lokal alles grün sein, obwohl das reale OpenOS-Bild unbrauchbar ist.

### Verbindlicher Fix
- In [`term_ui.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/term_ui.lua) eine reine Hilfsfunktion einführen:
  - `render_lines(width, height, buffer) -> lines`
- Diese Funktion erzeugt den finalen Frame als Zeilenarray und enthält die komplette Zeilenkomposition
- `flush(...)` darf nur noch:
  1. `render_lines(...)` aufrufen
  2. den fertigen Zeilenframe auf GPU/TTY schreiben
- `render_lines(...)` wird damit die eigentliche Source of Truth für das UI-Bild
- `flush(...)` bleibt nur Transport-/Cachelogik

### Zusätzliche Robustheit
- Optional `term_ui.API_VERSION = 2` einführen
- `route_book_editor.lua` prüft diese Version beim Start
- Wenn `term_ui` zu alt ist:
  - kein Crash
  - klare Fehlermeldung wie `term_ui out of date, please deploy matching files`
- Das verhindert weitere Mischdeploy-Probleme wie beim früheren `is_valid_target`-Crash

## 2. Tier‑2-/Kompaktlayout vollständig neu strukturieren
### Root Cause
Der Kompaktmodus ist aktuell nur ein zusammengedrücktes Komfortlayout. Dadurch stimmen Panelgrenzen, verfügbare Zeilen und Buttonreihen nicht sauber zusammen.

### Verbindlicher Fix
- `layout_for(width, height)` muss für jedes Tier vollständige Panel-Rects liefern, nicht nur `tier` plus ein paar Hilfszahlen
- Für `compact` ein echtes 3-Zonen-System festlegen:
  - `Detectors`, `Stations`, `Routes`
    - obere Hälfte: Liste
    - untere Hälfte: Details
  - `Schedules`
    - oberes Drittel: Schedule-Liste
    - mittleres Drittel: Entries
    - unteres Drittel: Wait Conditions
  - `Save / Validate`
    - ein Hauptpanel plus Fehler-/Statusbereich
- Alle Rects zentral berechnen und an `render_*` übergeben
- Keine Komfort-Konstanten wie feste Breiten `24`, `30`, `20` mehr im Kompaktpfad verwenden
- Action-Buttons im Kompaktmodus immer in genau zwei Reihen mit festem Raster
- Statuszeile separat reservieren, nie mit Buttons oder Panels teilen

### Mindestverhalten
- `comfort`: ab `80x24`
- `compact`: `54x18` bis `79x23`
- `minimum`: darunter nur klarer Fallback-Screen

## 3. Snapshot-Tests für den echten Bildinhalt ergänzen
### Verbindlicher Test-Fix
Die Preview-Tests müssen den finalen Bildschirmtext prüfen, nicht nur `buffer` und Targets.

Neue Testanforderungen:
- `term_ui_preview.lua` oder ein neuer Preview-Test baut `lines = render_lines(...)`
- Für `100x30` prüfen:
  - Titelzeile enthält `IR Schedule Editor`
  - Tabzeile enthält mehrere Tabs
  - Panels wie `Known Detectors` oder `Stations` sind sichtbar
  - Buttons erscheinen gesammelt in der unteren Aktionszone
- Für `70x20` und `54x18` prüfen:
  - Kompaktlayout zeigt weiterhin Titel, Tabs, mindestens ein Listenpanel und die Buttons
  - Panels sind in gestapelter Form sichtbar
  - Statuszeile bleibt vorhanden
- Keine Snapshot-Prüfung auf exakten Vollbildstring notwendig, aber klare Zeilen-/Substring-Assertions pro Layouttier

### Zusätzlicher Realismus
- Einen Test für den reinen Term-Fallback ergänzen:
  - Fake-`term.setCursor`
  - Fake-`term.write`
- Und einen für GPU:
  - Fake-`gpu.set`
- Beide müssen denselben `lines`-Frame ausgeben

## 4. Clipboard-/Paste-Support für Modalfelder
### Verifizierte Basis
Im lokalen OpenComputers/OpenOS-Bestand ist das `clipboard`-Event belegt. OpenOS `edit.lua` verarbeitet Paste bereits darüber.

### Verbindlicher Funktionsumfang
Copy/Paste wird nur für aktive Modalfelder implementiert.

Paste:
- `clipboard`-Event im Eventloop behandeln
- Clipboard-Text in das aktive Feld an Cursorposition einfügen
- `\r\n` zu `\n` normalisieren
- Mehrzeiliger Clipboard-Inhalt in Einzelfeldern durch Leerzeichen zusammenziehen

Copy:
- `Ctrl+C` kopiert den kompletten Inhalt des aktiven Felds in einen internen Editor-Clipboard-Puffer
- `Ctrl+V` fügt diesen internen Puffer ein, wenn kein echtes `clipboard`-Event kommt
- Es wird **keine** systemweite Copy-out-API angenommen, solange sie lokal nicht belastbar verifiziert ist

Textfeldmodell:
- pro Feld speichern:
  - `value`
  - `cursor`
  - `scroll_x`
- `handle_key_down(...)` ergänzen um:
  - `left`, `right`, `home`, `end`
  - `backspace`, `delete`
  - `Ctrl+C`, `Ctrl+V`
- Cursor im Modal sichtbar machen
- horizontales Scrolling für lange Werte einbauen

## 5. Diagnostik für den echten OpenOS-Lauf
Damit der gleiche Fehler nicht noch einmal lokal grün und im Spiel kaputt ist:

- optionalen Diagnosemodus für den Editor einführen, z. B. `route_book_editor --diagnose-ui`
- Ausgabe:
  - Auflösung
  - Layouttier
  - `term_ui`-API-Version
  - ob GPU- oder Term-Fallback benutzt wird
- alternativ mindestens beim Start kurz in die Statuszeile schreiben:
  - `UI tier=compact renderer=gpu api=v2`

## Annahmen und Defaults
- Das aktuelle Hauptproblem ist jetzt weniger ein einzelner Crash, sondern ein unzureichend getesteter Endbild-Renderpfad.
- Der Implementierungsagent soll zuerst `render_lines(...)` + Snapshot-Tests bauen, danach das Kompaktlayout umstellen, danach Clipboard ergänzen.
- Copy/Paste gilt in V1 nur für Modalfelder, nicht für freie Textselektion auf dem Bildschirm.
- Systemweites Copy-Out wird nicht vorausgesetzt; `Ctrl+C`/`Ctrl+V` bekommen deshalb eine sichere editorinterne Semantik.
