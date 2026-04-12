# Ergänzungsplan: Emulator Auf Den Echten Crash-/Cleanup-Pfad Erweitern

## Summary
Der aktuelle Emulator reicht für normale Render- und Inputpfade, aber nicht für den jetzt sichtbaren Ingame-Fehler `unknown error (cleanup: unknown error)`. Es fehlt die Emulation von OpenOS-Termination und Terminal-Invalidierung während des Exit-/Cleanup-Pfads.

## Erweiterungen am Emulator
- In [`tests/emulator/process.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/process.lua) einen echten Skript-Runner ergänzen, z. B. `run_script(path, argv, options)`, der:
  - das Script ohne `__module__` lädt
  - `io.stderr:write(...)` abfängt
  - `os.exit(code)` als strukturierte Termination einfängt
  - den kompletten Top-Level-Pfad testet
- In [`tests/emulator/runtime.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/runtime.lua) Fehlermodi für Exit/Cleanup ergänzen:
  - `event.pull` kann `{reason="terminated", code=...}` auslösen
  - GPU kann während `finalize_exit(...)` auf “invoke unavailable” kippen
  - `tty.gpu()`, `term.gpu()`, `term.clear()` und GPU-`fill`/`set` müssen gezielt scheitern können
- In [`tests/emulator/modules/term.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/modules/term.lua) `term.clear()` nicht mehr immer erfolgreich machen; stattdessen optional an den aktiven GPU-/Screen-Zustand koppeln.

## Neue Regressionstests
- Top-Level-Test für [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua):
  - normaler Start
  - Fehlerpfad mit `stderr`
  - `os.exit(1)`-Pfad
- Cleanup-Fehlertest:
  - Primärer Fehler + Cleanup-Fehler gleichzeitig
  - Ergebnis darf nie nur `unknown error (cleanup: unknown error)` sein, wenn der Ursprung genauer bekannt ist
- Terminationstest:
  - `{reason="terminated"}` während `event.pull`
  - `{reason="terminated"}` während GPU-Cleanup
  - beide Fälle müssen deterministisch und getrennt sichtbar werden
- Keyboard-RegressionsTests:
  - falsches Keyboard-`Esc` ignorieren
  - falsches Keyboard-`clipboard` ignorieren

## Erwartetes Ergebnis
- Danach kann der Emulator genau den derzeitigen Ingame-Crash lokal reproduzieren.
- Erst dann lohnt sich der eigentliche Fix am Exit-/Cleanup-Pfad, weil wir ihn anschließend stabil regressionssichern können.

## Annahmen
- Der gezeigte Ingame-Fehler ist kein reiner Layoutfehler.
- Der fehlende Emulator-Teil ist der OpenOS-ähnliche Top-Level-/Termination-/Cleanup-Pfad.
- Der bereits gefundene Keyboard-Bug bleibt zusätzlich bestehen und muss unabhängig davon behoben werden.
