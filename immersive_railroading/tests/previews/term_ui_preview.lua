package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local ui = assert(loadfile("./programs/lib/term_ui.lua"))()
local required_ui = require("lib.term_ui")
local editor = assert(loadfile("./programs/route_book_editor.lua"))("__module__")

local state = editor.new_state()
local screen = editor.build_screen(state, 100, 30)
local medium_screen = editor.build_screen(state, 70, 20)
local tier2_screen = editor.build_screen(state, 80, 25)
local compact_screen = editor.build_screen(state, 54, 18)
local minimum_screen = editor.build_screen(state, 50, 16)
local large_screen = editor.build_screen(state, 160, 50)
local comfort_lines = ui.render_lines(100, 30, screen.buffer)
local medium_lines = ui.render_lines(70, 20, medium_screen.buffer)
local tier2_lines = ui.render_lines(80, 25, tier2_screen.buffer)
local compact_lines = ui.render_lines(54, 18, compact_screen.buffer)

assert(type(screen.buffer) == "table" and #screen.buffer > 0, "editor should render a screen buffer")
assert(type(screen.targets) == "table" and #screen.targets > 0, "editor should expose clickable targets")
assert(ui.API_VERSION == 2, "term_ui should expose api version 2")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, 3, 2) == true, "hit testing should work")
assert(ui.hit(nil, 3, 2) == false, "hit should ignore nil rects")
assert(ui.hit({x = 1, y = 1, width = nil, height = 2}, 3, 2) == false, "hit should ignore nil width")
assert(ui.hit({x = 1, y = 1, width = 5, height = nil}, 3, 2) == false, "hit should ignore nil height")
assert(ui.hit({x = 1, y = 1, width = 0, height = 2}, 3, 2) == false, "hit should reject zero width")
assert(ui.hit({x = 1, y = 1, width = 5, height = 0}, 3, 2) == false, "hit should reject zero height")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, nil, 2) == false, "hit should reject nil px")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, 3, nil) == false, "hit should reject nil py")
assert(ui.fit_text("abcdef", 4) == "abc>", "fit_text should mark truncation")
assert(editor.parse_cli_mode({}) == "run", "empty argv should keep normal run mode")
assert(editor.parse_cli_mode({"diagnose-ui"}) == "diagnose-ui", "plain diagnose-ui should enable diagnostics")
assert(editor.parse_cli_mode({"--diagnose-ui"}) == "diagnose-ui", "direct flag should enable diagnostics when delivered to the chunk")
assert(editor.parse_cli_mode({"--", "--diagnose-ui"}) == "diagnose-ui", "double-dash form should enable diagnostics")
assert(compact_screen.layout.tier == "compact", "54x18 should use compact layout")
assert(minimum_screen.layout.tier == "minimum", "50x16 should use minimum-size fallback")
assert(screen.layout.tier == "comfort", "100x30 should use comfort layout")
assert(large_screen.layout.tier == "comfort", "160x50 should use comfort layout")
assert(medium_screen.layout.tier == "compact", "70x20 should use compact layout")
assert(tier2_screen.layout.tier == "compact", "80x25 should use compact layout")

assert(comfort_lines[1]:find("IR Schedule Editor", 1, true) ~= nil, "comfort frame should contain title")
assert(comfort_lines[2]:find("Detectors", 1, true) ~= nil, "comfort frame should show tabs")
assert(table.concat(comfort_lines, "\n"):find("Known Detectors", 1, true) ~= nil, "comfort frame should show detector panel")
assert(table.concat(comfort_lines, "\n"):find("%[ Add %]", 1) ~= nil, "comfort frame should show action buttons")

assert(table.concat(medium_lines, "\n"):find("Schedules", 1, true) ~= nil or table.concat(medium_lines, "\n"):find("Detectors", 1, true) ~= nil, "70x20 should show compact panels")
assert(table.concat(tier2_lines, "\n"):find("Det", 1, true) ~= nil, "80x25 should keep compact tabs")
assert(table.concat(compact_lines, "\n"):find("Det", 1, true) ~= nil, "54x18 should show compact tabs")
assert(table.concat(compact_lines, "\n"):find("%[ Add %]", 1) ~= nil, "54x18 should show compact buttons")
local compact_has_status = false
for _, line in ipairs(compact_lines) do
  if line:find("UI tier=", 1, true) ~= nil or line:find("Ready", 1, true) ~= nil then
    compact_has_status = true
    break
  end
