package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local function blank_lines(width, height)
  local lines = {}
  for y = 1, height do
    lines[y] = string.rep(" ", width)
  end
  return lines
end

local function write_line(lines, x, y, text)
  if not lines[y] then
    return
  end
  local width = #lines[y]
  if x < 1 or x > width then
    return
  end
  if x + #text - 1 > width then
    text = text:sub(1, width - x + 1)
  end
  lines[y] = lines[y]:sub(1, x - 1) .. text .. lines[y]:sub(x + #text)
end

local function make_runtime(width, height, events, options)
  options = options or {}
  local framebuffer = blank_lines(width, height)
  local queue = {}
  for index, item in ipairs(events or {}) do
    queue[index] = item
  end

  local gpu = {
    _screen = options.screen_address or "screen-1",
    getResolution = function()
      return options.physical_width or width, options.physical_height or height
    end,
    getScreen = function()
      return gpu._screen
    end,
    bind = function(screen_address)
      gpu._screen = screen_address
      return true
    end,
    fill = function(x, y, fill_width, fill_height, char)
      if options.fail_fill then
        error(options.fail_fill)
      end
      for row = y, y + fill_height - 1 do
        if framebuffer[row] then
          write_line(framebuffer, x, row, string.rep(char or " ", fill_width))
        end
      end
      return true
    end,
    set = function(x, y, text)
      if options.fail_set then
        error(options.fail_set)
      end
      write_line(framebuffer, x, y, text)
      return true
    end,
  }

  local cursor = {x = nil, y = nil}
  local clear_calls = 0
  local term_api = {
    getGlobalArea = function()
      return 1, 1, width, height
    end,
    setCursor = function(x, y)
      cursor.x = x
      cursor.y = y
    end,
    clear = function()
      clear_calls = clear_calls + 1
      framebuffer = blank_lines(width, height)
    end,
  }

  local tty_api = {
    isAvailable = function()
      return true
    end,
    gpu = function()
      return gpu
    end,
    bind = function()
      return true
    end,
    getViewport = function()
      return width, height, 0, 0, 1, 1
    end,
  }

  local event_api = {
    pull = function()
      local item = table.remove(queue, 1)
      if not item then
        return nil
      end
      return table.unpack(item)
    end,
  }

  local component_api = {
    invoke = function(address, method, ...)
      if address ~= "gpu-1" then
        error("unknown address")
      end
      if method == "fill" then
        return gpu.fill(...)
      end
      if method == "set" then
        return gpu.set(...)
      end
      if method == "getResolution" then
        return gpu.getResolution(...)
      end
      if method == "getScreen" then
        return gpu.getScreen(...)
      end
      if method == "bind" then
        return gpu.bind(...)
      end
      error("unknown method")
    end,
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    getPrimary = function(kind)
      if kind == "gpu" then
        return {address = "gpu-1"}
      end
      if kind == "screen" then
        return {address = "screen-1"}
      end
      return nil
    end,
  }

  return {
    component = component_api,
    term = term_api,
    tty = tty_api,
    event = event_api,
    keyboard = {
      isControlDown = function()
        return false
      end,
    },
    unicode = {
      char = function(code)
        return string.char(code)
      end,
    },
    framebuffer = function()
      return framebuffer
    end,
    cursor = cursor,
    clear_calls = function()
      return clear_calls
    end,
  }
end

local function load_editor_with_runtime(runtime)
  local original_require = require
  local original_term_ui = package.loaded["lib.term_ui"]
  local original_oc_proxy = package.loaded["lib.oc_proxy"]
  package.loaded["lib.term_ui"] = nil
  package.loaded["lib.oc_proxy"] = nil

  _G.require = function(name)
    if name == "component" then
      return runtime.component
    end
    if name == "term" then
      return runtime.term
    end
    if name == "tty" then
      return runtime.tty
    end
    if name == "event" then
      return runtime.event
    end
    if name == "keyboard" then
      return runtime.keyboard
    end
    if name == "unicode" then
      return runtime.unicode
    end
    return original_require(name)
  end

  local ok, editor_or_err = pcall(function()
    return assert(loadfile("./programs/route_book_editor.lua"))("__module__")
  end)

  _G.require = original_require
  package.loaded["lib.term_ui"] = original_term_ui
  package.loaded["lib.oc_proxy"] = original_oc_proxy
  assert(ok, editor_or_err)
  return editor_or_err
end

do
  local runtime = make_runtime(80, 25, {
    {"key_down", "screen-1", 0, 1},
  })
  local editor = load_editor_with_runtime(runtime)
  local state = editor.new_state()
  local context = assert(editor.resolve_terminal_context(runtime.term, runtime.tty, runtime.component))
  local exit_result = editor.run_loop(state, context, "run")
  local before_cleanup = runtime.framebuffer()

  assert(exit_result.kind == "ok", "Esc should produce a controlled ok exit")
  assert(editor.build_screen(state, 80, 25).layout.tier == "compact", "80x25 should resolve to compact layout")
  assert(before_cleanup[1]:find("IR Schedule Editor", 1, true) ~= nil, "80x25 frame should contain the title before cleanup")
  assert(before_cleanup[2]:find("Det", 1, true) ~= nil, "80x25 frame should contain compact tabs before cleanup")
  assert(table.concat(before_cleanup, "\n"):find("%[ Add %]", 1) ~= nil, "80x25 frame should place buttons before cleanup")

  local ok = editor.finalize_exit(context, exit_result)
  local after_cleanup = runtime.framebuffer()
  assert(ok == true, "cleanup after Esc should succeed")
  assert(after_cleanup[1] == string.rep(" ", 80), "cleanup should blank the first line")
  assert(runtime.cursor.x == 1 and runtime.cursor.y == 1, "cleanup should restore the cursor")
  assert(runtime.clear_calls() >= 1, "cleanup may use term.clear as a final sweep")
end

do
  local runtime = make_runtime(160, 50, {
    {"interrupted"},
  })
  local editor = load_editor_with_runtime(runtime)
  local state = editor.new_state()
  local context = assert(editor.resolve_terminal_context(runtime.term, runtime.tty, runtime.component))
  local exit_result = editor.run_loop(state, context, "run")
  local before_cleanup = runtime.framebuffer()

  assert(exit_result.kind == "interrupted", "interrupted should stay a controlled exit")
  assert(editor.build_screen(state, 160, 50).layout.tier == "comfort", "160x50 should resolve to comfort layout")
  assert(before_cleanup[1]:find("IR Schedule Editor", 1, true) ~= nil, "160x50 frame should contain the title before cleanup")
  assert(before_cleanup[2]:find("Detectors", 1, true) ~= nil, "160x50 frame should contain comfort tabs before cleanup")
  assert(table.concat(before_cleanup, "\n"):find("Known Detectors", 1, true) ~= nil, "160x50 frame should render the left panel before cleanup")

  local ok = editor.finalize_exit(context, exit_result)
  assert(ok == true, "cleanup after interrupted should succeed")
  assert(runtime.framebuffer()[1] == string.rep(" ", 160), "cleanup should blank the wide screen as well")
end

do
  local runtime = make_runtime(80, 25, {
    {"key_down", "screen-1", 0, 1},
  }, {
    fail_set = "simulated set failure",
  })
  local editor = load_editor_with_runtime(runtime)
  local state = editor.new_state()
  local context = assert(editor.resolve_terminal_context(runtime.term, runtime.tty, runtime.component))
  local exit_result = editor.run_loop(state, context, "run")
  local ok, err = editor.finalize_exit(context, exit_result)

  assert(exit_result.kind == "error", "render failures should become structured error exits")
  assert(exit_result.message:find("simulated set failure", 1, true) ~= nil, "run_loop should preserve the render failure message")
  assert(ok == nil, "finalize_exit should report render failures as errors")
  assert(err:find("unknown error", 1, true) == nil, "error path should never collapse into 'unknown error'")
  assert(err:find("cleanup: nil", 1, true) == nil, "error path should never append 'cleanup: nil'")
end

print("route_book_editor_oc_harness ok")
