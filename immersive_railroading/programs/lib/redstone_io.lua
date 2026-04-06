local M = {}

local SIDE_ALIASES = {
  bottom = "bottom",
  top = "top",
  back = "back",
  front = "front",
  right = "right",
  left = "left",
  north = "north",
  south = "south",
  west = "west",
  east = "east",
}

function M.normalize_side(side)
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

function M.make_controller(redstone_proxy, log_fn, now_fn)
  local controller = {
    redstone = redstone_proxy,
    log = log_fn or function() end,
    now = now_fn or os.clock,
    states = {},
    pulses = {},
  }

  local function inactive_level(config)
    return config.active_high == false and (config.strength or 15) or 0
  end

  local function active_level(config)
    return config.active_high == false and 0 or (config.strength or 15)
  end

  function controller:set_output(name, config, active)
    if not self.redstone then
      error("component.redstone is required for configured station outputs")
    end
    local side = M.normalize_side(config.side)
    if not side then
      error(("invalid redstone side for output %s"):format(name))
    end
    local target = active and active_level(config) or inactive_level(config)
    local key = ("%s:%s"):format(name, side)
    if self.states[key] == target then
      return
    end
    self.redstone.setOutput(side, target)
    self.states[key] = target
    self.log(active and "redstone_output_active" or "redstone_output_inactive", {
      output = name,
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
    self.pulses[name] = self.now() + duration
  end

  function controller:tick(outputs)
    local now = self.now()
    for name, deadline in pairs(self.pulses) do
      if now >= deadline then
        self.pulses[name] = nil
        local config = outputs and outputs[name]
        if config then
          self:set_output(name, config, false)
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
