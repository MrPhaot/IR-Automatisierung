local SIDES = {"top", "bottom", "left", "right", "front", "back", "north", "south", "east", "west"}

local function make_side_table(values)
  local out = {}
  for _, side in ipairs(SIDES) do
    out[side] = values and values[side] or 0
  end
  return out
end

local M = {}

function M.register(rt, spec)
  spec = spec or {}
  return rt:register_component("redstone", {
    address = spec.address,
    proxy_mode = spec.proxy_mode,
    primary = spec.primary ~= false,
    state = {
      outputs = make_side_table(spec.outputs),
      inputs = make_side_table(spec.inputs),
    },
    methods = {
      setOutput = function(self, side, value)
        self.state.outputs[side] = value
        rt.logs.redstone[#rt.logs.redstone + 1] = {
          address = self.address,
          side = side,
          value = value,
        }
        return value
      end,
      getOutput = function(self, side)
        return self.state.outputs[side] or 0
      end,
      getInput = function(self, side)
        return self.state.inputs[side] or 0
      end,
    },
  })
end

return M