end
assert(compact_has_status == true, "status line should remain visible")
assert(table.concat(comfort_lines, "\n"):find("renderer=", 1, true) == nil, "normal editor status should not contain diagnostics")

local saw_tab = false
local saw_button = false
for _, target in ipairs(screen.targets) do
  if target.tab_index == 1 then
    saw_tab = true
  end
  if target.id == "add" then
    saw_button = true
  end
end

assert(saw_tab == true, "editor should render tab targets")
assert(saw_button == true, "editor should render action buttons")

for _, variant in ipairs({screen, medium_screen, compact_screen}) do
  for _, target in ipairs(variant.targets) do
    assert(type(target.x) == "number" and target.x >= 1, "all targets should have numeric x")
    assert(type(target.y) == "number" and target.y >= 1, "all targets should have numeric y")
    assert(type(target.width) == "number" and target.width > 0, "all targets should have positive width")
    assert(type(target.height) == "number" and target.height > 0, "all targets should have positive height")
  end
end

local gpu_writes = {}
local fake_gpu = {
  fill = function() end,
  set = function(x, y, line)
    gpu_writes[#gpu_writes + 1] = {x = x, y = y, line = line}
  end,
}
ui._frame_cache = nil
local flush_ok = ui.flush(nil, fake_gpu, 10, 3, {
  {x = 1, y = 1, text = "header"},
  {x = 1, y = 2, text = "body"},
}, 4, 2)
assert(flush_ok == true, "flush should succeed with a bound gpu")
assert(#gpu_writes >= 2, "flush should write frame lines through gpu.set when available")
assert(gpu_writes[1].x == 4 and gpu_writes[1].y == 2, "flush should honor the terminal origin")

local term_writes = {}
local fake_term = {
  clear = function() end,
  setCursor = function(x, y)
    term_writes[#term_writes + 1] = {kind = "cursor", x = x, y = y}
  end,
  write = function(line)
    term_writes[#term_writes + 1] = {kind = "write", line = line}
  end,
}
ui._frame_cache = nil
local fallback_ok, fallback_err = ui.flush(fake_term, nil, 10, 3, {
  {x = 1, y = 1, text = "header"},
  {x = 1, y = 2, text = "body"},
}, 4, 2)
assert(fallback_ok == nil, "flush should reject framebuffer rendering without a gpu")
assert(tostring(fallback_err):find("gpu", 1, true) ~= nil, "flush should explain the missing gpu")
assert(#term_writes == 0, "flush should not use term.write for fullscreen ui frames")
local truth_lines = ui.render_lines(10, 3, {
  {x = 1, y = 1, text = "header"},
  {x = 1, y = 2, text = "body"},
})
assert(gpu_writes[1].line == truth_lines[1], "gpu flush should use render_lines frame content")
assert(gpu_writes[2].line == truth_lines[2], "gpu flush should keep render_lines line order")
required_ui._frame_cache = {width = 1, height = 1, origin_x = 1, origin_y = 1, lines = {"x"}}
required_ui.reset_cache()
assert(required_ui._frame_cache == nil, "reset_cache should clear the frame cache")

local bound_gpu = {
  set = function() end,
  fill = function() end,
  getResolution = function()
    return 160, 50
  end,
}
local terminal_context = editor.resolve_terminal_context({
  gpu = function()
    return bound_gpu
  end,
  getGlobalArea = function()
    return 4, 2, 54, 18
  end,
}, {
  gpu = function()
    return bound_gpu
  end,
  getViewport = function()
    return 54, 18, 0, 0, 1, 1
  end,
})
assert(terminal_context.renderer == "term-gpu", "editor should prefer the bound terminal gpu")
assert(terminal_context.viewport_width == 54 and terminal_context.viewport_height == 18, "editor should size layouts from the visible viewport")
assert(terminal_context.origin_x == 4 and terminal_context.origin_y == 2, "editor should preserve the terminal origin")
assert(terminal_context.physical_width == 160 and terminal_context.physical_height == 50, "editor should preserve physical gpu size as diagnostic info")
assert(editor.build_screen(state, terminal_context.viewport_width, terminal_context.viewport_height).layout.tier == "compact", "viewport size should control layout tier")
local terminal_diag = editor.diagnostic_summary(terminal_context)
assert(terminal_diag:find("renderer=term%-gpu") ~= nil, "diagnostics should report the terminal renderer")
assert(terminal_diag:find("viewport=54x18", 1, true) ~= nil, "diagnostics should report the viewport size")
assert(terminal_diag:find("origin=4,2", 1, true) ~= nil, "diagnostics should report the terminal origin")
assert(terminal_diag:find("raw_viewport=54,18,0,0,1,1", 1, true) ~= nil, "diagnostics should report the raw viewport tuple")
assert(terminal_diag:find("gpu=160x50", 1, true) ~= nil, "diagnostics should report the physical gpu size")
assert(terminal_diag:find("out of date", 1, true) == nil, "diagnostics should not claim term_ui is out of date")
assert(terminal_diag:find("tty_module=yes", 1, true) ~= nil, "diagnostics should report tty module presence")
assert(terminal_diag:find("tty_gpu=yes", 1, true) ~= nil, "diagnostics should report tty gpu presence")

do
  local startup_state = editor.new_state()
  local original_message = startup_state.message
  editor.apply_startup_status(startup_state, terminal_context, nil, {}, "run")
  assert(startup_state.message == original_message, "normal startup should keep the editor status line intact")

  local diagnose_message = editor.startup_summary(terminal_context, nil, {mode_name = "diagnose-ui"})
  assert(diagnose_message:find("renderer=term%-gpu") ~= nil, "diagnose-ui should still expose full diagnostics")
end

local termless_context = editor.resolve_terminal_context({
  getGlobalArea = function()
    return 9, 3, 54, 18
  end,
}, {
  gpu = function()
    return bound_gpu
  end,
  getViewport = function()
    return 54, 18, 0, 0, 1, 1
  end,
})
assert(termless_context ~= nil, "editor should succeed when tty.gpu is valid even if term.gpu is missing")
assert(termless_context.viewport_width == 54 and termless_context.viewport_height == 18, "6-value viewport results should still parse width and height")

local missing_gpu_context, missing_gpu_error, missing_gpu_diag = editor.resolve_terminal_context({
  gpu = function()
    return bound_gpu
  end,
  getGlobalArea = function()
    return 1, 1, 80, 25
  end,
}, {
  getViewport = function()
    return 80, 25, 0, 0, 1, 1
  end,
})
assert(missing_gpu_context == nil, "editor should reject a terminal without a bound gpu")
assert(missing_gpu_error == "no gpu component", "missing gpu should surface as a specific startup error")
assert(missing_gpu_diag.term_gpu == "yes", "diagnostics should keep term.gpu separate from tty.gpu")
assert(missing_gpu_diag.tty_gpu == "no", "diagnostics should show the missing tty gpu")

do
  local tty_state = {gpu = nil}
  local weird_gpu = setmetatable({}, {
    __index = {
      getScreen = function()
        return "screen-2"
      end,
      bind = function()
        return true
      end,
      getResolution = function()
        return 160, 50
      end,
      set = function() end,
      fill = function() end,
    },
  })
  local proxy_context, proxy_problem, proxy_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return tty_state.gpu
    end,
    bind = function(gpu)
      tty_state.gpu = gpu
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    getPrimary = function(kind)
      if kind == "gpu" then
        return weird_gpu
      end
      if kind == "screen" then
        return {address = "screen-1"}
      end
    end,
  })
  assert(proxy_context ~= nil and proxy_problem == nil, "resolver should accept readable proxies independent of raw basetype assumptions")
  assert(proxy_diag.gpu_proxy_type ~= "nil", "diagnostics should report the detected gpu proxy type")
  assert(proxy_diag.gpu_has_bind == "yes" and proxy_diag.gpu_has_getScreen == "yes", "diagnostics should report readable proxy methods")
end

do
  local tty_state = {gpu = nil}
  local invoke_gpu = {address = "gpu-proxy"}
  local invoke_screen = {address = "screen-1"}
  local component_api = {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    getPrimary = function(kind)
      if kind == "gpu" then
        return invoke_gpu
      end
      if kind == "screen" then
        return invoke_screen
      end
    end,
    invoke = function(address, method, ...)
      if address == "gpu-proxy" and method == "getScreen" then
        return "screen-2"
      end
      if address == "gpu-proxy" and method == "getResolution" then
        return 160, 50
      end
      if address == "gpu-proxy" and method == "bind" then
        return true
      end
    end,
  }
  local invoke_context, invoke_problem, invoke_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return tty_state.gpu
    end,
    bind = function(gpu)
      tty_state.gpu = gpu
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, component_api)
  assert(invoke_context ~= nil and invoke_problem == nil, "resolver should accept proxies whose methods are only reachable through component.invoke")
  assert(invoke_diag.invoke_getScreen_ok == "yes", "diagnostics should report invoke-based getScreen support")
  assert(invoke_diag.invoke_set_ok == "yes", "diagnostics should report invoke-based set support")
end

local missing_tty_context, missing_tty_error, missing_tty_diag = editor.resolve_terminal_context({
  gpu = function()
    return bound_gpu
  end,
  getGlobalArea = function()
    return 1, 1, 80, 25
  end,
}, nil)
assert(missing_tty_context == nil, "editor should reject missing tty module")
assert(missing_tty_error == "tty unavailable", "editor should report missing tty separately")
assert(missing_tty_diag.tty_module == false, "diagnostics should record absent tty module")
assert(editor.diagnostic_summary(nil, missing_tty_error, missing_tty_diag):find("renderer=unavailable", 1, true) ~= nil, "diagnostic mode should still emit a summary without context")

do
  local component_gpu = {}
  component_gpu.address = "gpu-1"
  component_gpu.getScreen = function()
    return component_gpu._bound or "screen-2"
  end
  component_gpu.bind = function(screen_address)
    component_gpu._bound = screen_address
    return true
  end
  component_gpu.getResolution = function()
    return 160, 50
  end
  component_gpu.set = function() end
  component_gpu.fill = function() end

  local tty_state = {gpu = nil}
  local rebound_context, rebound_problem, rebound_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    isAvailable = function()
      return true
    end,
    gpu = function()
      return tty_state.gpu
    end,
    bind = function(gpu)
      tty_state.gpu = gpu
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    gpu = component_gpu,
    screen = {address = "screen-1"},
  })
  assert(rebound_context ~= nil and rebound_problem == nil, "resolver should recover from a missing tty bind")
  assert(component_gpu._bound == nil, "existing gpu/screen binds should not be replaced when tty.bind is enough")
  assert(rebound_diag.rebind_attempted == "yes", "diagnostics should record the rebind attempt")
  assert(rebound_diag.rebind_ok == "yes", "diagnostics should report a successful rebind")
  assert(rebound_diag.tty_gpu_before == "no", "diagnostics should record the missing tty gpu before repair")
  assert(rebound_diag.tty_gpu_after == "yes", "diagnostics should record the repaired tty gpu")
  assert(rebound_diag.gpu_current_screen == "screen-2", "diagnostics should report the pre-existing gpu screen bind")
  assert(rebound_diag.tty_bind_before_gpu_bind == "yes", "diagnostics should record the early tty bind attempt")
  assert(rebound_diag.gpu_bind_attempted == "no", "diagnostics should not bind the gpu when tty.bind already fixes the state")
  assert(editor.diagnostic_summary(rebound_context):find("rebind_attempted=yes", 1, true) ~= nil, "summary should expose rebind flags")
