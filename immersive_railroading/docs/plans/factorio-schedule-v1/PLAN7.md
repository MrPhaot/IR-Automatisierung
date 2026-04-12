# Fix-Plan Für Den Startfehler `no bound terminal gpu`

## Zusammenfassung
Der aktuelle Fehler liegt im Startup-Pfad, nicht mehr im Renderpfad.  
`route_book_editor.lua` muss beim Start einen fehlenden TTY-GPU-Bind **selbst heilen** können, statt sofort abzubrechen.

Der Fix besteht aus zwei Stufen:
1. gebundenen Terminalkontext wie bisher prüfen
2. wenn `tty.gpu()` fehlt, aus primärem `component.gpu` + `component.screen` den TTY-Bind aktiv wiederherstellen und dann erneut prüfen

Die bisherigen Viewport-/Origin-/Input-Fixes bleiben sinnvoll, sind aber für diesen Fehler zweitrangig.

## Implementierungsänderungen
### 1. Selbstheilung für fehlenden TTY-Bind
- In `route_book_editor.lua` zusätzlich `component` laden
- Neue Hilfsfunktion, z. B. `attempt_terminal_rebind(component_api, tty_api)`
- Verhalten:
  - `component.isAvailable("gpu")` und `component.isAvailable("screen")` prüfen
  - primären `gpu`- und `screen`-Proxy holen
  - falls `gpu.getScreen() ~= screen.address`, `gpu.bind(screen.address)` ausführen
  - danach `tty.bind(gpu)` aufrufen
  - anschließend `tty.gpu()` erneut prüfen
- `resolve_terminal_context(...)` soll:
  - zuerst normalen gebundenen Zustand prüfen
  - bei fehlendem `tty.gpu()` genau **einmal** diesen Rebind-Versuch machen
  - nur wenn der Rebind scheitert, weiter mit `no bound terminal gpu` abbrechen

### 2. Diagnose deutlich erweitern
- `--diagnose-ui` soll vor und nach dem Rebindversuch ausgeben:
  - `component_gpu=yes/no`
  - `component_screen=yes/no`
  - `gpu_bound_screen=<address|nil>`
  - `tty_gpu_before=yes/no`
  - `tty_gpu_after=yes/no`
  - `rebind_attempted=yes/no`
  - `rebind_ok=yes/no`
- Fehlertext nicht nur `no bound terminal gpu`, sondern bei Bedarf:
  - `no gpu component`
  - `no screen component`
  - `gpu bind failed`
  - `tty bind failed`

### 3. Startup-Logik strikt nach Reihenfolge aufbauen
- Reihenfolge fest:
  1. `tty` vorhanden?
  2. `tty.gpu()` vorhanden?
  3. falls nein: Rebind versuchen
  4. dann Viewport/Origin bestimmen
  5. dann erst rendern
- Keine Vermischung von Startup-Heilung und Renderlogik

### 4. Bereits gemachte Render-/Input-Fixes beibehalten
- `tty.getViewport()` weiter korrekt als 6-Werte-API behandeln
- `term_ui.flush(...)` weiter mit `origin_x/origin_y`
- Nach dem Startup-Fix zusätzlich Eventkoordinaten auf Terminal-Ursprung umrechnen und Eventadresse filtern
- Aber das alles erst nach erfolgreichem Kontextaufbau

## Testplan
- Neuer Resolver-Test:
  - `tty.gpu()` zuerst `nil`
  - `component.gpu` + `component.screen` vorhanden
  - `attempt_terminal_rebind(...)` macht `gpu.bind(...)` + `tty.bind(...)`
  - danach `resolve_terminal_context(...)` erfolgreich
- Fehlerfall-Tests:
  - kein `component.gpu`
  - kein `component.screen`
  - `gpu.bind(...)` liefert Fehler
  - `tty.bind(...)` fehlt oder scheitert
- Diagnose-Test:
  - Rebind-Flags erscheinen korrekt im Summary
- Bestehende Tests für:
  - 6-Werte-Viewport
  - Origin-Offset
  - Render-Offset
  - alte `term_ui`-Kompatibilität
  bleiben bestehen

## Annahmen
- Der aktuelle OC-Ordner ist korrekt synchronisiert.
- Der verbleibende Startfehler ist sehr wahrscheinlich ein realer, aber behebbarer fehlender TTY-Bind im laufenden OpenOS-Kontext.
- Der Editor darf diesen Bind beim Start selbst wiederherstellen; das ist hier die richtige Robustheitsmaßnahme.
