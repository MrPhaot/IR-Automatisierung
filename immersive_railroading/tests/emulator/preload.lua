local runtime = require("tests.emulator.runtime")

local M = {}

local MODULES = {"component", "event", "term", "tty", "keyboard", "unicode", "computer", "filesystem", "shell"}
local PROJECT_MODULES = {"lib.term_ui", "lib.oc_proxy"}

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

return M
