# Fix-Plan Für Den Verbleibenden `gpu bind failed`-Fehler

## Zusammenfassung
Die neue Debug-Ausgabe zeigt, dass der Fehler jetzt klar isoliert ist:

- `diagnose-ui` funktioniert projektlokal wie geplant.
- Der eigentliche Fehler ist **kein echter fehlgeschlagener `gpu.bind(...)`-Aufruf**.
- Beleg: In der Debug-Zeile stehen `gpu_bind_attempted=no` und `tty_bind_before_gpu_bind=no`. Der Code ist also **vor jedem Bind-Versuch** ausgestiegen.
- Damit liegt die Grundursache im frühen Proxy-Check in [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua): `proxy_from_component(...)` plus `type(gpu.getScreen) ~= "function"` / `type(gpu.bind) ~= "function"` sind zu streng und klassifizieren einen gültigen OpenComputers-Proxy fälschlich als defekt.

Der Fehlername `gpu bind failed` ist in diesem Zustand irreführend. Tatsächlich scheitert die Erkennung des GPU-Proxys, nicht der Bind selbst.

## Wichtige Änderungen
### Proxy-Erkennung robust machen
- `proxy_from_component(...)` nicht mehr auf `table` oder `string` einschränken.
- Primäre Komponenten direkt aus `component.getPrimary(kind)` oder `component[kind]` beziehen.
- Proxy-Objekte unabhängig vom Lua-Basistyp akzeptieren, solange sie sich wie OC-Proxys verhalten.
- Neue kleine Hilfsfunktionen einführen:
  - `read_member(target, key)` mit `pcall`, um Felder/Methoden sicher auszulesen
  - `has_method(target, key)` auf Basis von `read_member(...)`
- Alle GPU-/Screen-Probes in `attempt_terminal_rebind(...)` auf diese Helper umstellen.

### Frühen Fehlschluss entfernen
- Den aktuellen Frühabbruch:
  - `if not gpu or type(gpu.getScreen) ~= "function" or type(gpu.bind) ~= "function" then return nil, "gpu bind failed" end`
  ersetzen durch:
  - `gpu proxy unavailable` wenn gar kein brauchbarer GPU-Proxy lesbar ist
  - `screen proxy unavailable` wenn der Screen-Proxy fehlt
- `gpu bind failed` nur noch verwenden, wenn `gpu.bind(...)` wirklich aufgerufen wurde und fehlgeschlagen ist.

### Rebind-Pfad beibehalten, aber sauber staffeln
- Nach erfolgreicher Proxy-Erkennung:
  1. `current_screen = gpu.getScreen()`
  2. zuerst `tty.bind(gpu)` versuchen
  3. nur wenn kein Screen gebunden ist oder `tty.bind(gpu)` nicht reicht: `gpu.bind(screen.address)`
  4. danach erneut `tty.bind(gpu)`
- Die bestehende Trennung zwischen `tty bind failed` und echtem `gpu bind failed` beibehalten.

### Diagnostik erweitern
- In `diagnostic_summary(...)` zusätzliche Proxy-Fakten aufnehmen:
  - `gpu_proxy_type`
  - `screen_proxy_type`
  - optional `gpu_has_bind`
  - optional `gpu_has_getScreen`
- So wird künftig sofort sichtbar, ob ein Proxy-Typ-/Methodenproblem vorliegt, bevor ein Bind versucht wird.

## Testplan
- Resolver-Test: `component.isAvailable("gpu") == true`, primärer GPU-Proxy ist gültig, aber darf nicht am Basistyp `table` hängen.
- Resolver-Test: Wenn der Proxy lesbar ist und `tty.bind(gpu)` reicht, darf kein `gpu.bind(...)` versucht werden.
- Resolver-Test: Wenn `gpu.getScreen() == nil`, dann `gpu.bind(screen.address)` und danach `tty.bind(gpu)`.
- Fehler-Test: Wenn der Proxy selbst unbrauchbar ist, muss der Fehler `gpu proxy unavailable` sein, nicht `gpu bind failed`.
- Diagnose-Test: Die Summary muss unterscheiden zwischen Proxy-Erkennungsfehler, `tty bind failed` und echtem `gpu bind failed`.

## Annahmen und Defaults
- Die aktuelle Debug-Zeile ist ausreichend, um den Fehler als **Proxy-Erkennungsbug** einzuordnen.
- OpenOS-Systemdateien bleiben unverändert; der Fix bleibt im Projekt.
- `diagnose-ui` bleibt der empfohlene Diagnoseaufruf, nicht `--diagnose-ui`.
