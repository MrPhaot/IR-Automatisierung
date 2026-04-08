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

print("station_dispatch_emulator ok")
