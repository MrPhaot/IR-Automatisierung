# Transparenter OC/OpenOS-Emulator Für Das IR-Projekt

## Summary
Der bestehende `route_book_editor`-Harness ist als Smoke-Test sinnvoll, ersetzt aber die Ingame-Fehlersuche nicht. Der Ersatz dafür ist kein weiterer ad-hoc Stub, sondern ein **gemeinsamer, transparenter Emulator**, der genau die im Projekt genutzte OC-/OpenOS-Oberfläche abbildet und Programme **end-to-end über `run(argv)`** ausführt.

Der Emulator muss auf dem realen Stand des Mods aufsetzen:
- OpenComputers-Tiers: `50x16`, `80x25`, `160x50`
- Screen/Keyboard-Kopplung, Ownership-/Usability-Gating
- Client/Server-TextBuffer-/Terminalpfad
- Events wie `touch`, `clipboard`, `screen_resized`, `interrupted`
- Die im Projekt tatsächlich benutzten APIs:
  - `component`, `event`, `term`, `tty`, `keyboard`, `unicode`, `computer`, `filesystem`, `shell`
  - Komponenten: `gpu`, `screen`, `keyboard`, `redstone`, `ir_remote_control`, generische adressierte Proxies

Der Emulator ist **nicht** Minecraft- oder Voll-OC-Emulator. Er ist aber vollständig für **alle im Repo benutzten Features**.

## Zielstruktur
```text
immersive_railroading/tests/emulator/
  runtime.lua
  preload.lua
  process.lua
  util.lua
  modules/
    component.lua
    event.lua
    term.lua
    tty.lua
    keyboard.lua
    unicode.lua
    computer.lua
    filesystem.lua
    shell.lua
  components/
    gpu.lua
    screen.lua
    keyboard.lua
    redstone.lua
    ir_remote_control.lua
    generic.lua
immersive_railroading/tests/previews/
  route_book_editor_emulator.lua
  station_dispatch_emulator.lua
  train_controller_emulator.lua
```

## Kernarchitektur
### 1. Runtime als einzige Wahrheit
`runtime.lua` baut eine vollständige simulierte Maschine. Alle Modul- und Komponentenobjekte greifen nur auf diesen Zustand zu.

```lua
local function make_runtime(spec)
  local rt = {
    time = spec.time or 0,
    next_address = 1,
    logs = {
      invocations = {},
      signals = {},
      shell = {},
      screen_syncs = {},
    },
    components = {
      by_address = {},
      by_type = {},
      primary = {},
    },
    signals = {},
    windows = {},
    shell = {
      cwd = spec.cwd or "/home/immersive_railroading/programs",
      prompt = spec.prompt or "/home/immersive_railroading/programs # ",
      stdout = {},
      stderr = {},
    },
    text = {
      server = {},
      client = {},
      dirty = {},
    },
    ownership = {
      enabled = spec.can_computers_be_owned ~= false,
      player = spec.player or "player",
    },
  }
  return rt
end
```

Pflichtregeln:
- `server`-Buffer ist die GPU-/TTY-Zieloberfläche.
- `client`-Buffer ist die sichtbare Oberfläche nach Sync.
- Jeder GPU-Write schreibt **nur** in `server`, danach synchronisiert `runtime:sync_screen(screen_address)`.
- Tests prüfen immer den **sichtbaren** `client`-Buffer, nicht den Rohbuffer.

### 2. Require-/Global-Injektion
`preload.lua` stellt die OC/OpenOS-Module unter ihren echten Namen bereit. Programme werden unverändert per `loadfile(...)` geladen.

