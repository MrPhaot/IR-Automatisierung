# Fix-Plan Für Den Neuen Fehler `gpu bind failed`

## Zusammenfassung
Die Dateien sind synchron. Der aktuelle Fehler liegt sehr wahrscheinlich im neuen Selbstheilungs-Code: Der Editor versucht beim Reparieren des Terminalzustands **zu früh ein `gpu.bind(...)`**, obwohl oft nur `tty.bind(gpu)` fehlt.

Der Reparaturpfad muss daher aufgeteilt werden:
- zuerst TTY-Bind wiederherstellen
- nur falls die GPU selbst wirklich an keinen nutzbaren Screen gebunden ist, zusätzlich `gpu.bind(screen)`

## Implementierungsänderungen
### 1. Rebind-Strategie in `attempt_terminal_rebind(...)` umdrehen
- Nicht mehr zuerst `gpu.bind(...)`
- Neue Reihenfolge:
  1. primären `gpu` holen
  2. aktuelles `gpu.getScreen()` lesen
  3. wenn bereits ein Screen gebunden ist:
     - zuerst direkt `tty.bind(gpu)` versuchen
     - danach `tty.gpu()` erneut prüfen
  4. nur wenn kein Screen gebunden ist oder `tty.bind(gpu)` nicht reicht:
     - dann `component.screen` holen
     - dann `gpu.bind(screen.address)` versuchen
     - danach erneut `tty.bind(gpu)`
- `gpu bind failed` darf also nur noch kommen, wenn ein echter GPU-Screen-Bind wirklich nötig war und wirklich fehlgeschlagen ist

### 2. Fehlerursachen feiner trennen
- Neue Fehlergründe:
  - `no gpu component`
  - `no screen component`
  - `tty bind failed`
  - `gpu has no screen and gpu bind failed`
- Nicht mehr pauschal `gpu bind failed`, wenn eigentlich nur der TTY-Bind kaputt war

### 3. Diagnostik ausbauen
- In `--diagnose-ui` zusätzlich:
  - `gpu_current_screen=<addr|nil>`
  - `tty_bind_before_gpu_bind=yes/no`
  - `tty_bind_after_gpu_bind=yes/no`
  - `gpu_bind_attempted=yes/no`
  - `gpu_bind_ok=yes/no`
- So lässt sich sofort unterscheiden:
  - GPU war schon an Screen gebunden, aber TTY nicht
  - GPU war komplett ungebunden
  - GPU-Bind selbst schlägt fehl

### 4. `resolve_terminal_context(...)` unverändert streng lassen
- Weiterhin nur erfolgreich, wenn am Ende `tty.gpu()` eine echte GPU mit `set` liefert
- Aber den Reparaturpfad davor realistischer und weniger destruktiv machen

## Testplan
- Neuer Rebind-Test:
  - `tty.gpu() == nil`
  - `component.gpu.getScreen()` liefert schon `"screen-2"`
  - `component.screen.address` ist `"screen-1"`
  - `tty.bind(gpu)` reicht aus
  - Resolver muss erfolgreich sein, **ohne** `gpu.bind(...)` zu erzwingen
- Zweiter Test:
  - `gpu.getScreen() == nil`
  - `tty.bind(gpu)` allein reicht nicht
  - dann `gpu.bind(screen.address)` + `tty.bind(gpu)`
  - Resolver erfolgreich
- Dritter Test:
  - `gpu.getScreen() == nil`
  - `gpu.bind(...)` schlägt fehl
  - spezifischer Fehler statt pauschaler Fehlklassifikation
- Bestehende Tests für:
  - Viewport-Parsing
  - Origin-Offset
  - Pointer-Normalisierung
  - Diagnosefelder
  bleiben bestehen

## Annahmen
- Der neue Fehler kommt nicht mehr von falschen Dateien.
- Die wahrscheinlichste Fehlentscheidung ist das vorschnelle `gpu.bind(primary_screen)` im Reparaturpfad.
- Der robustere Fix ist: erst `tty.bind(gpu)`, dann nur bei Bedarf `gpu.bind(screen)`.
