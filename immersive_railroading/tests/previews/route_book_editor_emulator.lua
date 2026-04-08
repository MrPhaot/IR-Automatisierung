package.path = "./?.lua;./programs/?.lua;./programs/lib/?.lua;" .. package.path

local emulator = require("tests.emulator.preload")
local process = require("tests.emulator.process")

local function find_sync(logs, predicate)
  for _, entry in ipairs(logs or {}) do
    if predicate(entry) then
      return entry
    end
  end
  return nil
end

local function any_line_matches(lines, pattern, plain)
  for _, line in ipairs(lines or {}) do
    if type(line) == "string" and line:find(pattern, 1, plain ~= false) ~= nil then
      return true
    end
  end
  return false
end

emulator.with_runtime({
  screen = {tier = 2, owner = "alice"},
}, function(rt)
  rt:after(0.2, function()
    rt:queue_interrupted()
  end)
  local mod = process.load_module("./programs/route_book_editor.lua")
  local ok, err = process.run_program(mod, {}, {runtime = rt})
  assert(ok == true and err == nil, "route_book_editor should exit cleanly on tier 2")

  local titled_frame = find_sync(rt.logs.screen_syncs, function(entry)
    return any_line_matches(entry.lines, "IR Schedule Editor", true)
  end)
  local compact_tabs = find_sync(rt.logs.screen_syncs, function(entry)
    return any_line_matches(entry.lines, "[> Det <", true)
  end)
  assert(titled_frame ~= nil, "tier 2 run should produce a visible editor frame")
  assert(compact_tabs ~= nil, "tier 2 frame should use compact tabs")
end)

emulator.with_runtime({
  screen = {tier = 3},
  window = {x = 4, y = 2},
}, function(rt)
  rt:after(0.1, function()
    rt:resize_screen(rt.term.screen_address, 80, 25)
  end)
  rt:after(0.2, function()
    rt:queue_key_down(rt.term.keyboard_address, 0, 1)
  end)

  local mod = process.load_module("./programs/route_book_editor.lua")
  local ok, err = process.run_program(mod, {}, {runtime = rt, shell_redraw = true})
  assert(ok == true and err == nil, "route_book_editor should exit cleanly on tier 3")

  local comfort_frame = find_sync(rt.logs.screen_syncs, function(entry)
    return any_line_matches(entry.lines, "[> Detectors <]", true)
  end)
  assert(comfort_frame ~= nil, "tier 3 frame should render comfort tabs before resize")

  local resized_frame = find_sync(rt.logs.screen_syncs, function(entry)
    return any_line_matches(entry.lines, "[> Det <]", true)
  end)
  assert(resized_frame ~= nil, "screen resize should eventually render the compact layout")

  local visible = rt:visible_lines(rt.term.screen_address)
  assert(any_line_matches(visible, "/home/immersive_railroading/programs # ", true), "shell redraw should cleanly replace the client buffer after exit")
end)