```lua
local function with_runtime(spec, fn)
  local rt = make_runtime(spec)
  local saved_loaded = {}
  local saved_preload = {}
  local names = {"component","event","term","tty","keyboard","unicode","computer","filesystem","shell"}

  for _, name in ipairs(names) do
    saved_loaded[name] = package.loaded[name]
    saved_preload[name] = package.preload[name]
    package.loaded[name] = nil
    package.preload[name] = function()
      return require("tests.emulator.modules." .. name).make(rt)
    end
  end

  local saved_component = rawget(_G, "component")
  local saved_computer = rawget(_G, "computer")
  _G.component = require("component")
  _G.computer = require("computer")

  local ok, a, b, c = xpcall(function() return fn(rt) end, debug.traceback)

  _G.component = saved_component
  _G.computer = saved_computer
  for _, name in ipairs(names) do
    package.loaded[name] = saved_loaded[name]
    package.preload[name] = saved_preload[name]
  end

  if not ok then error(a) end
  return a, b, c
end
```

Pflicht:
- `component` und `computer` auch als globale Namen setzen, weil [`station_dispatch.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/station_dispatch.lua) und [`train_controller.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua) `rawget(_G, ...)` bevorzugen.
- Keine Inline-Stubs mehr in einzelnen Tests.

## Modulverträge
### `component`
Pflichtoberfläche:
- `isAvailable(kind) -> boolean`
- `getPrimary(kind) -> proxy|nil`
- `proxy(address) -> proxy|nil`
- `invoke(address, method, ...) -> ...`
- Live-Aliase `component.gpu`, `component.screen`, `component.keyboard`, `component.redstone`, `component.ir_remote_control`

Exaktes Proxy-Modell:
- Jeder Komponententyp unterstützt `proxy_mode = "direct"` oder `"invoke_only"`.
- `direct`: `component.proxy(address).method` ist direkt sichtbar.
- `invoke_only`: Proxy ist `{address=...}` ohne Methoden; Aufrufe gehen über `component.invoke`.
- Default:
  - `gpu`: `"invoke_only"` testen
  - `screen`: `"invoke_only"`
  - `keyboard`: `"invoke_only"`
  - `redstone`: `"direct"`
  - `ir_remote_control`: `"direct"`
