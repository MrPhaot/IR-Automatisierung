package.path = "./?.lua;./programs/?.lua;./programs/lib/?.lua;" .. package.path

local emulator = require("tests.emulator.preload")
local process = require("tests.emulator.process")

emulator.with_runtime({
  ir_remote_control = {
    info = {weight = 425000},
    consist = {locomotives = 1},
    pos = {x = 0, y = 64, z = 0},
  },
}, function(rt)
  local mod = process.load_module("./programs/train_controller.lua")
  assert(type(mod.load_route_book) == "function" and type(mod.execute_route_plan) == "function", "train_controller should load inside the emulator")

  local component = require("component")
  local remote = component.ir_remote_control
  remote.setThrottle(0.4)
  remote.setReverser(1)
  remote.setBrake(0.2)
  remote.setIndependentBrake(0.8)
  remote.setIgnition(true)

  local info = remote.info()
  local consist = remote.consist()
  local x, y, z = remote.getPos()
  assert(info.weight == 425000, "remote.info should be readable")
  assert(consist.locomotives == 1, "remote.consist should be readable")
  assert(x == 0 and y == 64 and z == 0, "remote.getPos should be readable")
  assert(#rt.logs.remote >= 5, "control writes should be logged in order")

  local filesystem = require("filesystem")
  assert(filesystem.exists("/home") == true, "filesystem should expose the seeded root structure")
  filesystem.makeDirectory("/tmp/controller")
  assert(filesystem.isDirectory("/tmp/controller") == true, "filesystem.makeDirectory should work in the emulator")

  local book, err = mod.load_route_book()
  assert(type(book) == "table" and err == nil, "train_controller should still load the route book under emulator-backed globals")
end)

print("train_controller_emulator ok")
