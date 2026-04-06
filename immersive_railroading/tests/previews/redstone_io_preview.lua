local io_lib = assert(loadfile("./programs/lib/redstone_io.lua"))()

local calls = {}
local proxy = {
  setOutput = function(side, strength)
    calls[#calls + 1] = {side = side, strength = strength}
  end,
}

local now = 0
local controller = io_lib.make_controller(proxy, function() end, function() return now end)
local outputs = {
  loader = {side = "north", strength = 15, active_high = true},
  departure = {side = "south", strength = 12, active_high = false, pulse_ticks = 4},
}

controller:update(outputs, {loader = true})
local saw_loader = false
for _, call in ipairs(calls) do
  if call.side == "north" and call.strength == 15 then
    saw_loader = true
  end
end
assert(saw_loader == true, "while_pending output should go active")

controller:pulse("departure", outputs.departure)
assert(calls[#calls].side == "south" and calls[#calls].strength == 0, "active-low pulse should drive zero while active")

now = 1
controller:tick(outputs)
assert(calls[#calls].side == "south" and calls[#calls].strength == 12, "pulse should return to inactive level after deadline")

print("redstone_io_preview ok")
