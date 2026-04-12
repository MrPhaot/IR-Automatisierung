# Fix-Plan Für Den Neuen `route_book_editor`-Startfehler

## Zusammenfassung
Die neue Fehlermeldung ist sehr wahrscheinlich ein **falscher Negativbefund des neuen Terminal-Resolvers**, nicht ein echter „keine GPU vorhanden“-Zustand.

Beleglage:
- Im Screenshot sind `gpu`, `screen` und `keyboard` als Komponenten vorhanden.
- OpenOS-Boot bindet GPU/Screen grundsätzlich über [`boot/91_gpu.lua`](/home/mrphaot/.local/share/PrismLauncher/instances/HBM%20NTM%202/minecraft/saves/TEST%20%281%29/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/boot/91_gpu.lua).
- OpenOS-eigene Tools nutzen für den Terminal-GPU-Zugriff teils direkt `tty.gpu()`, z. B. [`bin/resolution.lua`](/home/mrphaot/.local/share/PrismLauncher/instances/HBM%20NTM%202/minecraft/saves/TEST%20%281%29/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/bin/resolution.lua).
- Der Editor prüft aktuell nur `call_api(term, "gpu")` in [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua#L1123). Das ist zu eng und kann einen funktionierenden TTY-Kontext fälschlich als „kein aktives Terminal-GPU“ einstufen.
- Zusätzlich ist `rawget(_G, "term") or require("term")` unnötig riskant; für den Editor sollte das echte OpenOS-Modul geladen werden, nicht ein eventuell verschmutztes Global.

Die Grundursache ist damit: **Der neue Resolver benutzt die falsche Source of Truth für den gebundenen Terminal-GPU-Kontext.**

## Implementierungsänderungen
### 1. Terminal-Resolver auf `tty` als kanonische Quelle umstellen
- In `route_book_editor.lua` zusätzlich `local tty = safe_require("tty")` laden.
- `resolve_terminal_context(...)` nicht mehr nur auf `term.gpu()` aufbauen.
- Feste Auflösungsreihenfolge:
  1. gebundene GPU über `tty.gpu()`
  2. Verfügbarkeit über `tty.isAvailable()` sofern vorhanden
  3. Viewport über `tty.getViewport()`
  4. globale Fläche über `term.getGlobalArea()` nur als Zusatz/Fallback für Position/Größe
- `component.gpu` darf **nicht** als Produktionsfallback benutzt werden; der Benutzer wollte bewusst einen gebundenen OpenOS-Terminalpfad.

### 2. `rawget(_G, "term")` entfernen
- `route_book_editor.lua` soll `term` immer über `require("term")` laden.
- Gleiches Prinzip für `tty`: echtes Modul, kein Global-Fallback.
- Damit wird ausgeschlossen, dass ein früherer Befehl oder ein fremdes Globalobjekt den Resolver verfälscht.

### 3. `resolve_terminal_context()` robuster machen
- Erfolg soll gelten, wenn:
  - `tty.gpu()` eine Proxy-Tabelle mit `set` liefert
  - und ein positiver Viewport aus `tty.getViewport()` oder `term.getGlobalArea()` ableitbar ist
- Fehlertexte differenzieren:
  - `tty unavailable`
  - `no bound terminal gpu`
  - `viewport unavailable`
- Kein Fehler mehr allein deshalb, weil `term.gpu()` nil liefert, solange `tty.gpu()` gültig ist.

### 4. Diagnosepfad korrigieren
- `--diagnose-ui` soll zusätzlich ausgeben:
  - `term_module=yes/no`
  - `tty_module=yes/no`
  - `tty_available=yes/no`
  - `term_gpu=yes/no`
  - `tty_gpu=yes/no`
  - `viewport=<w>x<h>`
- So wird künftig sofort sichtbar, ob der Fehler am Modulobjekt oder am echten TTY-Zustand liegt.

## Tests
- Preview-Test für `resolve_terminal_context()` mit Stub-Modulen:
  - `term.gpu=nil`, `tty.gpu=proxy` -> Erfolg
  - `term.gpu=proxy`, `tty.gpu=proxy` -> Erfolg
  - `tty.gpu=nil` trotz `component.gpu` vorhanden -> Fehler
  - verschmutztes `_G.term` darf keinen Einfluss mehr haben
- Regressions-Test für `--diagnose-ui`-ähnliche Summary:
  - bei gültigem TTY-Kontext kein `no active terminal gpu`
- Bestehende `term_ui`- und Layout-Tests bleiben, aber erst nach diesem Startfix relevant.

## Annahmen
- Die aktuelle Fehlermeldung ist ein Resolver-Bug, kein echter Hardwaremangel.
- Der Editor soll weiterhin einen **gebundenen OpenOS-Terminal-GPU-Kontext** verlangen, aber diesen korrekt über `tty` erkennen.
- Die frühere kaputte GUI ist separat; dieser Fix stellt zuerst sicher, dass der Editor überhaupt wieder im richtigen Terminalkontext startet.
