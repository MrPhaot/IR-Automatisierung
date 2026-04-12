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
  screen = {tier = 2, owner = "alice"},
  redstone = {},
}, function(rt)
  local mod = process.load_module("./programs/route_book_editor.lua")
  local state = mod.new_state()
  state.active_tab = 2
  state.book.STATIONS.mine = {
    display_name = "Mine",
    x = 1, y = 64, z = 1,
    detector_ids = {},
    redstone_outputs = {
      loader = {address = "redstone-a", side = "north", strength = 15, pulse_ticks = 20, active_high = true},
    },
  }
  state.selections.stations = 1
  state.panel_scrolls.station_detail = 4
  local screen = mod.build_screen(state, 100, 30)
  local text = table.concat(require("lib.term_ui").render_lines(100, 30, screen.buffer), "\n")
  assert(text:find("Redstone outputs:", 1, true) ~= nil, "station detail should show redstone outputs")
  assert(text:find("loader @ redstone-a -> north strength=15", 1, true) ~= nil, "station detail should show configured redstone output details")
  assert(text:find("pulse_ticks=20 active_high=true", 1, true) ~= nil, "station detail should show wrapped redstone output attributes")
end)

emulator.with_runtime({
  screen = {tier = 2, owner = "alice"},
  redstone = {},
}, function(rt)
  local mod = process.load_module("./programs/route_book_editor.lua")
  local state = mod.new_state()
  state.active_tab = 4
  state.book.SCHEDULES.loop = {
    cyclic = false,
    entries = {
      {
        route = "ore",
        wait = {
          groups = {
            {
              {
                type = "time_passed",
                seconds = 0,
                redstone = {output = "loader", mode = "while_pending"},
              },
              {
                type = "inactivity",
                seconds = 10,
              },
            },
            {
              {
                type = "cargo_percent",
                comparator = ">=",
                value = 90,
                scope = "station_any_detector",
              },
            },
          },
        },
      },
    },
  }
  state.selections.schedules = 1
  state.panel_scrolls.schedule_wait = 2
  local screen = mod.build_screen(state, 100, 30)
  local text = table.concat(require("lib.term_ui").render_lines(100, 30, screen.buffer), "\n")
  assert(text:find("Group A", 1, true) ~= nil and text:find("Group B", 1, true) ~= nil, "wait summary should render every wait group")
  assert(text:find("%[1%] time_passed 0s") ~= nil, "wait summary should render the first condition in a group")
  assert(text:find("%[2%] inactivity 10s") ~= nil, "wait summary should render additional AND conditions in the same group")
  assert(text:find("cargo_percent >= 90", 1, true) ~= nil, "wait summary should render comparator-based conditions")
  assert(text:find("station_any_detector", 1, true) ~= nil, "wait summary should render wrapped comparator scopes")
  assert(text:find("redstone io=loader", 1, true) ~= nil, "schedule wait panel should show redstone i/o id summaries")
  assert(text:find("mode=while_pending", 1, true) ~= nil, "schedule wait panel should show redstone mode summaries")
end)

emulator.with_runtime({
  screen = {tier = 2, owner = "alice"},
  redstone = false,
}, function(rt)
  local mod = process.load_module("./programs/route_book_editor.lua")
  local state = mod.new_state()
  state.active_tab = 5
  state.book.STATIONS.mine = {
    display_name = "Mine",
    x = 1, y = 64, z = 1,
    detector_ids = {},
    redstone_outputs = {
      loader = {address = "redstone-a", side = "north", strength = 15, pulse_ticks = 20, active_high = true},
    },
  }
  local screen = mod.build_screen(state, 100, 30)
  local text = table.concat(require("lib.term_ui").render_lines(100, 30, screen.buffer), "\n")
  assert(text:find("Redstone runtime: required", 1, true) ~= nil, "save tab should show required redstone runtime state")
  assert(text:find("Primary component.redstone: missing", 1, true) ~= nil, "save tab should show missing redstone primary state")
  assert(text:find("Schedule redstone binds by I/O ID to the destination station.", 1, true) ~= nil, "save tab should explain redstone binding by i/o id")
  assert(text:find("Station I/O address selects which redstone module is used.", 1, true) ~= nil, "save tab should explain station io addresses")
  assert(text:find("Conditions in a group are AND.", 1, true) ~= nil, "save tab should explain group semantics")
  assert(text:find("Groups are OR.", 1, true) ~= nil, "save tab should explain group semantics")
  assert(text:find("Click [+] to add a condition, then choose AND or OR before the next one.", 1, true) ~= nil, "save tab should describe the chain builder flow")
  assert(text:find("Comparator%-based conditions open a comparator chooser before returning.") ~= nil, "save tab should describe comparator chooser behavior")
  assert(text:find("Redstone is attached per condition via the Redstone field.", 1, true) ~= nil, "save tab should describe per-condition redstone")
  assert(text:find("read%-only") == nil, "save tab should no longer claim outputs are read-only")
end)

