# Fix-Plan Für Den Verbleibenden Proxy-/GPU-Zugriffsfehler

## Zusammenfassung
Die neue Debug-Ausgabe isoliert den eigentlichen Defekt sehr klar:

- `term_gpu=yes` und `tty_gpu=yes` zeigen: Es **gibt** bereits einen GPU-Bezug im laufenden OpenOS-Terminal.
- Gleichzeitig zeigen `gpu_proxy_type=table`, `gpu_has_bind=no`, `gpu_has_getScreen=no`: Der Code kann an diesem Objekt keine Methoden über `type(proxy.method) == "function"` erkennen.
- Damit ist die Grundursache nicht mehr „keine GPU“, sondern ein **falsches Proxy-Zugriffsmodell**.
- Derselbe Fehler steckt nicht nur im Rebind-Pfad von `route_book_editor.lua`, sondern auch im Renderer von [`term_ui.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/term_ui.lua), der ebenfalls `type(gpu_api.set)` / `type(gpu_api.fill)` voraussetzt.

Kurz: Der Code behandelt OpenComputers-Proxys wie normale Lua-Objekte mit direkt sichtbaren Methoden. In diesem Laufzeitkontext ist diese Annahme falsch.

## Wichtige Änderungen
### GPU-/Proxy-Zugriff zentral neu aufbauen
- Eine kleine interne Helper-Schicht einführen, z. B. `lib/oc_proxy.lua`, statt verstreuter Direktzugriffe.
- Diese Helper sollen drei Dinge kapseln:
  - `read(target, key)` für sichere Feldzugriffe wie `address`
  - `address_of(target)` für die Komponentenadresse
  - `invoke(component_api, target, method, ...)`
- `invoke(...)` soll diese Reihenfolge nutzen:
  1. direkten Methodenaufruf versuchen, wenn wirklich eine Funktion sichtbar ist
  2. sonst über `component.invoke(address, method, ...)` auf die Adresse des Proxys fallen
- Der Code darf Methodenfähigkeit nicht mehr über `type(proxy.method) == "function"` entscheiden.

### `route_book_editor.lua` auf Invoke-basierte Prüfung umstellen
- `call_api`, `has_method` und die aktuelle Proxy-Validierung entfernen oder intern auf den neuen Helper umstellen.
- `resolve_terminal_context(...)` soll `tty.gpu()` nicht mehr verwerfen, nur weil `gpu.set` nicht direkt sichtbar ist.
- GPU-Gültigkeit stattdessen über erfolgreiche Aufrufe prüfen:
  - `getResolution`
  - `getScreen`
- `attempt_terminal_rebind(...)` soll für `getScreen`, `bind` und ähnliche Aufrufe nur noch den neuen Invoke-Helper benutzen.
- Der Fehler `gpu proxy unavailable` darf nur noch kommen, wenn weder direkter Aufruf noch `component.invoke(address, ...)` möglich sind.

### `term_ui.lua` ebenfalls robust machen
- `flush(...)`, `clear_screen(...)` und `write_line(...)` dürfen nicht mehr auf `type(gpu_api.set)` bzw. `type(gpu_api.fill)` bestehen.
- Auch dort denselben Invoke-Mechanismus verwenden:
  - `fill(origin_x, origin_y, width, height, " ")`
  - `set(x, y, line)`
- Sonst wird nach erfolgreichem Startup der nächste Fehler direkt im Renderer auftreten.

### Diagnostik an den echten Fehler anpassen
- Diagnosefelder ergänzen oder umdeuten:
  - `gpu_address`
  - `screen_address`
  - `invoke_getScreen_ok`
  - `invoke_bind_ok`
  - `invoke_set_ok`
- Fehlertexte klar trennen:
  - `gpu invoke unavailable`
  - `tty bind failed`
  - `gpu has no screen and bind failed`
- Nicht mehr „Proxy unavailable“, wenn eigentlich nur die direkte Methodensichtbarkeit fehlt.

## Testplan
- Resolver-Test mit Proxy-Stub, der nur eine `address` hat und dessen Methoden nur über `component.invoke` funktionieren.
- Rebind-Test:
  - `tty.gpu()` vorhanden, direkte Methoden nicht sichtbar, `component.invoke(..., "getScreen")` funktioniert -> Kontextaufbau erfolgreich.
- Renderer-Test:
  - `term_ui.flush(...)` mit GPU-Stub ohne direkt sichtbare `set`-/`fill`-Methoden, aber mit funktionierendem `component.invoke`-Fallback.
- Diagnose-Test:
  - aktuelle Fehlersituation darf nicht mehr als `gpu proxy unavailable` enden, wenn `component.invoke` auf demselben Proxy möglich ist.
- Regression:
  - bestehende Viewport-/Origin-/Pointer-Logik unverändert weiter testen.

## Annahmen und Defaults
- `component.invoke` ist im Zielsystem verfügbar und der stabile Zugriffspfad für diese Proxyform.
- Der Fix bleibt projektlokal; OpenOS-Systemdateien werden nicht verändert.
- Die neue Diagnose hat den entscheidenden Punkt bereits bewiesen: Das Problem ist Methodenerkennung, nicht Hardwareverfügbarkeit.