emulator.with_runtime({
  screen = {tier = 2, owner = "alice"},
}, function(rt)
  local foreign_screen = rt:register_screen({owner = "alice", primary = false})
  local foreign_keyboard = rt:register_keyboard({
    screen_address = foreign_screen.address,
    owner = "alice",
    primary = false,
  })
  rt:queue_key_down(foreign_keyboard.address, 0, 1, "alice")
  rt:queue_clipboard(foreign_keyboard.address, "ignored", "alice")
  local other_screen = rt:register_screen({owner = "bob", primary = false})
  rt:queue_touch(other_screen.address, 2, 2, 0, "alice")
  rt:queue_clipboard(rt.term.keyboard_address, "ignored", "bob")
  rt:after(0.1, function()
    rt:queue_interrupted()
  end)

  local mod = process.load_module("./programs/route_book_editor.lua")
  local ok = process.run_program(mod, {}, {runtime = rt})
  assert(ok == true, "mismatched input ownership should not break the editor")
  assert(#rt.logs.signals == 3, "only wrong-owner events should be rejected before they reach the program")
end)

emulator.with_runtime({
  screen = {tier = 2},
}, function(rt)
  local gpu = rt.components.primary.gpu
  local original_set = gpu.methods.set
  gpu.methods.set = function()
    error("emulated gpu set failure")
  end
  rt:after(0.1, function()
    rt:queue_interrupted()
  end)

  local mod = process.load_module("./programs/route_book_editor.lua")
  local ok, err = process.run_program(mod, {}, {runtime = rt})
  gpu.methods.set = original_set

  assert(ok == nil, "gpu failures should surface as deterministic errors")
  assert(tostring(err):find("unknown error", 1, true) == nil, "emulator path should never degrade into 'unknown error'")
  assert(tostring(err):find("cleanup: nil", 1, true) == nil, "emulator path should never append 'cleanup: nil'")
end)

emulator.with_runtime({
  screen = {tier = 2},
}, function(rt)
  rt:after(0.1, function()
    rt:queue_interrupted()
  end)
  local ok, err, meta = process.run_script("./programs/route_book_editor.lua", {}, {runtime = rt})
  assert(ok == true and err == nil, "top-level script should succeed on a normal interrupted exit")
  assert(meta.exit_code == 0, "normal top-level exit should not trigger os.exit(1)")
  assert(meta.stderr == "", "normal top-level exit should not write stderr")
end)

emulator.with_runtime({
  screen = {tier = 2},
  failures = {
    gpu_set_error = {message = "primary render failed"},
    gpu_fill_error = {message = "cleanup render failed"},
  },
}, function(rt)
  local ok, err, meta = process.run_script("./programs/route_book_editor.lua", {}, {runtime = rt, shell_redraw = true})
  assert(ok == nil, "top-level script should surface failing render/cleanup paths")
  assert(meta.exit_code == 1 and meta.terminated == true, "top-level error path should terminate with os.exit(1)")
  assert(meta.stderr:find("primary render failed", 1, true) ~= nil, "stderr should keep the primary failure")
  assert(meta.stderr:find("cleanup render failed", 1, true) ~= nil, "stderr should keep the cleanup failure")
  assert(meta.stderr:find("unknown error", 1, true) == nil, "combined failure path should stay specific")
  assert(meta.stderr:find("cleanup: unknown error", 1, true) == nil, "combined failure path should not regress to the old crash text")
end)

emulator.with_runtime({
  screen = {tier = 2},
  failures = {
    event_pull_terminated = {message = "signal terminated", code = 130},
  },
}, function(rt)
  local ok, err, meta = process.run_script("./programs/route_book_editor.lua", {}, {runtime = rt})
  assert(ok == true and err == nil, "event-pull termination should be treated as a controlled exit")
  assert(meta.stderr == "", "controlled termination should not emit stderr")
end)

emulator.with_runtime({
  screen = {tier = 2},
}, function(rt)
  package.loaded["lib.term_ui"] = {
    API_VERSION = nil,
    flush = function()
      return false, nil
    end,
  }

  local ok, err, meta = process.run_script("./programs/route_book_editor.lua", {"diagnose-ui"}, {runtime = rt})
  assert(ok == true and err == nil, "diagnose-ui should succeed even with a poisoned term_ui cache entry")
  assert(meta.stdout:find("api=v2", 1, true) ~= nil, "diagnostics should still report the fresh term_ui api version")
  assert(meta.stdout:find("api=v?", 1, true) == nil, "stale term_ui should not leak into diagnose-ui")

  rt:after(0.1, function()
    rt:queue_interrupted()
  end)
  local run_ok, run_err, run_meta = process.run_script("./programs/route_book_editor.lua", {}, {runtime = rt, shell_redraw = true})
  assert(run_ok == true and run_err == nil, "normal run should also recover from poisoned term_ui cache entries")
  assert(run_meta.stderr:find("unknown error %(cleanup: unknown error%)") == nil, "stale term_ui should not resurrect the old cleanup crash")
end)

emulator.with_runtime({
  screen = {tier = 2},
}, function(rt)
  package.loaded["lib.oc_proxy"] = {
    read = function()
      return nil
    end,
    address_of = function()
      return nil
    end,
    can_invoke = function()
      return false
    end,
    invoke = function()
      return false, "poisoned oc_proxy"
    end,
  }

  local ok, err, meta = process.run_script("./programs/route_book_editor.lua", {"diagnose-ui"}, {runtime = rt})
  assert(ok == true and err == nil, "diagnose-ui should fresh-load oc_proxy as well")
  assert(meta.stdout:find("api=v2", 1, true) ~= nil, "fresh-loaded stack should remain intact under oc_proxy poisoning")
end)

print("route_book_editor_emulator ok")
