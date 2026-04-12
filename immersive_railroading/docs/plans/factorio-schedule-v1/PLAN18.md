# `route_book_editor`: Vollständige Overflow-Bereinigung und Emulator-Lifecycle/Leak-Fix

## Summary
Dieser Plan ist die präzisierte, technisch vollständige Version des vorherigen Plans. Er deckt zwei Baustellen ab:

1. **Editor-UI**
   Alle relevanten dynamischen Textflächen im `route_book_editor` werden systematisch von hartem Abschneiden auf eine feste Overflow-Policy umgestellt:
   - **Lesepanels**: Wrap + vertikales Scrollen
   - **Listen, Statuszeile, einzeilige Inputs**: einzeilig bleiben
   - **Modal-Cursor**: nur auf der aktiven Zeile

2. **Emulator**
   Der Emulator bekommt einen sauberen Lebenszyklus, harte Laufzeitgrenzen und begrenzte Logs. Der aktuelle Leak-/Hängerpfad ist plausibel, weil:
   - `process.lua` derzeit keinen echten Timeout/Failsafe hat
   - `runtime.lua` `screen_syncs` unbegrenzt akkumuliert
   - `preload.lua` zwar Module zurücksetzt, aber die Runtime nicht explizit schließt

Wichtig: Die unten stehenden Codestücke sind **statisch gegen den aktuellen Codebestand geprüft und aufeinander abgestimmt**, aber **nicht als fertiger Patch im Sandbox-Workspace eingebaut und getestet**. Sie sind deshalb als Implementierungsvorgabe zu verstehen, nicht als bereits bewiesener Endzustand.

## Verifizierte Ist-Stellen
### 1. Harte Abschneidung im Editor
Aktuelle zentrale Stelle:

```lua
local function render_text(buffer, x, y, text, width)
  buffer[#buffer + 1] = {
    x = x,
    y = y,
    text = width and term_ui.fit_text(text, width) or tostring(text),
  }
end
```

