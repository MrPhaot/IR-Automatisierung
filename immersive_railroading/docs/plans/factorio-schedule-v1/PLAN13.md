# `route_book_editor` Stabilisieren Mit OC-Harness: Exit-Contract, Cleanup und Reproduzierbare Runtime-Tests

## Summary
Dieser Plan kombiniert den eigentlichen Fix mit einer reproduzierbaren Teststrategie, damit wir nicht weiter auf manuelles Ingame-Debugging angewiesen sind.

Gesicherter Stand:
- Der Terminalkontext wird jetzt aufgebaut: `renderer=term-gpu`, `tty_gpu=yes`, `invoke_set_ok=yes`.
- Der lokale Framebuffer ist korrekt. `build_screen(...)` plus `term_ui.render_lines(...)` erzeugen Outer Box, Tabs und Panels sauber.
- Die verbleibenden Probleme liegen daher im **Runtime-/Exit-Pfad** und in fehlender reproduzierbarer Abdeckung des echten OC-Terminalverhaltens.

Aktuelle harte Symptome, die der Fix abdecken muss:
1. `unknown error (cleanup: nil)` zeigt einen fehlerhaften Exit-/Fehlervertrag.
2. Nach Beendigung wird die UI sichtbar beschädigt oder überschrieben.
3. Manuelles Testen in Minecraft ist zu langsam und zu unzuverlässig; wir brauchen einen lokalen OC-Harness, der genau diese Fälle automatisiert.

## Wichtige Änderungen
### 1. Exit- und Fehlervertrag deterministisch machen
- In [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua) den Exit-Funnel beibehalten, aber den Contract härten:
  - `make_exit(...)` darf nie ein Fehlerobjekt ohne `message` erzeugen.
  - `normalize_runtime_failure(...)` muss immer ein vollständiges strukturiertes Exit-Objekt zurückgeben.
  - `run()` darf nach `xpcall(...)` kein mehrdeutiges `ok/exit_result`-Handling mehr haben.
- `finalize_exit(...)` muss strikt unterscheiden:
  - kontrollierte Exits: `ok`, `interrupted`, `terminated`
  - echte Fehler: `error`
- `finalize_exit(...)` darf niemals `cleanup: nil` erzeugen.
  - Wenn Cleanup scheitert, muss ein echter String vorhanden sein.
  - Wenn kein Cleanup-Fehler vorliegt, darf der Suffix gar nicht angehängt werden.
- `term_ui.flush(...)` auf einen klaren Rückgabevertrag festziehen:
  - Erfolg: `true`
  - Fehler: `nil, <string>`
  - nie `false`
  - nie `nil, nil`

### 2. Cleanup technisch korrekt und idempotent machen
- Cleanup nicht nur als “leer flushen”, sondern als vollständigen Editor-Abbau definieren:
  - leeren Frame über die gesamte Viewport-Fläche rendern
  - `term_ui`-Framecache zurücksetzen
  - Cursor auf `1,1`
  - optional zusätzlich `term.clear()` oder `term.clearLine()` nur dann, wenn der Fullscreen-Flush nicht ausreicht
- Cleanup muss mehrfach sicher aufrufbar sein, ohne Folgefehler.
- Cleanup darf keine Diagnose- oder Shell-Zeilen in den Editorbereich zurücklassen.
- `terminated` wird nach Cleanup als kontrollierter Exit behandelt und nicht wieder an die Shell hochgereicht.

### 3. Runtime-Status von Diagnose strikt trennen
- Im normalen Run darf `state.message` niemals technische Rendererdiagnose enthalten.
- `diagnose-ui` bleibt der einzige vollständige Diagnosepfad.
- Falls im normalen Run Telemetrie gebraucht wird, dann nur sehr knapp, z. B. `Ready`, `Validation OK`, `Saved`, `Canceled`.
- Keine automatische Diagnosezeile beim Resize oder Kontext-Refresh.

### 4. Tier-2/Tier-3-Layout finalisieren
- `80x25` bleibt `compact`.
- `160x50` bleibt `comfort`.
- Die Layoutlogik in `layout_for(...)` wird nicht weiter erweitert; stattdessen wird im Harness verifiziert, dass beide Monitorgrößen den erwarteten finalen Frame erzeugen.
- Ziel ist nicht, noch mehr Layoutvarianten zu erfinden, sondern die existierenden stabil reproduzierbar zu machen.

