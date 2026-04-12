# Fix-Plan Für Die Weiterhin Kaputte `route_book_editor`-GUI

## Zusammenfassung
Die aktuell überprüften Dateien im OC-Ordner sind praktisch aktuell; ein echter Dateimismatch ist damit **nicht mehr** die Hauptursache. Der frühere Hinweis `term_ui out of date, please deploy matching files` passt nicht mehr zum jetzt geprüften Stand und ist sehr wahrscheinlich ein älterer Lauf oder ein irreführender Selbsttest gewesen.

Die eigentliche Grundursache für die weiterhin kaputte GUI ist mit hoher Wahrscheinlichkeit der **falsche Renderer-/Terminalpfad**:

- Der Editor bestimmt Größe und Renderer über `component.gpu` und `gpu.getResolution()`, nicht über das **aktive OpenOS-Terminal**.
- `term_ui.flush(...)` hat weiterhin einen `term`-Fallback, der ganze Vollbreiten-Zeilen mit `term.write(line)` schreibt.
- In OpenOS ist `term.write(...)` wrap-basiert. Für full-screen Framebuffer-Zeilen ist das ungeeignet und führt genau zu dem beobachteten Effekt: kurze Buttons bleiben sichtbar, große Rahmen-/Panelzeilen verschwinden oder zerlegen das Layout.
- Zusätzlich benutzt der Editor die **physische GPU-Auflösung** statt der **aktuellen Viewport-/Terminalfläche**. Das ist für ein OpenOS-TUI-Programm die falsche Referenz.

Die Fixrichtung ist deshalb: **den Editor fest auf das aktive OpenOS-Terminal mit gebundener GPU und Viewport umstellen** und den kaputten Term-Fallback für die Vollbild-UI entfernen.

## Implementierungsänderungen
### 1. Renderer auf aktives Terminal/GPU umstellen
- `route_book_editor.lua` soll die Rendering-Basis nicht mehr aus `component.gpu` ableiten.
- Stattdessen das aktive Terminal als Source of Truth benutzen:
  - GPU über `term.gpu()` oder die entsprechende Term-/TTY-Bindung beziehen
  - verfügbare Fläche über `term.getGlobalArea()` oder `tty.getViewport()`-äquivalente Term-APIs bestimmen
- `resolution(...)` im Editor so umbauen, dass sie **Viewportbreite/-höhe** zurückgibt, nicht die rohe physische GPU-Resolution
- Wenn kein korrekt verfügbares OpenOS-Terminal mit GPU/Viewport vorhanden ist:
  - kein kaputtes Rendering
  - stattdessen klarer Fehler wie `route_book_editor requires a bound OpenOS terminal with GPU`

### 2. Kaputten Term-Fallback aus `term_ui.flush(...)` entfernen
- `term_ui.flush(...)` soll für die Vollbild-UI **nicht mehr** `term.write(line)` als primären Frame-Ausgabepfad verwenden
- Für diese UI ist der neue feste Standard:
  - vorbereitete Zeilen via `gpu.set(x, y, line)` auf die aktive Terminal-GPU schreiben
- Der bisherige `term`-Fallback darf höchstens noch für Diagnose-/Fehlerausgaben benutzt werden, nicht für das normale Editor-Framebuffer-Rendering
- `render_lines(...)` bleibt die Source of Truth für den Endframe
- `flush(...)` bleibt nur:
  - Cacheverwaltung
  - Screen clear
  - Zeilenweises Schreiben auf die aktive GPU

### 3. Diagnosepfad korrigieren
- Die Meldung `term_ui out of date...` ist als Diagnose aktuell irreführend
- Statt einer starren `API_VERSION`-Warnung soll der Startstatus echte Laufzeitfakten melden:
  - `renderer=term-gpu`
  - Viewportgröße
  - physische GPU-Resolution optional zusätzlich
- Wenn ein Fehler vorliegt, soll die Diagnose den echten Grund nennen:
  - `no active terminal gpu`
  - `viewport unavailable`
  - `unsupported renderer`
- `API_VERSION` kann bleiben, aber nur noch als sekundäre Kompatibilitätsinfo, nicht als Hauptfehlerursache für die UI

### 4. Layout auf Viewport statt Roh-Resolution aufsetzen
- `build_screen(...)` weiterverwenden, aber alle Größen sollen aus der aktiven Terminalfläche kommen
- Tier-Entscheidung (`comfort` / `compact` / `minimum`) auf Basis des **sichtbaren Termbereichs**
- Dadurch wird verhindert, dass ein 160x50-GPU-Screen mit kleinerem nutzbarem TTY-Bereich falsch als volles Komfortlayout behandelt wird

### 5. Copy/Paste in das korrigierte Eingabemodell integrieren
- Die bereits begonnene Clipboard-Unterstützung bleibt im Modalbereich
- Paste weiter über das verifizierte OpenOS-`clipboard`-Event
- `Ctrl+C`/`Ctrl+V` bleiben editorintern für Modalfelder
- Diese Änderungen müssen aber auf dem neuen Terminal/GPU-Pfad getestet werden, nicht nur in isolierten Lua-Preview-Tests

## Tests und Verifikation
### 1. Neue Renderer-Regressionstests
- Test für die Rendererwahl:
  - wenn ein Terminal-GPU-Kontext vorhanden ist, muss der Editor diesen bevorzugen
  - kein Fallback auf den kaputten `term.write`-Zeilenpfad
- Test für Viewport-basierte Größenberechnung:
  - Mock-Terminal mit kleinerem Viewport als physischer Resolution
  - Layouttier muss sich nach dem Viewport richten

### 2. `term_ui`-Tests erweitern
- `render_lines(...)` bleibt getestet
- neuer Test für `flush(...)`:
  - Fake-GPU bekommt vollständige Zeilen
  - kein Term-Write-Framebuffer-Pfad mehr für regulären UI-Betrieb
- falls ein Fehlerpfad ohne GPU unterstützt bleibt:
  - expliziter Test, dass der Editor kontrolliert abbricht oder einen klaren Fehlerstatus zeigt

### 3. Editor-Preview erweitern
- `term_ui_preview.lua` oder ein zusätzlicher Preview-Test soll prüfen:
  - Diagnose-/Rendererstatus verwendet nicht mehr irreführend `term_ui out of date`
  - `build_screen(...)` funktioniert auf Viewportgrößen
  - Tier-2/Tier-3-Layouts basieren auf sichtbarer Fläche, nicht auf `gpu.getResolution()`

### 4. Manuelle Akzeptanz im OC-Rechner
- `lua route_book_editor.lua --diagnose-ui`
  - muss echten Renderer-/Viewportstatus melden
- normaler Start:
  - Titel, Tabs, Panels und Buttons sichtbar
  - nicht nur Buttons/Status
- Tier‑2-Monitor:
  - kompaktes, aber vollständiges Layout
- Modalfelder:
  - Texteingabe
  - `clipboard`-Paste
  - `Ctrl+C` / `Ctrl+V`

## Annahmen
- Die geprüften OC-Dateien sind aktuell genug; ein bloßer Redeploy derselben Dateien wird das GUI-Problem allein nicht lösen.
- Der zentrale Fehler liegt im Rendertransport, nicht mehr primär im Datenmodell oder in der Ziel-UI-Struktur.
- Für diese UI ist ein korrekt gebundenes OpenOS-Terminal mit GPU jetzt fest vorausgesetzt; ein generischer Term-Fallback ist nicht mehr Ziel des Produktionspfads.