do
  local mod = assert(loadfile("./programs/route_book_editor.lua"))("__module__")
  local rows = mod.redstone_output_rows_from_station({
    redstone_outputs = {
      loader = {address = "redstone-a", side = "north", strength = 15, pulse_ticks = 20, active_high = true},
      depart = {address = "redstone-b", side = "south", strength = 9, pulse_ticks = 5, active_high = false},
    },
  })
  assert(#rows == 2, "station redstone outputs should expand to modal rows")
  local outputs = mod.collect_redstone_outputs({
    redstone_outputs = rows,
  })
  assert(outputs.loader.address == "redstone-a" and outputs.loader.side == "north" and outputs.depart.address == "redstone-b" and outputs.depart.active_high == false, "redstone outputs should round-trip through editor helpers")
  local ok, err = mod.validate_redstone_output_rows({
    {id = "loader"},
    {id = "loader"},
  })
  assert(ok == false and tostring(err):find("duplicated", 1, true) ~= nil, "duplicate redstone output names should be rejected")
end

do
  local mod = assert(loadfile("./programs/route_book_editor.lua"))("__module__")
  local state = mod.new_state()
  state.active_tab = 4
  state.book.SCHEDULES.loop = {
    cyclic = false,
    entries = {
      {
        route = "ore",
        wait = {
          groups = {
            {
              {
                type = "time_passed",
                seconds = 0,
                redstone = {output = "loader", mode = "while_pending"},
              },
            },
          },
        },
      },
    },
  }
  local first_condition = state.book.SCHEDULES.loop.entries[1].wait.groups[1][1]
  assert(first_condition.redstone.output == "loader", "schedule redstone binding should remain representable in the simplified editor path")
end

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

do
  local captured
  emulator.with_runtime({
    screen = {tier = 2},
  }, function(rt)
    captured = rt
  end)
  assert(captured and captured.closed == true, "with_runtime should close runtimes after successful runs")
end

do
  local captured
  local ok, err = pcall(function()
    emulator.with_runtime({
      screen = {tier = 2},
    }, function(rt)
      captured = rt
      error("forced preview failure")
    end)
  end)
  assert(ok == false and tostring(err):find("forced preview failure", 1, true) ~= nil, "with_runtime should rethrow test failures")
  assert(captured and captured.closed == true, "with_runtime should close runtimes after failing runs")
end

emulator.with_runtime({
  screen = {tier = 2},
  limits = {
    max_screen_syncs = 8,
  },
}, function(rt)
  for _ = 1, 20 do
    rt:write_screen(rt.term.screen_address, 1, 1, "frame")
  end
  assert(#rt.logs.screen_syncs == 8, "screen sync history should be bounded")
end)

emulator.with_runtime({
  screen = {tier = 2},
  limits = {
    max_event_pulls = 5,
  },
}, function(rt)
  local mod = process.load_module("./programs/route_book_editor.lua")
  local ok, err = process.run_program(mod, {}, {runtime = rt})
  assert(ok == nil, "run_program should stop on event-pull timeouts")
  assert(tostring(err):find("event pull limit exceeded", 1, true) ~= nil, "run_program should surface the event-pull timeout")
end)

emulator.with_runtime({
  screen = {tier = 2},
  limits = {
    max_event_pulls = 5,
  },
}, function(rt)
  local ok, err, meta = process.run_script("./programs/route_book_editor.lua", {}, {runtime = rt, shell_redraw = true})
  assert(ok == nil and meta.terminated == true and meta.exit_code == 1, "run_script should stop on event-pull timeouts")
  assert(tostring(err):find("event pull limit exceeded", 1, true) ~= nil, "run_script should surface the event-pull timeout")
end)

do
  local before_write = io.write
  local before_exit = os.exit
  emulator.with_runtime({
    screen = {tier = 2},
    failures = {
      gpu_set_error = {message = "primary render failed"},
    },
  }, function(rt)
    local ok, err = process.run_script("./programs/route_book_editor.lua", {}, {runtime = rt})
    assert(ok == nil, "run_script failure fixture should still fail")
  end)
  assert(io.write == before_write, "run_script should restore io.write after failures")
  assert(os.exit == before_exit, "run_script should restore os.exit after failures")
end

print("route_book_editor_emulator ok")