Quelle: [`route_book_editor.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/route_book_editor.lua)

Die Kürzungslogik selbst:

```lua
local function fit_text(text, width)
  text = tostring(text or "")
  width = math.max(width or #text, 0)
  if #text <= width then
    return text .. string.rep(" ", width - #text)
  end
  if width <= 1 then
    return text:sub(1, width)
  end
  return text:sub(1, width - 1) .. ">"
end
```

Quelle: [`term_ui.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/lib/term_ui.lua)

### 2. Alle aktuell relevanten Overflow-Stellen
Diese Stellen sind geprüft und müssen explizit behandelt werden:

Detailpanel allgemein:
```lua
for index, line in ipairs(detail_lines or {}) do
  render_text(buffer, detail_rect.x + 2, detail_rect.y + 1 + index, line, detail_rect.width - 4)
end
```

Schedule Entries:
```lua
render_text(buffer, layout.schedule_entries.x + 2, layout.schedule_entries.y + 1 + index, ("[%d] %s"):format(index, entry.route), layout.schedule_entries.width - 4)
```

Schedule Wait Conditions:
```lua
render_text(buffer, layout.schedule_wait.x + 2, layout.schedule_wait.y + group_index * 2 + 1, ("%s %s %s"):format(first_condition.type, tostring(first_condition.comparator or ">="), tostring(first_condition.value or first_condition.seconds)), layout.schedule_wait.width - 4)
```

Save / Validate:
```lua
render_text(buffer, layout.save.x + 2, layout.save.y + 3 + index, "ERROR: " .. message, layout.save.width - 4)
```

Statuszeile:
```lua
render_text(buffer, 3, layout.status_y, state.message or "", math.max(width - 4, 1))
```

Modal-Cursor-Bug:
```lua
display = display:sub(1, cursor_index - 1) .. "|" .. display:sub(cursor_index)
```

Diese Cursor-Einfügung passiert aktuell sowohl in `modal_field_visible_value(...)` als auch `repeatable_item_visible_value(...)` immer, unabhängig von der aktiven Zeile.

### 3. Verifizierte Emulator-Leak-/Hänger-Stellen
Unbegrenzter Screen-Sync-Log in [`runtime.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/runtime.lua):
```lua
self.logs.screen_syncs[#self.logs.screen_syncs + 1] = {
  screen_address = screen_address,
  lines = util.copy_lines(self.text.client[screen_address]),
  time = self.time,
}
```

Kein deterministischer Abbruch in [`process.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/process.lua):
```lua
local ok, success, err = xpcall(function()
  return entry(argv or {})
end, debug.traceback)
```

Kein Runtime-Close in [`preload.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/preload.lua):
```lua
local ok, a, b, c = xpcall(function()
  return fn(rt)
end, debug.traceback)
...
if not ok then
  error(a)
end
```

Event-Pull ohne Budget in [`modules/event.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/modules/event.lua):
```lua
function event.pull(timeout)
  local terminated = rt:take_failure("event_pull_terminated")
  ...
  rt:tick(timeout or 0)
  local signal = table.remove(rt.signals, 1)
  if not signal then
    return nil
  end
  return table.unpack(signal)
end
```

## Overflow-Policy pro UI-Fläche
### Wrap + vertikales Scrollen
Diese Flächen dürfen mehrzeilig sein und dürfen nie mehr mit `>` abgeschnitten werden:
- `Save / Validate`:
  - Validation-Fehler
  - Hilfetexte
- rechte Detailpanels:
  - Detectors
  - Stations
  - Routes
- `Schedules -> Entries`
- `Schedules -> Wait Conditions`

### Einzeilig bleiben
Diese Flächen bleiben bewusst einzeilig:
- linke Auswahllisten
- Statuszeile
- Modal-Eingabezeilen
- `[+]`- und `[x]`-Zeilen
- Tabs, Buttons, Box-Titel

Regel:
- Lesepanels: vollständiger Text per Wrap/Scroll
- Navigations- und Editierflächen: einzeilig, ggf. horizontales Sichtfenster
- Statuszeile bleibt Kurzstatus, kein Volltextfenster

## Implementierungsänderungen
### A. Neue Helper in `route_book_editor.lua`
Direkt unter `render_text(...)` ergänzen:

```lua
local function split_long_token(token, width)
  local out = {}
  token = tostring(token or "")
  width = math.max(tonumber(width) or 0, 1)
  while #token > width do
    out[#out + 1] = token:sub(1, width)
    token = token:sub(width + 1)
  end
  if token ~= "" then
    out[#out + 1] = token
  end
  return out
end

local function wrap_text(text, width)
  text = tostring(text or "")
  width = math.max(tonumber(width) or 0, 1)
  local lines = {}

  for raw_line in (text .. "\n"):gmatch("(.-)\n") do
    if raw_line == "" then
      lines[#lines + 1] = ""
    else
      local current = ""
      for token in raw_line:gmatch("%S+") do
        if #token > width then
          if current ~= "" then
            lines[#lines + 1] = current
            current = ""
          end
          for _, part in ipairs(split_long_token(token, width)) do
            lines[#lines + 1] = part
          end
        else
          local candidate = current == "" and token or (current .. " " .. token)
          if #candidate <= width then
            current = candidate
          else
            if current ~= "" then
              lines[#lines + 1] = current
            end
            current = token
          end
        end
      end
      if current ~= "" then
        lines[#lines + 1] = current
      end
    end
  end

  if #lines == 0 then
    lines[1] = ""
  end
  return lines
end

local function render_wrapped_lines(buffer, x, y, width, height, lines, scroll_y)
  local flat = {}
  for _, line in ipairs(lines or {}) do
    for _, wrapped in ipairs(wrap_text(line, width)) do
      flat[#flat + 1] = wrapped
    end
  end

  local max_scroll = math.max(#flat - height, 0)
  scroll_y = clamp(scroll_y or 0, 0, max_scroll)

  for row = 1, height do
    local text = flat[scroll_y + row]
    if not text then
      break
    end
    render_text(buffer, x, y + row - 1, text, width)
  end

  return {
    line_count = #flat,
    scroll_y = scroll_y,
    max_scroll = max_scroll,
  }
end

local function inline_view(raw_value, cursor, scroll_x, viewport, show_cursor)
  raw_value = tostring(raw_value or "")
  cursor = clamp(cursor or (#raw_value + 1), 1, #raw_value + 1)
  viewport = math.max(viewport or 1, 1)
  scroll_x = clamp(scroll_x or 0, 0, math.max(#raw_value - viewport, 0))

  if cursor - 1 < scroll_x then
    scroll_x = cursor - 1
  elseif cursor - 1 > scroll_x + viewport then
    scroll_x = cursor - 1 - viewport
  end

  local display = raw_value:sub(scroll_x + 1, scroll_x + viewport)
  if show_cursor then
    local cursor_index = clamp(cursor - scroll_x, 1, viewport + 1)
    display = display:sub(1, cursor_index - 1) .. "|" .. display:sub(cursor_index)
  end

  return display, scroll_x
end
```

### B. Scrollzustände in `new_state()`
`new_state()` ergänzen:

```lua
panel_scrolls = {
  detector_detail = 0,
  station_detail = 0,
  route_detail = 0,
  schedule_entries = 0,
  schedule_wait = 0,
  save = 0,
}
```

### C. Detailpanels auf Wrap umstellen
Aktuelle Funktion:
```lua
local function render_primary_split(buffer, targets, list_rect, detail_rect, title, items, selected_index, area, detail_lines)
```

Neue Signatur:
```lua
local function render_primary_split(buffer, targets, list_rect, detail_rect, title, items, selected_index, area, detail_lines, detail_scroll)
```

Aktuellen Detail-Loop ersetzen durch:

```lua
local detail_height = math.max(detail_rect.height - 3, 0)
render_wrapped_lines(
  buffer,
  detail_rect.x + 2,
  detail_rect.y + 2,
  detail_rect.width - 4,
  detail_height,
  detail_lines,
  detail_scroll or 0
)
```

Alle Call-Sites anpassen:
- Detectors:
```lua
render_primary_split(..., detail_lines, state.panel_scrolls.detector_detail)
```
- Stations:
```lua
render_primary_split(..., detail_lines, state.panel_scrolls.station_detail)
```
- Routes:
```lua
render_primary_split(..., detail_lines, state.panel_scrolls.route_detail)
```

### D. Schedule-Panels auf Wrap umstellen
Aktuellen `Entries`-Direktrender ersetzen:

```lua
local entry_lines = {}
for index, entry in ipairs(schedule.entries or {}) do
  entry_lines[#entry_lines + 1] = ("[%d] %s"):format(index, entry.route or "")
end

render_wrapped_lines(
  buffer,
  layout.schedule_entries.x + 2,
  layout.schedule_entries.y + 2,
  layout.schedule_entries.width - 4,
  math.max(layout.schedule_entries.height - 3, 0),
  entry_lines,
  state.panel_scrolls.schedule_entries
)
```

Aktuellen `Wait Conditions`-Direktrender ersetzen:

```lua
local wait_lines = {}
for group_index, group in ipairs(first_entry.wait.groups or {}) do
  wait_lines[#wait_lines + 1] = ("Group %s"):format(string.char(64 + group_index))
  local first_condition = group[1]
  if first_condition then
    wait_lines[#wait_lines + 1] = ("%s %s %s"):format(
      first_condition.type,
      tostring(first_condition.comparator or ">="),
      tostring(first_condition.value or first_condition.seconds)
    )
  end
end

render_wrapped_lines(
  buffer,
  layout.schedule_wait.x + 2,
  layout.schedule_wait.y + 2,
  layout.schedule_wait.width - 4,
  math.max(layout.schedule_wait.height - 3, 0),
  wait_lines,
  state.panel_scrolls.schedule_wait
)
```

### E. Save / Validate vollständig umbauen
Den aktuellen Save-Block vollständig ersetzen durch:

```lua
term_ui.render_box(buffer, term_ui.box(layout.save.x, layout.save.y, layout.save.width, layout.save.height, "Save / Validate"))
local validation = station_dispatch.validate_route_book(state.book)

local save_lines = {
  ("Dirty: %s"):format(state.dirty and "[*]" or "[ ]"),
  ("Validation: %s"):format(validation.ok and "OK" or "Errors"),
}

for _, message in ipairs(validation.errors or {}) do
  save_lines[#save_lines + 1] = "ERROR: " .. tostring(message)
end

save_lines[#save_lines + 1] = ""
save_lines[#save_lines + 1] = "Run schedule: station_dispatch run <schedule>"
save_lines[#save_lines + 1] = "Run route:    train_controller route <route>"
save_lines[#save_lines + 1] = "Schedules run on the active ir_remote_control train."

render_wrapped_lines(
  buffer,
  layout.save.x + 2,
  layout.save.y + 2,
  layout.save.width - 4,
  math.max(layout.save.height - 3, 0),
  save_lines,
  state.panel_scrolls.save
)
```

`help_y` und alle Einzel-`render_text(...)`-Hilfszeilen entfernen.

### F. Modal-Cursor nur auf aktiver Zeile
Aktuelle Funktionen:

```lua
local function modal_field_visible_value(field, available)
...
display = display:sub(1, cursor_index - 1) .. "|" .. display:sub(cursor_index)
```

```lua
local function repeatable_item_visible_value(field, item, available, item_index)
...
display = display:sub(1, cursor_index - 1) .. "|" .. display:sub(cursor_index)
```

Ersetzen durch:

```lua
local function modal_field_visible_value(field, available, show_cursor)
  local prefix = tostring(field.label or "") .. ": "
  local viewport = math.max(available - #prefix - 1, 1)
  local display, next_scroll_x = inline_view(field.value or "", field.cursor, field.scroll_x, viewport, show_cursor)
  field.scroll_x = next_scroll_x
  return prefix .. display
end

local function repeatable_item_visible_value(field, item, available, item_index, show_cursor)
  local label = item_index == 1 and field.label or string.rep(" ", #tostring(field.label or ""))
  local prefix = ("%s [%d]: "):format(label, item_index)
  local viewport = math.max(available - #prefix - 1, 1)
  local display, next_scroll_x = inline_view(item.value or "", item.cursor, item.scroll_x, viewport, show_cursor)
  item.scroll_x = next_scroll_x
  return prefix .. display
end
```

In `render_modal(...)` exakt so aufrufen:

```lua
local is_active = row_index == modal.active_row

if row.kind == "text" then
  render_text(buffer, x + 2, row_y, prefix .. modal_field_visible_value(row.field, width - 4, is_active), width - 4)
elseif row.kind == "repeat_item" then
  render_text(buffer, x + 2, row_y, prefix .. repeatable_item_visible_value(row.field, row.item, width - 6, row.item_index, is_active), width - 6)
elseif row.kind == "repeat_add" then
  render_text(buffer, x + 2, row_y, prefix .. repeatable_add_visible_value(row.field), width - 4)
end
```

### G. Scrollrouting vervollständigen
Aktuelle Funktion:
```lua
local function handle_scroll(state, direction)
```

Neue Signatur:
```lua
local function handle_scroll(state, direction, x, y, screen)
```

Regeln:
- Wenn `state.modal` aktiv:
  - nur `modal.scroll_y`
- Wenn `active_tab == 5`:
  - `panel_scrolls.save`
- Wenn `active_tab == 4`:
  - Scroll in `layout.schedule_entries` -> `panel_scrolls.schedule_entries`
  - Scroll in `layout.schedule_wait` -> `panel_scrolls.schedule_wait`
  - sonst wie bisher Listen-Auswahlscroll
- Wenn `active_tab == 1/2/3`:
  - Scroll in rechtem Detailpanel -> jeweiliger Detailscroll
  - sonst wie bisher Listen-Auswahlscroll

Im `run(...)`-Loop den Scroll-Call ändern von:
```lua
if handle_scroll(state, direction) then
```
zu:
```lua
local local_x, local_y = normalize_pointer_event(context, pulled[2], pulled[3], pulled[4])
if handle_scroll(state, direction, local_x, local_y, screen) then
```

### H. Statuszeile bleibt bewusst einzeilig
Diese Zeile bleibt unverändert:
```lua
render_text(buffer, 3, layout.status_y, state.message or "", math.max(width - 4, 1))
```

Begründung:
- Statuszeile ist Kurzstatus, kein Volltextfenster
- längere fachliche Texte müssen im jeweiligen Panel vollständig lesbar sein

### I. Emulator-Runtime schließbar machen
In [`runtime.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/runtime.lua) ergänzen:

```lua
function rt:close()
  if self.closed then
    return
  end
  self.closed = true
  self.signals = {}
  self.timers = {}
  self.windows = {}
  self.term = nil
  self.text.server = {}
  self.text.client = {}
  self.text.dirty = {}
  self.components.by_address = {}
  self.components.by_type = {}
  self.components.primary = {}
  self.shell.stdout = {}
  self.shell.stderr = {}
  self.logs.invocations = {}
  self.logs.signals = {}
  self.logs.shell = {}
  self.logs.screen_syncs = {}
  self.logs.redstone = {}
  self.logs.remote = {}
end
```

### J. `with_runtime(...)` in `preload.lua` auf echtes Cleanup umstellen
Neue Hilfsfunktion:

```lua
local function restore_modules(saved_loaded, saved_preload, saved_component, saved_computer, rt)
  _G.component = saved_component
  _G.computer = saved_computer

  for _, name in ipairs(MODULES) do
    package.loaded[name] = saved_loaded[name]
    package.preload[name] = saved_preload[name]
  end

  for _, name in ipairs(PROJECT_MODULES) do
    package.loaded[name] = saved_loaded[name]
  end

  if rt then
    pcall(function()
      rt:close()
    end)
  end
end
```

`with_runtime(...)` dann als:

```lua
function M.with_runtime(spec, fn)
  local rt = runtime.make_runtime(spec or {})
  local saved_loaded = {}
  local saved_preload = {}

  for _, name in ipairs(MODULES) do
    saved_loaded[name] = package.loaded[name]
    saved_preload[name] = package.preload[name]
    package.loaded[name] = nil
    package.preload[name] = function()
      return require("tests.emulator.modules." .. name).make(rt)
    end
  end

  for _, name in ipairs(PROJECT_MODULES) do
    saved_loaded[name] = package.loaded[name]
    package.loaded[name] = nil
  end

  local saved_component = rawget(_G, "component")
  local saved_computer = rawget(_G, "computer")
  _G.component = require("component")
  _G.computer = require("computer")

  local ok, a, b, c = xpcall(function()
    return fn(rt)
  end, debug.traceback)

  restore_modules(saved_loaded, saved_preload, saved_component, saved_computer, rt)

  if not ok then
    error(a)
  end
  return a, b, c
end
```

### K. Screen-Sync-Logs hart begrenzen
In `make_runtime(spec)` ergänzen:

```lua
limits = {
  max_screen_syncs = (spec.limits and spec.limits.max_screen_syncs) or 128,
  max_event_pulls = (spec.limits and spec.limits.max_event_pulls) or 2000,
},
metrics = {
  event_pulls = 0,
},
```

In `sync_screen(...)` ersetzen:

```lua
local log = self.logs.screen_syncs
log[#log + 1] = {
  screen_address = screen_address,
  lines = util.copy_lines(self.text.client[screen_address]),
  time = self.time,
}
if #log > self.limits.max_screen_syncs then
  table.remove(log, 1)
end
```

### L. Event-Pull-Budget einführen
In [`modules/event.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/emulator/modules/event.lua):

```lua
function event.pull(timeout)
  rt.metrics.event_pulls = rt.metrics.event_pulls + 1
  if rt.metrics.event_pulls > rt.limits.max_event_pulls then
    error({
      reason = "timeout",
      code = 124,
      message = "event pull limit exceeded",
    }, 0)
  end

  local terminated = rt:take_failure("event_pull_terminated")
  if terminated then
    error({
      reason = "terminated",
      code = terminated.code or 130,
      message = terminated.message or "terminated",
    }, 0)
  end

  rt:tick(timeout or 0)
  local signal = table.remove(rt.signals, 1)
  if not signal then
    return nil
  end
  return table.unpack(signal)
end
```

### M. `process.lua` timeout- und cleanup-sicher machen
Neue Helper:

```lua
local function is_terminated(err)
  return type(err) == "table" and err.reason == "terminated"
end

local function is_timeout(err)
  return type(err) == "table" and err.reason == "timeout"
end
```

`run_program(...)` ersetzen durch:

```lua
function M.run_program(program, argv, options)
  options = options or {}
  local entry
  if type(program) == "table" then
    entry = program.run or program.main
  elseif type(program) == "function" then
    entry = program
  end
  assert(type(entry) == "function", "program must expose run(argv) or main(argv)")

  local ok, success, err = xpcall(function()
    return entry(argv or {})
  end, function(problem)
    return problem
  end)

  local result_ok, result_err
  if ok then
    if success == nil then
      result_ok = nil
      result_err = tostring(err)
    else
      result_ok = true
    end
  elseif is_terminated(success) then
    result_ok = true
  elseif is_timeout(success) then
    result_ok = nil
    result_err = "emulator timeout: " .. tostring(success.message or "timeout")
  else
    result_ok = nil
    result_err = tostring(success)
  end

  if options.runtime and options.shell_redraw then
    options.runtime:shell_redraw(result_ok and nil or tostring(result_err))
  end

  return result_ok, result_err
end
```

`run_script(...)` so umbauen, dass `io.stderr`, `io.write` und `os.exit` immer restauriert werden, auch bei Fehlern. Struktur:

```lua
function M.run_script(path, argv, options)
  options = options or {}
  local runtime = options.runtime
  local saved_stderr = io.stderr
  local saved_io_write = io.write
  local saved_os_exit = os.exit
  local stderr_lines = {}
  local stdout_lines = {}

  io.stderr = {
    write = function(_, text)
      text = tostring(text or "")
      stderr_lines[#stderr_lines + 1] = text
      if runtime then
        runtime.shell.stderr[#runtime.shell.stderr + 1] = text
      end
      return true
    end,
  }

  io.write = function(...)
    local parts = {}
    for index = 1, select("#", ...) do
      parts[#parts + 1] = tostring(select(index, ...))
    end
    local text = table.concat(parts)
    stdout_lines[#stdout_lines + 1] = text
    if runtime then
      runtime.shell.stdout[#runtime.shell.stdout + 1] = text
    end
    return true
  end

  os.exit = function(code)
    error({
      reason = "terminated",
      code = code or 0,
      message = "terminated",
    }, 0)
  end

  local ok, result, extra = xpcall(function()
    local chunk = assert(loadfile(path))
    return chunk(table.unpack(argv or {}))
  end, function(problem)
    return problem
  end)

  io.stderr = saved_stderr
  io.write = saved_io_write
  os.exit = saved_os_exit

  local result_ok, result_err, meta
  if ok then
    result_ok = true
    meta = {exit_code = 0, stderr = table.concat(stderr_lines), stdout = table.concat(stdout_lines)}
  elseif is_terminated(result) then
    if result.code == 0 then
      result_ok = true
      meta = {exit_code = 0, stderr = table.concat(stderr_lines), stdout = table.concat(stdout_lines)}
    else
      result_ok = nil
      result_err = table.concat(stderr_lines) ~= "" and table.concat(stderr_lines) or tostring(result.message or "terminated")
      meta = {
        exit_code = result.code,
        stderr = table.concat(stderr_lines),
        stdout = table.concat(stdout_lines),
        terminated = true,
      }
    end
  elseif is_timeout(result) then
    result_ok = nil
    result_err = "emulator timeout: " .. tostring(result.message or "timeout")
    meta = {
      exit_code = 124,
      stderr = table.concat(stderr_lines),
      stdout = table.concat(stdout_lines),
      timeout = true,
    }
  else
    result_ok = nil
    result_err = tostring(result)
    meta = {
      exit_code = 1,
      stderr = table.concat(stderr_lines),
      stdout = table.concat(stdout_lines),
    }
  end

  if runtime and options.shell_redraw then
    runtime:shell_redraw(result_ok and nil or tostring(result_err))
  end

  return result_ok, result_err, meta
end
```

### N. Optionaler zweiter Timeout-Failsafe
Optional, aber empfohlen: in `process.lua` zusätzlich `debug.sethook` als zweite Sicherung.

Default:
- `instruction_limit = 5e6`

Verhalten:
- alle 100000 Instruktionen Hook
- bei Überschreitung:
```lua
error({
  reason = "timeout",
  code = 124,
  message = "instruction limit exceeded",
}, 0)
```

Das ist optional, weil `event_pull`-Budget schon den wahrscheinlichsten Leakpfad abdeckt. Wenn eingebaut, dann in beiden Runnern konsistent.

## Testplan
### Editor-Regressionen
In [`route_book_editor_emulator.lua`](/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/tests/previews/route_book_editor_emulator.lua) ergänzen:

- `save tab wraps long validation error`
  - langer Validierungsfehler
  - mehrere sichtbare Zeilen
  - kein abgeschnittener Einzeiler mit `>`
- `detector detail wraps long address`
- `station detail wraps long detector ids`
- `route detail wraps long waypoint text`
- `schedule entry wraps long route id`
- `wait condition wraps long condition line`
- `only active modal row shows cursor`
  - mehrere Repeatable-Zeilen
  - genau eine Zeile mit `|`
- `panel scroll targets correct panel`
  - Save-Scroll
  - Route-Detail-Scroll
  - Schedule-Wait-Scroll

### Emulator-/Leak-Regressionen
Neue Tests:
- `with_runtime closes runtime on success`
- `with_runtime closes runtime on failure`
- `screen_sync log is bounded`
- `event pull timeout aborts runaway run_program`
- `event pull timeout aborts runaway run_script`
- `run_script restores io and os.exit on failure`

### Mindestakzeptanz
Nach Implementierung müssen diese Punkte erfüllt sein:
- lange Validierungsfehler sind im Editor vollständig lesbar
- lange Detailtexte in allen Lesepanels werden nicht mehr mit `>` abgeschnitten
- nur die aktive Modalzeile zeigt einen Cursor
- der Emulator bleibt bei fehlendem Exit nicht unbegrenzt laufen
- `lua`-Prozesse aus Emulatorläufen wachsen nicht mehr ungebremst im Speicher, weil Runtime und Logpuffer freigegeben bzw. begrenzt sind

## Geprüft / wahrscheinlich korrekt / zwingend nachtesten
### Geprüft
- die genannten Ist-Stellen existieren genau so im aktuellen Code
- die vorgeschlagenen Eingriffspunkte passen zur heutigen Struktur
- die Leak-Ursachen werden an den richtigen Emulator-Dateien adressiert

### Wahrscheinlich korrekt
- die Helper-Signaturen und Aufrufstellen
- der Wrap-Ansatz für Panelinhalte
- das Cursor-Fix-Muster
- der begrenzte `screen_syncs`-Ringpuffer
- das `event_pull`-Budget als primärer Schutz gegen Endlosschleifen

### Zwingend nach der Implementierung testen
- Off-by-one bei Panelhöhe und Scrollbereichen
- Interaktion von Wrap + Box-Innenhöhe
- Modalbreite und `[x]`-Positionen
- Scrollrouting anhand von Mauspositionen
- Timeoutgrenzen des Emulators: nicht zu niedrig, nicht zu hoch
- Shell-Redraw nach Timeout/Termination

## Assumptions
- `term_ui.fit_text(...)` wird **nicht** global geändert; die Overflow-Korrektur bleibt editorseitig.
- Die Statuszeile bleibt absichtlich einzeilig.
- Vollständige Historie aller `screen_syncs` ist für Tests nicht erforderlich; ein begrenzter Verlauf reicht.
- Das Ziel ist ein robuster Emulator für die Projekt-Tests, nicht ein vollständiger OC-Profiler oder Heap-Debugger.