end

do
  local component_gpu = {}
  component_gpu.address = "gpu-1"
  component_gpu.getScreen = function()
    return component_gpu._bound
  end
  component_gpu.bind = function(screen_address)
    component_gpu._bound = screen_address
    return true
  end
  component_gpu.getResolution = function()
    return 160, 50
  end
  component_gpu.set = function() end
  component_gpu.fill = function() end

  local tty_state = {gpu = nil, attempts = 0}
  local rebound_context, rebound_problem, rebound_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return tty_state.gpu
    end,
    bind = function(gpu)
      tty_state.attempts = tty_state.attempts + 1
      if tty_state.attempts >= 2 then
        tty_state.gpu = gpu
      end
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    gpu = component_gpu,
    screen = {address = "screen-1"},
  })
  assert(rebound_context ~= nil and rebound_problem == nil, "resolver should recover after gpu.bind plus tty.bind when the gpu has no screen")
  assert(component_gpu._bound == "screen-1", "gpu.bind should run when the gpu has no screen")
  assert(rebound_diag.gpu_bind_attempted == "yes", "diagnostics should record the gpu bind attempt")
  assert(rebound_diag.gpu_bind_ok == "yes", "diagnostics should record a successful gpu bind")
  assert(rebound_diag.tty_bind_after_gpu_bind == "yes", "diagnostics should record the second tty bind attempt")
