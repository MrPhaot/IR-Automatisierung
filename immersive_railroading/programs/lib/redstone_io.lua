local M = {}
local oc_proxy = require("lib.oc_proxy")

local SIDE_ALIASES = {
  bottom = 0,
  down = 0,
  top = 1,
  up = 1,
  back = 2,
  north = 2,
  front = 3,
  south = 3,
  right = 4,
  west = 4,
  left = 5,
  east = 5,
}

function M.normalize_side(side)
  if type(side) == "number" then
    return side
  end
  if type(side) ~= "string" then
    return nil
  end
  return SIDE_ALIASES[side:lower()]
end

function M.validate_outputs(outputs)
  local errors = {}
  for name, output in pairs(outputs or {}) do
    if type(output) ~= "table" then
      errors[#errors + 1] = ("redstone output %s must be a table"):format(name)
    else
      if not M.normalize_side(output.side) then
        errors[#errors + 1] = ("redstone output %s uses unknown side %s"):format(name, tostring(output.side))
      end
      if output.strength ~= nil and type(output.strength) ~= "number" then
        errors[#errors + 1] = ("redstone output %s.strength must be numeric"):format(name)
      end
      if output.pulse_ticks ~= nil and type(output.pulse_ticks) ~= "number" then
        errors[#errors + 1] = ("redstone output %s.pulse_ticks must be numeric"):format(name)
      end
    end
  end
  return {
    ok = #errors == 0,
    errors = errors,
  }
end

function M.make_controller(resolve_redstone_proxy, log_fn, now_fn, component_api)
  local controller = {
    resolve_redstone_proxy = resolve_redstone_proxy or function()
      return nil
    end,
    log = log_fn or function() end,
    now = now_fn or os.clock,
    states = {},
    pulses = {},
    component = component_api,
  }

  local function inactive_level(config)
    return config.active_high == false and (config.strength or 15) or 0
  end

  local function active_level(config)
    return config.active_high == false and 0 or (config.strength or 15)
  end

  local function state_key(name, config, side)
    local address = config and config.address or "__primary__"
    return ("%s:%s:%s"):format(tostring(address), tostring(name), tostring(side))
  end

  function controller:set_output(name, config, active)
    local redstone, redstone_error = self.resolve_redstone_proxy(config)
    if not redstone then
      error(redstone_error or "component.redstone is required for configured station outputs")
    end
    local side = M.normalize_side(config.side)
    if not side then
      error(("invalid redstone side for output %s"):format(name))
    end
    local target = active and active_level(config) or inactive_level(config)
    local key = state_key(name, config, side)
    if self.states[key] == target then
      return
    end
    local ok, invoke_error = oc_proxy.invoke(self.component, redstone, "setOutput", side, target)
    if not ok then
      error(tostring(invoke_error or ("failed to set redstone output " .. tostring(name))))
    end
    self.states[key] = target
    self.log(active and "redstone_output_active" or "redstone_output_inactive", {
      output = name,
      address = tostring(config and config.address or "<primary>"),
      side = side,
      strength = target,
    })
  end

  function controller:update(outputs, pending_names)
    for name, config in pairs(outputs or {}) do
      self:set_output(name, config, pending_names and pending_names[name] == true)
    end
  end

  function controller:pulse(name, config)
    local duration = (config.pulse_ticks or 20) / 20
    self:set_output(name, config, true)
    self.pulses[state_key(name, config, M.normalize_side(config.side) or config.side)] = {
      deadline = self.now() + duration,
      name = name,
    }
  end

  function controller:tick(outputs)
    local now = self.now()
    for key, pulse in pairs(self.pulses) do
      if now >= pulse.deadline then
        self.pulses[key] = nil
        local config = outputs and outputs[pulse.name]
        if config then
          self:set_output(pulse.name, config, false)
        end
      end
    end
  end

  function controller:shutdown(outputs)
    for name, config in pairs(outputs or {}) do
      self:set_output(name, config, false)
    end
    self.pulses = {}
  end

  return controller
end

return M
