# Fix-Plan Für Den Erneuten `route_book_editor`-Crash

## Zusammenfassung
Der neue Crash ist kein Layoutproblem mehr, sondern ein **API-Kompatibilitätsfehler zwischen `route_book_editor.lua` und `term_ui.lua`**.

Verifizierter Befund:
- Lokal exportiert `programs/lib/term_ui.lua` bereits `is_valid_target`
- `programs/route_book_editor.lua` benutzt diese Funktion aber **nicht konsistent**
  - an einer Stelle mit Fallback über lokale `is_valid_target(...)`
  - an einer anderen Stelle per direktem Aufruf `term_ui.is_valid_target(...)`
- Der Screenshotfehler `attempt to call a nil value (field 'is_valid_target')` zeigt, dass auf dem Zielsystem eine ältere oder nicht mitgezogene `term_ui.lua` liegt
- Die lokalen Preview-Tests sind grün, weil sie nur den synchronen Repo-Zustand testen, nicht einen gemischten Deploy-Zustand

Der Fix muss deshalb zwei Dinge leisten:
- den Editor gegen fehlende `term_ui.is_valid_target`-Exports robust machen
- die Tests so erweitern, dass genau dieser Versionsmismatch künftig auffällt

## Root-Cause-Fix
### 1. Editor von optionalem `term_ui.is_valid_target` entkoppeln
- In `route_book_editor.lua` eine einzige lokale Hilfsfunktion als Source of Truth behalten:
  - `is_valid_target(target)`
- Diese Funktion darf optional `term_ui.is_valid_target` benutzen, aber nur defensiv:
  - wenn vorhanden: delegieren
  - wenn nicht vorhanden: lokale Validierung verwenden
- **Alle direkten Aufrufe** von `term_ui.is_valid_target(...)` in `route_book_editor.lua` entfernen
- Besonders die Modal-/Dialogpfade auf diese lokale Hilfsfunktion umstellen

Ziel:
- Der Editor darf auch mit einer älteren `term_ui.lua` nicht crashen
- `term_ui.is_valid_target` wird zu einem optionalen Komfort-Export, nicht zu einer zwingenden Laufzeitabhängigkeit

### 2. Zielgerichtete API-Kompatibilität einziehen
- `route_book_editor.lua` soll nur auf diese `term_ui`-Funktionen hart angewiesen sein:
  - `box`
  - `button`
  - `render_box`
  - `render_tabs`
  - `render_list`
  - `render_buttons`
  - `flush`
  - `fit_text`
  - `hit`
- Zusätzliche Helper wie `is_valid_target` nur optional verwenden
- Falls später weitere neue `term_ui`-Helper dazukommen, immer denselben Pattern verwenden:
  - capability check
  - lokaler Fallback

## Tests
### 1. Regressions-Test für genau diesen Crash
- `tests/previews/term_ui_preview.lua` oder neuer dedizierter Preview-Test soll einen **alten `term_ui`-Stand simulieren**
- Dafür einen Stub ohne `is_valid_target` einspeisen oder per isoliertem Loader ein `term_ui`-Table ohne diesen Export erzeugen
- Erwartung:
  - `route_book_editor.build_screen(...)` funktioniert trotzdem
  - kein Crash bei Modal-/Target-Erzeugung

### 2. Target-Validierung weiter absichern
- Tests beibehalten/ergänzen für:
  - `hit(nil, ...) == false`
  - ungültige Targets führen nie zum Fehler
  - alle erzeugten Targets aus `build_screen(...)` haben positive numerische Geometrie

### 3. Gemischter-Deploy-Fall explizit abdecken
- Neuer Preview-Test:
  - „neuer Editor + altes term_ui“
- Optional zweiter Test:
  - „neuer Editor + neues term_ui“
- Damit wird genau der reale OpenOS-Fehler modelliert, den die lokalen grünen Tests bisher übersehen haben

## Deployment- und Robustheits-Fix
- Doku/Arbeitsweise für den Implementierungsagenten festziehen:
  - bei UI-Lib-Änderungen `route_book_editor.lua` und `programs/lib/term_ui.lua` immer gemeinsam deployen
- Optional kleine Laufzeitdiagnose:
  - wenn ein erwarteter `term_ui`-Helper fehlt, einmal kurze Statusmeldung setzen wie `term_ui compatibility fallback active`
- Kein harter Abbruch nur wegen fehlendem `is_valid_target`

## Annahmen
- Der Crash kommt sehr wahrscheinlich von einem **inkonsistent aktualisierten OpenOS-Deploy**, nicht von der aktuellen Repo-Version allein
- Der richtige Fix ist deshalb **Kompatibilitätshärtung im Editor**, nicht nur „nochmal term_ui aktualisieren“
- Layout- und Renderer-Fixes bleiben sinnvoll, sind aber für diesen konkreten Crash nicht mehr die Hauptursache