end

do
  local no_screen_context, no_screen_error, no_screen_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return nil
    end,
    bind = function()
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu"
    end,
    gpu = {
      getScreen = function()
        return nil
      end,
      bind = function()
        return true
      end,
      getResolution = function()
        return 160, 50
      end,
      set = function() end,
      fill = function() end,
    },
  })
  assert(no_screen_context == nil, "resolver should fail when no screen component exists")
  assert(no_screen_error == "no screen component", "missing screen should surface as a specific startup error")
  assert(no_screen_diag.component_screen == "no", "diagnostics should report missing screen component")
end

do
  local bad_proxy_context, bad_proxy_error, bad_proxy_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return nil
    end,
    bind = function()
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    getPrimary = function(kind)
      if kind == "gpu" then
        return {}
      end
      if kind == "screen" then
        return {address = "screen-1"}
      end
    end,
  })
  assert(bad_proxy_context == nil, "resolver should fail when the gpu proxy is unreadable")
  assert(bad_proxy_error == "gpu invoke unavailable", "unreadable gpu proxies should not be misreported as gpu bind failures")
  assert(editor.diagnostic_summary(nil, bad_proxy_error, bad_proxy_diag):find("gpu_proxy_type=table", 1, true) ~= nil, "diagnostics should expose proxy-type failures")
