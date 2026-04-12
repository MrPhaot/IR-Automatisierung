# Ergänzungsplan: Stale `package.loaded`-Module Im OpenOS-Shellprozess Robust Beheben

## Summary
Der aktuelle Crashpfad wird durch stale Projektmodule im OpenOS-Shellprozess verursacht. `lua.lua` startet Programme im bestehenden Lua-Umfeld; `package.loaded` bleibt erhalten. Dadurch können nach Deploy oder mehreren Läufen alte Instanzen von `lib.term_ui`, `lib.oc_proxy` und weiteren Projektlibs weiterverwendet werden, obwohl die Dateien auf Disk bereits aktuell sind.

Der Fix muss deshalb **projektlokale Module vor jedem Skriptstart explizit aus `package.loaded` entfernen** oder über einen projektlokalen Frischlade-Helper laden. Ohne diesen Schritt bleibt der Editor nondeterministisch und kann trotz aktueller Dateien weiter mit alter Modul-API laufen.

## Implementierungsänderungen
### 1. Projektlokalen Fresh-Require-Helper einführen
- In den betroffenen OpenOS-Skripten einen kleinen Helper ergänzen, z. B.:
```lua
local function fresh_require(name)
  if package and package.loaded then
    package.loaded[name] = nil
  end
  return require(name)
end
```
- Nur für **projektlokale** Module verwenden, nicht für OpenOS-Kernmodule wie `component`, `event`, `term`, `tty`, `keyboard`, `unicode`.

### 2. `route_book_editor.lua` auf Frischladen umstellen
- In [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua) diese Module nicht mehr per normalem `require(...)`, sondern per `fresh_require(...)` laden:
  - `lib.route_book_store`
  - `lib.augment_registry`
  - `lib.oc_proxy`
  - `lib.term_ui`
- `station_dispatch.lua` wird bereits per `loadfile(...)` geladen; innerhalb dieses Chunks müssen aber dessen eigene Projektlibs ebenfalls frisch geladen werden.

### 3. Dasselbe in den transitiv geladenen Skripten
- In [`station_dispatch.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/station_dispatch.lua) ebenfalls `fresh_require(...)` für:
  - `lib.route_book_store`
  - `lib.augment_registry`
  - `lib.station_schedule`
  - `lib.redstone_io`
- In [`train_controller.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua) dieselbe Strategie für projektlokale Libs, falls vorhanden.
- Ziel: Jeder Shell-Start bekommt konsistent die aktuelle Projektlogik von Disk, auch wenn der Shellprozess alt ist.

### 4. Diagnose härten
- `diagnostic_summary(...)` in [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua) unverändert lassen, aber die neue Regression explizit absichern:
  - Nach dem Fix muss `diagnose-ui` unter Cache-Vergiftung trotzdem `api=v2` melden.
- Keine zusätzliche Diagnoseheuristik nötig; der Cache-Fix ist die eigentliche Ursachebehebung.

## Emulator-/Testergänzungen
### 1. Persistent-Shell-Cache-Regressionsfall
- [`route_book_editor_emulator.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/previews/route_book_editor_emulator.lua) um einen Test ergänzen, der **genau den Ingame-Fall** modelliert:
  - innerhalb eines `with_runtime(...)`
  - `package.loaded["lib.term_ui"]` absichtlich mit einer stale Modulinstanz vergiften:
    - `API_VERSION = nil`
    - `flush = function() return false, nil end`
  - danach `process.run_script("./programs/route_book_editor.lua", {"diagnose-ui"}, ...)`
  - Erwartung nach Fix:
    - Diagnose enthält **nicht** `api=v?`
    - Diagnose enthält `api=v2`
  - danach normaler Run:
    - darf **nicht** `unknown error (cleanup: unknown error)` liefern

### 2. Optional dieselbe Regression für `lib.oc_proxy`
- Zweiten Testfall ergänzen, der `package.loaded["lib.oc_proxy"]` vergiftet.
- Ziel: projektweit absichern, dass nicht nur `term_ui`, sondern auch andere lokale Libs frisch geladen werden.

### 3. Bestehende Tests beibehalten
- Die aktuellen Emulator-Top-Level-Tests bleiben:
  - normaler Run
  - kombinierter Render-/Cleanup-Fehler
  - `event_pull_terminated`
  - Keyboard-/Clipboard-Adressfilterung
- Der neue Cache-Test ist zusätzlich und muss den bisherigen Screenshot-Pfad explizit abdecken.

## Annahmen
- Der beobachtete Ingame-Crash wird primär durch stale `package.loaded`-Einträge verursacht, nicht durch die Dateien auf Disk.
- Die Disk-Dateien sind aktuell; der Shellprozess ist das Problem.
- `route_book.lua` unterscheidet sich zwischen Workspace und OC-Instanz, ist aber nach aktuellem Stand nicht der Auslöser dieses speziellen Crashpfads.
