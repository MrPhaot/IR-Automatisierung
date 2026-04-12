# Fix-Plan Für `route_book_editor`: Diagnose-Aufruf und `gpu bind failed`

## Zusammenfassung
Es gibt zwei getrennte Ursachen:

1. `lua route_book_editor.lua --diagnose-ui` funktioniert unter OpenOS nicht wie erwartet, weil [`/bin/lua.lua`](/home/mrphaot/.local/share/PrismLauncher/instances/HBM%20NTM%202/minecraft/saves/TEST%20%281%29/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/bin/lua.lua) `shell.parse(...)` nur als `args` liest. `shell.parse` behandelt `--diagnose-ui` aber als Option und nicht als Positionsargument. Die Script-Datei bekommt den Flag daher gar nicht.

2. Der eigentliche Startfehler `gpu bind failed` kommt sehr wahrscheinlich aus der Rebind-Strategie in [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua): Der Code versucht zu früh `gpu.bind(primary_screen)`, obwohl oft nur `tty.bind(gpu)` fehlt.

Gewählter Scope: projektlokal. OpenOS-Systemdateien werden nicht gepatcht.

## Wichtige Änderungen
### CLI und Diagnose
- In `route_book_editor.lua` eine kleine CLI-Normalisierung einführen, z. B. `parse_cli_mode(argv)`.
- Unterstützte Diagnose-Aufrufe projektlokal:
  - `lua route_book_editor.lua diagnose-ui`
  - `lua route_book_editor.lua -- --diagnose-ui`
- `--diagnose-ui` intern als Alias behalten, aber nur dort auswerten, wo der Chunk ihn tatsächlich sehen kann.
- Wenn kein Terminalkontext aufgebaut werden kann, im Diagnosemodus immer `diagnostic_summary(...)` ausgeben und nie `context_error(...)`.
- Die Fehlermeldung für den normalen Start soll zusätzlich einen knappen Hinweis auf den Diagnoseaufruf enthalten, z. B. `use 'lua route_book_editor.lua diagnose-ui'`.

### Rebind-Strategie
- `attempt_terminal_rebind(...)` umstellen auf diese Reihenfolge:
  1. primären GPU-Proxy holen
  2. aktuellen Screen über `gpu.getScreen()` lesen
  3. wenn bereits ein Screen gebunden ist: zuerst nur `tty.bind(gpu)` versuchen
  4. nur wenn `gpu.getScreen()` leer ist oder `tty.bind(gpu)` nicht reicht: an `component.screen.address` binden
  5. danach erneut `tty.bind(gpu)` und `tty.gpu()` prüfen
- `gpu.bind(...)` nur noch verwenden, wenn wirklich kein brauchbarer Screen gebunden ist.
- `gpu bind failed` nur noch melden, wenn ein echter GPU-Screen-Bind notwendig war und tatsächlich fehlgeschlagen ist.
- Wenn `tty.bind(gpu)` bei bereits gebundener GPU scheitert, stattdessen `tty bind failed` melden.

### Diagnosefelder
- `diagnostic_summary(...)` um die Rebind-Stufen als Laufzeitfakten beibehalten:
  - `gpu_current_screen`
  - `tty_gpu_before`
  - `tty_gpu_after`
  - `rebind_attempted`
  - `gpu_bind_attempted`
  - `gpu_bind_ok`
- Zusätzlich klar trennen zwischen:
  - `no gpu component`
  - `no screen component`
  - `tty bind failed`
  - `gpu has no screen and gpu bind failed`

## Testplan
- CLI-Test für `parse_cli_mode(argv)`:
  - `{"diagnose-ui"}` aktiviert Diagnose
  - `{"--diagnose-ui"}` aktiviert Diagnose, wenn der Chunk das Argument bekommt
  - leeres `argv` aktiviert Diagnose nicht
- Resolver-Test:
  - `tty.gpu() == nil`, `gpu.getScreen() == "screen-x"` -> `tty.bind(gpu)` reicht, kein `gpu.bind(...)`
  - `tty.gpu() == nil`, `gpu.getScreen() == nil` -> `gpu.bind(screen.address)` danach `tty.bind(gpu)`
  - `gpu.bind(...)` scheitert -> spezifischer Fehler statt pauschalem Fehlklassifizieren
- Diagnose-Test:
  - bei fehlendem Kontext liefert Diagnose immer die Summary-Zeile, nicht `context_error(...)`
- Regressions-Test:
  - bestehende Viewport-/Origin-/Pointer-Tests bleiben erhalten

## Annahmen und Defaults
- `lua route_book_editor.lua --diagnose-ui` kann projektlokal nicht vollständig “repariert” werden, solange OpenOS-`/bin/lua.lua` ungepatcht bleibt.
- Der empfohlene Diagnoseaufruf ist deshalb künftig `lua route_book_editor.lua diagnose-ui`.
- Wenn später exakt `lua script.lua --diagnose-ui` unterstützt werden soll, ist das ein separater System-Fix an [`/bin/lua.lua`](/home/mrphaot/.local/share/PrismLauncher/instances/HBM%20NTM%202/minecraft/saves/TEST%20%281%29/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/bin/lua.lua), nicht an `route_book_editor.lua`.