- Das spiegelt den aktuellen Projektzustand mit [`oc_proxy.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/oc_proxy.lua).

Implementierung:
```lua
function component.invoke(address, method, ...)
  local c = rt.components.by_address[address]
  assert(c, "no such component: " .. tostring(address))
  local fn = c.methods[method]
  assert(type(fn) == "function", "no such method: " .. tostring(method))
  rt.logs.invocations[#rt.logs.invocations + 1] = {address=address, method=method, args={...}}
  return fn(c, ...)
end
```

### `event`
Pflichtoberfläche:
- `pull(timeout) -> signal, ...`
- `push(signal, ...)`
- `clear()`

Verhalten:
- `pull(timeout)`:
  - Wenn Queue nicht leer: erstes Signal liefern.
  - Wenn Queue leer und `timeout` gesetzt: `rt.time = rt.time + timeout`; dann `nil` liefern.
  - Vor Rückgabe jedes `pull` einmal `rt:tick(timeout or 0)` ausführen, damit Pulslängen, Resize und Shell-Nachlauf reproduzierbar laufen.
- Exakte Signalformen:
  - `{"key_down", keyboard_address, char_code, key_code, player}`
  - `{"clipboard", keyboard_address, text, player}`
  - `{"touch", screen_address, x, y, button, player}`
  - `{"scroll", screen_address, x, y, delta, player}`
  - `{"drag", screen_address, x, y, button, player}`
  - `{"drop", screen_address, x, y, button, player}`
  - `{"interrupted"}`
  - `{"screen_resized", screen_address, width, height}`

### `computer`
Pflichtoberfläche:
- `uptime() -> number`
- optional `pullSignal(timeout)` als Alias zu `event.pull`, falls später benötigt

```lua
function computer.uptime()
  return rt.time
end
```

### `unicode`
Pflichtoberfläche:
- `char(code)`
- optional `len`, `sub` nur wenn Tests sie brauchen
- Für jetzt reicht:
```lua
function unicode.char(code)
  return utf8.char(code)
end
```

### `filesystem`
Pflichtoberfläche nur für den Projektumfang:
- `exists(path) -> boolean`
- `makeDirectory(path) -> true`
- optional `isDirectory(path)` wenn Tests es brauchen
- Interner Zustand: `rt.fs.nodes[path] = {kind="dir"|"file", content=...}`

### `shell`
Pflichtoberfläche:
- `execute(command) -> true | nil, reason`
- `getWorkingDirectory() -> string`
- `setWorkingDirectory(path)` optional
- `execute` muss **nicht** generisch shell-parsen. Es braucht nur den im Projekt verwendeten Fall:
  - `wget -f "<url>" "<path>"`

Implementierung:
```lua
function shell.execute(command)
  local url, path = command:match('^wget %-f "([^"]+)" "([^"]+)"$')
  if not url then
    return nil, "unsupported shell command"
  end
  local body = rt.downloads[url]
  if body == nil then
    return nil, "download unavailable"
  end
  rt.fs.nodes[path] = {kind="file", content=body}
  return true
end
```

### `keyboard`
Pflichtoberfläche:
- `isControlDown() -> boolean`
- Zustand über `rt.input.control_down`
- Für `route_book_editor` reicht das.

### `term`
Pflichtoberfläche:
- `gpu() -> gpu_proxy|nil`
- `screen() -> screen_address|nil`
- `keyboard() -> keyboard_address|nil`
- `getGlobalArea() -> x, y, width, height`
- `setCursor(x, y)`
- `getCursor()`
- `clear()`

Verhalten:
- `clear()` leert **den aktuellen Fensterbereich** im `server`-Buffer der gebundenen Screenfläche.
- `getGlobalArea()` kommt aus `rt.windows.active = {x,y,width,height,screen_address,keyboard_address,gpu_address}`.
- Default-Fenster:
  - Vollbild `1,1,width,height`
  - Tests müssen aber Subwindows explizit setzen können.

### `tty`
Pflichtoberfläche:
- `isAvailable() -> true|false`
- `gpu() -> gpu_proxy|nil`
- `bind(gpu_proxy) -> true|nil, reason`
- `getViewport() -> width, height, dx, dy, x, y`

Exaktes Verhalten:
- `tty.bind(gpu)` verbindet die aktive `term`-Window-Instanz mit genau dieser GPU.
- `tty.getViewport()` liefert immer **6 Werte**.
- Default-Rückgabe:
```lua
return win.width, win.height, 0, 0, 1, 1
```

## Komponenten
### `gpu`
Pflichtmethoden:
- `bind(screen_address[, reset])`
- `getScreen()`
- `getResolution()`
- `set(x, y, text[, vertical])`
- `fill(x, y, width, height, char)`

Verhalten:
- `bind` verknüpft GPU mit Screen und setzt `component.screen`/`component.gpu` Primaries, falls der Screen primär ist.
- `set` und `fill` schreiben in `rt.text.server[screen_address]`, danach `rt:sync_screen(screen_address)`.
- `setResolution` ist nicht nötig, weil Screen-Tier die Auflösung vorgibt.

### `screen`
Zustand:
```lua
{
  type = "screen",
  tier = 2 or 3,
  width = 80 or 160,
  height = 25 or 50,
  precise = tier == 3,
  keyboards = { ["kbd-1"] = true },
  usable = true,
  owner = nil,
}
```

### `keyboard`
Zustand:
- `screen_address`
- `usable`
- `owner`
- Nicht-attachte Keyboards liefern keine Events für diesen Screen.

### `redstone`
Pflichtmethoden:
- `setOutput(side, value)`
- `getOutput(side)`
- `getInput(side)` optional, aber gleich mitbauen
- Zustand:
```lua
outputs = {top=0,bottom=0,left=0,right=0,front=0,back=0,north=0,south=0,east=0,west=0}
inputs = {}
```
- `setOutput` muss den gesetzten Wert loggen, damit [`redstone_io.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/redstone_io.lua) sauber testbar ist.

### `ir_remote_control`
Pflichtmethoden aus dem echten Projektgebrauch:
- `info()`
- `consist()`
- `getPos()`
- `setThrottle(value)`
- `setReverser(value)`
- `setBrake(value)`
- `setIndependentBrake(value)`
- `getIgnition()`
- `setIgnition(value)`

Default-Zustand:
```lua
state = {
  throttle = 0,
  reverser = 0,
  brake = 0,
  independent_brake = 0,
  ignition = false,
  pos = {x=0,y=64,z=0},
  info = {},
  consist = {},
}
```

### `generic`
Für Detektoren und andere adressierte Geräte:
- Frei registrierbare Methoden
- Für `station_dispatch` reicht typischerweise `info()`

## Bildschirm-/Terminalmodell
### Client/Server-Textbuffer
`runtime.lua` braucht diese drei Funktionen:

```lua
function rt:ensure_screen_buffers(screen_address, width, height) ... end
function rt:sync_screen(screen_address) ... end
function rt:visible_lines(screen_address) ... end
```

Pflichtverhalten:
- `ensure_screen_buffers` legt leere Matrizen für `server` und `client` an.
- `sync_screen` kopiert `server` nach `client` und protokolliert `screen_syncs`.
- `visible_lines` liefert eine Stringliste der sichtbaren Client-Zeilen; Tests dürfen nur diese lesen.

### Shell-Nachlauf
`process.lua` modelliert den Post-Exit-Pfad:
- `run_program(chunk, argv)` führt `run(argv)` im `xpcall` aus.
- Nach Ende des Programms kann optional `runtime:shell_redraw()` ausgeführt werden.
- `shell_redraw()` schreibt Prompt, Fehlertext oder `terminated` in den **sichtbaren Clientbuffer**.
- Damit wird exakt der Fehler geprüft, der im Spiel als “UI nach Exit kaputt” auftrat.

## Input-/Ownership-Modell
Pflichtregeln:
- Wenn `rt.ownership.enabled == true`, dann werden Input-Events nur akzeptiert, wenn `event.player == screen.owner` oder `screen.owner == nil`.
- `touch` und `key_down` mit falscher Adresse oder falschem Owner werden **nicht** in die Queue gelegt.
- Tier 3 darf präzisere Eingaben erzeugen; der Emulator liefert aber weiterhin Rasterkoordinaten an Lua. Optionaler Zusatz: `raw_x`, `raw_y` im Log.

Helper:
```lua
function rt:queue_touch(screen_address, x, y, button, player)
  local screen = self.components.by_address[screen_address]
  if not screen.usable then return end
  if self.ownership.enabled and screen.owner and player ~= screen.owner then return end
  table.insert(self.signals, {"touch", screen_address, x, y, button or 0, player or self.ownership.player})
end
```

## Test-Suites
### `route_book_editor_emulator.lua`
Pflichtfälle:
1. `run({})` auf Tier 2 mit `80x25` ergibt `compact`.
2. `run({})` auf Tier 3 mit `160x50` ergibt `comfort`.
3. Startframe enthält Outer Box, Tabs, Panels.
4. `touch` auf Tabs/Buttons funktioniert nur vom richtigen Screen.
5. `clipboard` und Modalfeldeingabe funktionieren nur vom richtigen Keyboard.
6. Subwindow mit `origin_x ~= 1` und `origin_y ~= 1` rendert und klickt korrekt.
7. `screen_resized` wechselt sauber zwischen `80x25` und `160x50`.
8. `interrupted` endet ohne Fehlertext.
9. künstlicher GPU-Fehler endet deterministisch, niemals `unknown error`, niemals `cleanup: nil`.
10. Post-Exit-Shell-Prompt überschreibt den Clientbuffer sauber, ohne alte UI-Reste.

### `station_dispatch_emulator.lua`
Pflichtfälle:
1. `component.ir_remote_control` vorhanden -> Schedulelauf startet.
2. Detektorproxy per `component.proxy(address)` + `info()` funktioniert.
3. `component.redstone.setOutput(...)` wird bei `while_pending` korrekt gesetzt.
4. Pulse via `pulse_ticks` laufen über Simulationszeit und enden korrekt.
5. Fehlender `redstone`-Proxy liefert den erwarteten Fehlerstring.
6. Event-/Zeitpfad über `event.pull` und `computer.uptime` ist reproduzierbar.

### `train_controller_emulator.lua`
Pflichtfälle:
1. `remote.info`, `remote.consist`, `remote.getPos` lesbar.
2. `setThrottle`, `setReverser`, `setBrake`, `setIndependentBrake` werden in der erwarteten Reihenfolge geschrieben.
3. `getIgnition`/`setIgnition` funktionieren.
4. Loggerpfad nutzt `filesystem.exists`/`makeDirectory` korrekt.
5. Fehler in `remote.getPos` oder `remote.info` propagieren deterministisch.

## Implementierungsreihenfolge
1. `runtime.lua`, `preload.lua`, `component.lua`, `event.lua`, `computer.lua`, `unicode.lua`
2. `gpu.lua`, `screen.lua`, `keyboard.lua`, `term.lua`, `tty.lua`
3. `process.lua` mit Shell-Nachlauf und sichtbarem Clientbuffer
4. `redstone.lua`, `ir_remote_control.lua`, `generic.lua`
5. `filesystem.lua`, `shell.lua`
6. `route_book_editor_emulator.lua`
7. `station_dispatch_emulator.lua`
8. `train_controller_emulator.lua`
9. Bestehenden `route_book_editor_oc_harness.lua` nur als Fast-Smoke behalten, nicht als Hauptabdeckung

## Öffentliche/Interne Interfaces
Neue interne API des Emulators:
```lua
local emulator = require("tests.emulator.preload")

emulator.with_runtime({
  screen = {tier = 2, owner = "alice"},
  window = {x = 1, y = 1},
  proxy_mode = {gpu = "invoke_only", screen = "invoke_only"},
  downloads = {["https://..."] = "file-body"},
}, function(rt)
  local chunk = assert(loadfile("programs/route_book_editor.lua"))
  local mod = chunk("__module__")
  local ok, err = mod.run({})
  local lines = rt:visible_lines(rt.term.screen_address)
end)
```

Pflicht-Helper auf `rt`:
- `register_screen(spec)`
- `register_keyboard(spec)`
- `register_gpu(spec)`
- `register_redstone(spec)`
- `register_ir_remote_control(spec)`
- `register_component(kind, spec)`
- `queue_touch(...)`
- `queue_key_down(...)`
- `queue_clipboard(...)`
- `queue_scroll(...)`
- `queue_interrupted()`
- `sync_screen(screen_address)`
- `visible_lines(screen_address)`

## Annahmen und Defaults
- Es wird **kein** Minecraft-, Forge- oder Voll-OpenComputers-Emulator gebaut.
- Es werden **alle im Projekt tatsächlich genutzten** OC/OpenOS-Features vollständig emuliert.
- Default-Screen ist Tier 2 mit `80x25`; Tier 3 wird in eigenen Tests explizit angelegt.
- Default-GPU/Screen/Keyboard laufen im `invoke_only`-Modus, damit der Emulator die reale Proxy-Problematik weiterhin abdeckt.
- Ownership ist standardmäßig aktiv, passend zu `OpenComputers.cfg`.
- Nicht genutzte OC-Systeme wie Modem, Internet, Robot, Navigation, Datenkarten, Nanomaschinen und Energienetz bleiben bewusst außerhalb des Scopes.
