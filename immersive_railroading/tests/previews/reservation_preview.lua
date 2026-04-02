local blocks = {
  main_01 = {owner = nil},
  main_02 = {owner = nil},
}

local switches = {J1 = "siding"}
local switch_locks = {}

local route = {
  blocks = {"main_01", "main_02"},
  switches = {J1 = "main"},
}

local function reserve(owner, route_definition)
  for _, block_id in ipairs(route_definition.blocks) do
    local block = blocks[block_id]
    if block.owner and block.owner ~= owner then
      return false
    end
  end

  for switch_id, required in pairs(route_definition.switches) do
    if switch_locks[switch_id] and switch_locks[switch_id] ~= owner then
      return false
    end
    switches[switch_id] = required
    switch_locks[switch_id] = owner
  end

  for _, block_id in ipairs(route_definition.blocks) do
    blocks[block_id].owner = owner
  end

  return true
end

assert(reserve("train_A", route) == true, "first owner should reserve route")
assert(switches.J1 == "main", "switch should align to route")
assert(reserve("train_B", route) == false, "second owner should be blocked")

print("reservation logic ok")