## OC-Harness Und Teststrategie
### 1. Neuen lokalen OC-UI-Harness hinzufügen
- Einen dedizierten Test/Harness unter [`tests/previews/term_ui_preview.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/previews/term_ui_preview.lua) erweitern oder einen separaten Harness ergänzen, z. B. `tests/previews/route_book_editor_oc_harness.lua`.
- Der Harness soll OpenOS-relevante Runtime nachbilden:
  - `component`
  - `term`
  - `tty`
  - GPU-Proxy mit `invoke`-Fallback
  - Viewport
  - `term.getGlobalArea()`
  - Eventqueue für `touch`, `scroll`, `key_down`, `clipboard`, `interrupted`
- Ziel ist nicht ein Minecraft-Emulator, sondern ein **OC-Terminal-Harness**, der den echten Render-/Exit-Pfad kontrolliert nachstellt.

### 2. Was der Harness explizit prüfen muss
- Start auf `80x25`
  - tier=`compact`
  - finale sichtbare Zeilen 1-5 enthalten Outer Box, Titel und Tabs
  - Buttons sind im unteren Bereich korrekt positioniert
- Start auf `160x50`
  - tier=`comfort`
  - Outer Box, Tabs, linkes und rechtes Panel korrekt
- Cleanup nach kontrolliertem Exit
  - Editorbereich wird aktiv geleert
  - Cursor wird zurückgesetzt
  - keine stale Frame-Reste bleiben im simulierten Screenbuffer
- `interrupted`-Pfad
  - kein Fehlertext
  - kein `terminated`
  - Cleanup läuft
- Fehlerpfad
  - erzwungener Renderfehler oder künstlicher Flush-Fehler
  - Ergebnis ist ein deterministischer Fehlerstring
  - niemals `unknown error`
  - niemals `cleanup: nil`

### 3. Golden-Frame-/Snapshot-Prüfung
- Für `80x25` und `160x50` je einen kleinen Golden-Frame-Check definieren:
  - nicht der komplette Screen als Riesen-Snapshot
  - sondern gezielt 6-10 Schlüsselzeilen und markante Spaltenbereiche
- So lässt sich erkennen:
  - ob die Kopfzeilen wirklich vor dem Exit vorhanden waren
  - ob der Schaden erst beim Exit entsteht
  - ob das Layout selbst regressiert

### 4. Optionaler echter Host-Smoketest
- Nicht als primäre Strategie.
- Optional als spätere Phase kann ein kleiner Host-Smoketest ergänzt werden, wenn gewünscht:
  - PrismLauncher/Minecraft-Fenster fokussieren
  - Tastatur-/Mausaktionen simulieren
  - Screenshot erfassen
- Das ist nur ein Zusatz-Sanity-Check, nicht die Hauptabdeckung.
- Der Hauptgewinn muss aus dem lokalen OC-Harness kommen.

## Konkrete Implementierungspunkte
### `route_book_editor.lua`
- `run()`:
  - `xpcall(...)`-Pfad vereinfachen
  - Ergebnisnormalisierung sofort nach `xpcall`
  - kein implizites Defaulting auf fehlerhafte leere Exitobjekte
- `normalize_runtime_failure(...)`:
  - immer vollständige strukturierte `make_exit("error", ..., <string>)`
  - unbekannte Fehlerobjekte robust serialisieren
- `finalize_exit(...)`:
  - Cleanup-Rückgabe strikt normalisieren
  - `cleanup_error` nur setzen, wenn wirklich ein String-Fehler existiert
  - kontrollierte Exits nie als Shell-Fehler melden
- `run_loop(...)`:
  - nur strukturierte Exitobjekte zurückgeben
  - keine gemischten `true`/`nil,err`-Returns im Loop

### `term_ui.lua`
- `flush(...)`:
  - klarer Rückgabevertrag
  - Cleanup-Leerframe mit leerem Buffer muss sicher funktionieren
- `reset_cache()`:
  - explizit öffentlich und testbar halten

### Tests
- Bestehende Preview-Tests weiterverwenden, aber um echte Runtime-Szenarien erweitern:
  - Start
  - Frame-Assertion
  - Eventfolge
  - Exitfolge
  - Cleanupfolge
  - Fehlerfolge

## Testplan
### Unit-/Preview-Level
- `parse_cli_mode(...)` bleibt grün.
- `startup_summary(...)` gibt im normalen Run keine Diagnose zurück.
- `finalize_exit(...)`:
  - `ok`
  - `interrupted`
  - `terminated`
  - `error`
  jeweils mit und ohne Kontext
- `term_ui.flush(...)`:
  - Erfolgspfad
  - Invoke-Fallback
  - leerer Buffer für Cleanup
  - deterministische Fehler bei ungültiger GPU

### OC-Harness-Level
- `80x25` Startframe vor Exit prüfen.
- `160x50` Startframe vor Exit prüfen.
- `Esc`-Exit simulieren und finalen Screenbuffer danach prüfen.
- `interrupted` simulieren und denselben Cleanup prüfen.
- künstlichen Flush-Fehler injizieren und finalen Fehlerstring prüfen.

### Manuelle Abnahme im Spiel
- Nur noch kurze Smoke-Checks:
  - `lua route_book_editor.lua`
  - `lua route_book_editor.lua diagnose-ui`
  - ein Start auf Tier-2
  - ein Start auf Tier-3
  - ein sofortiger Exit
- Die eigentliche Ursachenanalyse soll danach nicht mehr im Spiel stattfinden.

## Annahmen und Defaults
- Wir bauen keinen Minecraft-/OpenComputers-Voll-Emulator.
- Wir bauen einen lokalen OC-Terminal-Harness, der genau den relevanten Render-/Event-/Exit-Pfad des Editors simuliert.
- Hostseitige GUI-Automation ist optional und nachrangig.
- Der andere Agent soll Fix und Harness zusammen implementieren; der Harness ist kein „später vielleicht“, sondern Teil des eigentlichen Fixpakets.
