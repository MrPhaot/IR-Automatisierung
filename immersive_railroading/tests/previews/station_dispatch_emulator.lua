package.path = "./?.lua;./programs/?.lua;./programs/lib/?.lua;" .. package.path

local emulator = require("tests.emulator.preload")
local process = require("tests.emulator.process")

emulator.with_runtime({
  redstone = {},
  ir_remote_control = {},
}, function(rt)
  local detector = rt:register_component_kind("detector", {
    methods = {
      info = function()
        return {cargo_percent = 75}
      end,
    },
  })

  local mod = process.load_module("./programs/station_dispatch.lua")
  assert(type(mod.run) == "function" and type(mod.validate_route_book) == "function", "station_dispatch should load inside the emulator")

  local component = require("component")
  local detector_proxy = component.proxy(detector.address)
  local info = detector_proxy.info()
  assert(info.cargo_percent == 75, "generic detector proxies should work through the shared emulator")

  component.redstone.setOutput("north", 11)
  assert(component.redstone.getOutput("north") == 11, "redstone outputs should be observable")
  assert(#rt.logs.redstone >= 1, "redstone writes should be logged for dispatcher-style tests")

  local computer = require("computer")
  local event = require("event")
  local before = computer.uptime()
  event.pull(0.5)
  assert(computer.uptime() >= before + 0.5, "event/computer time should advance reproducibly in the emulator")
end)

emulator.with_runtime({
  redstone = false,
}, function(rt)
  local mod = process.load_module("./programs/station_dispatch.lua")
  local resolver = mod._make_redstone_proxy_resolver({
    STATIONS = {
      mine = {
        redstone_outputs = {
          loader = {address = "redstone-missing", side = "north", strength = 15},
        },
      },
    },
  })
  local redstone_proxy, redstone_error = resolver({address = "redstone-missing", side = "north", strength = 15})
  assert(redstone_proxy == nil, "dispatcher should not invent a missing redstone primary")
  assert(tostring(redstone_error):find("redstone component address redstone%-missing is unavailable") ~= nil, "missing redstone addresses should return a friendly dispatcher error")
end)

emulator.with_runtime({
  redstone = {},
  ir_remote_control = false,
}, function(rt)
  local mod = process.load_module("./programs/station_dispatch.lua")
  local remote, remote_error = mod._get_remote()
  assert(remote == nil, "dispatcher should not invent a missing ir_remote_control primary")
  assert(remote_error == "component.ir_remote_control is not available", "missing ir_remote_control should return a friendly dispatcher error")
end)

print("station_dispatch_emulator ok")