end

do
  local bind_fail_context, bind_fail_error = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return nil
    end,
    bind = function()
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    gpu = {
      getScreen = function()
        return nil
      end,
      bind = function()
        return false, "bind failed"
      end,
      getResolution = function()
        return 160, 50
      end,
      set = function() end,
      fill = function() end,
    },
    screen = {address = "screen-1"},
  })
  assert(bind_fail_context == nil and bind_fail_error == "gpu has no screen and gpu bind failed", "gpu bind errors should only surface when the gpu truly has no screen")
end

do
  local tty_bind_fail_context, tty_bind_fail_error = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return nil
    end,
    bind = function()
      return false, "tty bind failed"
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    gpu = {
      getScreen = function()
        return "screen-1"
      end,
      bind = function()
        return true
      end,
      getResolution = function()
        return 160, 50
      end,
      set = function() end,
      fill = function() end,
    },
    screen = {address = "screen-1"},
  })
  assert(tty_bind_fail_context == nil and tty_bind_fail_error == "tty bind failed", "tty bind errors should be surfaced explicitly")
end

do
  local original_require = require
  local original_global_term = _G.term
  local old_term_ui = {
    box = ui.box,
    button = ui.button,
    render_box = ui.render_box,
    render_tabs = ui.render_tabs,
    render_list = ui.render_list,
    render_buttons = ui.render_buttons,
    flush = ui.flush,
    fit_text = ui.fit_text,
    hit = ui.hit,
  }

  _G.require = function(name)
    if name == "lib.term_ui" then
      return old_term_ui
    end
    if name == "term" then
      return {
        gpu = function()
          return nil
        end,
        getGlobalArea = function()
          return 1, 1, 54, 18
        end,
      }
    end
    if name == "tty" then
      return {
        gpu = function()
          return bound_gpu
        end,
        getViewport = function()
          return 54, 18, 0, 0, 1, 1
        end,
      }
    end
    return original_require(name)
  end
  _G.term = {
    gpu = function()
      error("polluted global term should not be used")
    end,
  }

  local mixed_editor = assert(loadfile("./programs/route_book_editor.lua"))("__module__")
  local mixed_state = mixed_editor.new_state()
  local mixed_screen = mixed_editor.build_screen(mixed_state, 100, 30)
  assert(type(mixed_screen.targets) == "table" and #mixed_screen.targets > 0, "new editor should tolerate old term_ui without is_valid_target")
  local mixed_context, mixed_problem = mixed_editor.resolve_terminal_context(require("term"), require("tty"))
  assert(mixed_context ~= nil and mixed_problem == nil, "resolver should use required modules instead of polluted globals")

  _G.require = original_require
  _G.term = original_global_term
end

do
  local offset_writes = {}
  local offset_gpu = {
    fill = function(x, y, width, height, char)
      offset_writes[#offset_writes + 1] = {kind = "fill", x = x, y = y, width = width, height = height, char = char}
    end,
    set = function(x, y, line)
      offset_writes[#offset_writes + 1] = {kind = "set", x = x, y = y, line = line}
    end,
  }
  ui._frame_cache = nil
  local ok = ui.flush(nil, offset_gpu, 12, 2, {
    {x = 1, y = 1, text = "hello"},
    {x = 1, y = 2, text = "world"},
  }, 4, 2)
  assert(ok == true, "offset flush should succeed")
  assert(offset_writes[1].kind == "fill" and offset_writes[1].x == 4 and offset_writes[1].y == 2, "clear should respect terminal origin")
  assert(offset_writes[2].kind == "set" and offset_writes[2].x == 4 and offset_writes[2].y == 2, "first rendered line should use origin offset")
  assert(offset_writes[3].kind == "set" and offset_writes[3].x == 4 and offset_writes[3].y == 3, "second rendered line should stack under origin")
end

do
  local cleanup_calls = {}
  local cleanup_gpu = {
    fill = function(x, y, width, height, char)
      cleanup_calls[#cleanup_calls + 1] = {kind = "fill", x = x, y = y, width = width, height = height, char = char}
    end,
    set = function(x, y, line)
      cleanup_calls[#cleanup_calls + 1] = {kind = "set", x = x, y = y, line = line}
    end,
  }
  local original_require = require
  local cursor_calls = {}
  _G.require = function(name)
    if name == "term" then
      return {
        setCursor = function(x, y)
          cursor_calls[#cursor_calls + 1] = {x = x, y = y}
        end,
      }
    end
    return original_require(name)
  end
  local cleanup_editor = assert(loadfile("./programs/route_book_editor.lua"))("__module__")
  local cleanup_ui = package.loaded["lib.term_ui"]
  cleanup_ui._frame_cache = {width = 12, height = 2, origin_x = 4, origin_y = 2, lines = {"hello", "world"}}
  local ok = cleanup_editor.finalize_exit({
    gpu = cleanup_gpu,
    viewport_width = 12,
    viewport_height = 2,
    origin_x = 4,
    origin_y = 2,
  }, {kind = "interrupted"})
  _G.require = original_require
  assert(ok == true, "finalize_exit should treat interrupted exits as controlled success")
  assert(cleanup_ui._frame_cache == nil, "finalize_exit should reset the ui frame cache")
  assert(#cleanup_calls > 0, "finalize_exit should actively clear the editor viewport")
  assert(cursor_calls[1] and cursor_calls[1].x == 1 and cursor_calls[1].y == 1, "finalize_exit should restore the cursor")
end

do
  local terminated = editor.normalize_runtime_failure({reason = "terminated", code = 130})
  assert(terminated.kind == "terminated" and terminated.code == 130, "terminated tables should be normalized into controlled exits")
  local exploded = editor.normalize_runtime_failure("boom")
  assert(exploded.kind == "error" and exploded.message == "boom", "plain runtime errors should stay errors")
end

do
  local original_require = require
  local invoke_writes = {}
  _G.require = function(name)
    if name == "component" then
      return {
        invoke = function(address, method, ...)
          if address == "gpu-fallback" and method == "fill" then
            local x, y, width, height, char = ...
            invoke_writes[#invoke_writes + 1] = {kind = "fill", x = x, y = y, width = width, height = height, char = char}
            return true
          end
          if address == "gpu-fallback" and method == "set" then
            local x, y, line = ...
            invoke_writes[#invoke_writes + 1] = {kind = "set", x = x, y = y, line = line}
            return true
          end
        end,
      }
    end
    return original_require(name)
  end
  local invoke_ui = assert(loadfile("./programs/lib/term_ui.lua"))()
  invoke_ui._frame_cache = nil
  local ok = invoke_ui.flush(nil, {address = "gpu-fallback"}, 8, 2, {
    {x = 1, y = 1, text = "abc"},
    {x = 1, y = 2, text = "def"},
  }, 3, 4)
  assert(ok == true, "term_ui should support invoke-based gpu proxies")
  assert(invoke_writes[1].kind == "fill" and invoke_writes[1].x == 3 and invoke_writes[1].y == 4, "invoke fallback should clear using the translated origin")
  assert(invoke_writes[2].kind == "set" and invoke_writes[2].x == 3 and invoke_writes[2].y == 4, "invoke fallback should write the first line at the translated origin")
  _G.require = original_require
end

do
  local local_x, local_y = editor.normalize_pointer_event({
    screen_address = "screen-1",
    origin_x = 4,
    origin_y = 2,
    viewport_width = 54,
    viewport_height = 18,
  }, "screen-1", 7, 4)
  assert(local_x == 4 and local_y == 3, "pointer events should be translated into viewport-local coordinates")

  local ignored_x = editor.normalize_pointer_event({
    screen_address = "screen-1",
    origin_x = 4,
    origin_y = 2,
    viewport_width = 54,
    viewport_height = 18,
  }, "other-screen", 7, 4)
  assert(ignored_x == nil, "pointer events from other screens should be ignored")
end

print("term_ui_preview ok")
