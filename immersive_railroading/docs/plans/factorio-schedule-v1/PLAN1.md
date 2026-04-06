# Fix-Plan Für `route_book_editor`: UI-Stabilisierung Mit Explizitem Crash-Fix

## Zusammenfassung
Der neue Screenshot zeigt: Der Renderpfad ist teilweise schon korrigiert, aber der Editor crasht weiterhin beim Klicken in `programs/lib/term_ui.lua` an der Hit-Test-Stelle. Der Fix muss deshalb zwei Ziele gleichzeitig erfüllen:

- die UI optisch und layout-technisch stabil machen
- den Crash als **P0** vollständig beseitigen, auch auf großen Screens

Die Implementierung soll in dieser Reihenfolge erfolgen: **Crash-Härtung zuerst**, danach Layout-/Render-Fixes, danach Eventloop- und Dialogbereinigung.

## P0: Crash Beheben
Die Klickverarbeitung muss so gehärtet werden, dass `term_ui.hit(...)` niemals durch unvollständige Targets oder defekte Eventdaten abstürzen kann.

Verbindliche Änderungen:
- `term_ui.hit(rect, px, py)` defensiv umbauen:
  - sofort `false`, wenn `rect` kein Table ist
  - sofort `false`, wenn `rect.x`, `rect.y`, `rect.width`, `rect.height`, `px` oder `py` keine Zahlen sind
  - sofort `false`, wenn `rect.width <= 0` oder `rect.height <= 0`
  - erst danach den Rechteckvergleich ausführen
- `route_book_editor.build_screen(...)` darf nur valide Targets in `screen.targets` aufnehmen
  - vor dem Einfügen jeden Target-Eintrag validieren
  - invalide Targets verwerfen statt sie weiterzugeben
- `render_tabs`, `render_list`, `render_buttons` in `term_ui.lua` müssen garantieren, dass alle erzeugten Targets vollständige Geometrie besitzen
- `handle_click(...)` in `route_book_editor.lua` soll zusätzliche Guards bekommen:
  - wenn `screen` oder `screen.targets` fehlt: `false`
  - wenn Klickkoordinaten nicht numerisch sind: `false`
- Bei Klicks darf nie ungefiltert auf teilweise erzeugte Buttons/Targets vertraut werden

Erwartetes Ergebnis:
- kein Crash mehr bei Mausklicks
- auch nicht bei leeren Listen, abgeschnittenen Panels oder deformierten Layouts

## Layout- und Render-Fix
Der Screenshot zeigt zwar wieder Rahmen, aber das Layout ist noch starr und dadurch fragil.

Verbindliche Änderungen:
- `term_ui.flush(...)` auf einen sauberen OpenOS-Renderpfad festlegen:
  - bevorzugt `gpu.set(1, y, line)`
  - Fallback `term.setCursor(1, y)` + `term.write(line)`
  - kein `io.write(...)` für Frame-Zeilen
- `render_box(...)` robust machen:
  - Boxen mit zu kleiner Breite/Höhe nicht normal zeichnen
  - keine negativen `string.rep(...)`-Breiten zulassen
- `build_screen(...)` bekommt zentrale Layoutberechnung statt harter Magiezahlen an jeder Stelle
- Hybrid-Layout fest einbauen:
  - `>= 80x24`: Komfortlayout
  - `54x18` bis `79x23`: Kompaktlayout
  - `< 54x18`: klarer Mindestgrößen-Screen statt normaler UI
- Im Kompaktlayout:
  - Tabs gekürzt
  - Panels untereinander statt nebeneinander
  - Buttons in mehreren Reihen
- Alle berechneten Breiten/Höhen vor Nutzung clampen:
  - mindestens 1 für Texte
  - mindestens 2/2 oder 3/3 für Boxen, je nach Renderer-Regel

Erwartetes Ergebnis:
- Tier-3-Screen bleibt korrekt
- kleinere Screens degradieren kontrolliert statt kaputt zu gehen

## Eventloop und Interaktion
Der aktuelle Loop rendert effektiv nur bei Klicks und benutzt noch `io.read()`-basierte Prompts, was die UI weiter destabilisiert.

Verbindliche Änderungen:
- Eventloop auf Polling mit Timeout umstellen, z. B. `event.pull(0.1)`
- Diese Events behandeln:
  - `touch`
  - `drag`
  - `drop`
  - `scroll`
  - `key_down`
  - `interrupted`
- `needs_render` setzen bei:
  - jeder Auswahländerung
  - jeder Aktion
  - jeder Größenänderung
  - jedem Dialogstatuswechsel
- GPU-Auflösung pro Loop prüfen und bei Änderung Layout neu berechnen
- `prompt()` mit `io.read()` nicht weiter für UI-Aktionen verwenden
- Stattdessen einfacher Modal-Zustand im Editor:
  - Textfeld
  - Confirm/Cancel
  - Maus als Primärbedienung
  - Tastatur nur für Eingabe, `Enter`, `Esc`, optional `Tab`

## Tests
Die Fixes gelten erst als fertig, wenn der Crash reproduzierbar abgesichert ist.

Pflichttests:
- `tests/previews/term_ui_preview.lua` erweitern um:
  - `hit()` mit `nil`-Feldern
  - `hit()` mit `width=nil`, `height=nil`, `width<=0`, `height<=0`
  - `hit()` mit `px=nil` oder `py=nil`
  - Erwartung jeweils: `false`, nie Crash
- Neuer Preview-Test für `route_book_editor.build_screen(...)`:
  - alle `screen.targets` haben numerische positive Geometrie
  - keine invaliden Targets in Komfort- und Kompaktlayout
- Layout-Tests für:
  - `100x30`
  - `80x24`
  - `54x18`
  - `50x16` als Mindestgrößen-Fallback
- Renderer-Test mit Fake-`gpu`/`term`:
  - vollständiger Frame wird zeilenweise geschrieben
  - kein kaputter Versatz durch den Renderpfad
- Manueller Akzeptanztest auf dem OpenOS-Rechner:
  - Start des Editors
  - Klick auf Tabs
  - Klick auf Buttons
  - Klick in leere Listen
  - kein Crash in allen Fällen

## Annahmen und Reihenfolge
- Der verbleibende Crash ist jetzt höher priorisiert als die reine Layout-Politur.
- Der Implementierungsagent soll **zuerst** `term_ui.hit()` und Target-Validierung härten, **danach** Layout/Renderer, **danach** Eventloop und Modal-Eingaben.
- Der Fix ist erst abgeschlossen, wenn sowohl:
  - die UI sichtbar stabil ist
  - als auch der Klick-Crash sicher nicht mehr auftritt
