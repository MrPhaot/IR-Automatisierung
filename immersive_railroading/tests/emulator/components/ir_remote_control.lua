local function copy_table(source)
  local out = {}
  for key, value in pairs(source or {}) do
    out[key] = value
  end
  return out
end

local M = {}

function M.register(rt, spec)
  spec = spec or {}
  local state = {
    throttle = 0,
    reverser = 0,
    brake = 0,
    independent_brake = 0,
    ignition = false,
    pos = copy_table(spec.pos or {x = 0, y = 64, z = 0}),
    info = copy_table(spec.info),
    consist = copy_table(spec.consist),
  }
  return rt:register_component("ir_remote_control", {
    address = spec.address,
    proxy_mode = spec.proxy_mode,
    primary = spec.primary ~= false,
    state = state,
    methods = {
      info = function(self)
        return copy_table(self.state.info)
      end,
      consist = function(self)
        return copy_table(self.state.consist)
      end,
      getPos = function(self)
        return self.state.pos.x, self.state.pos.y, self.state.pos.z
      end,
      setThrottle = function(self, value)
        self.state.throttle = value
        rt.logs.remote[#rt.logs.remote + 1] = {method = "setThrottle", value = value}
        return true
      end,
      setReverser = function(self, value)
        self.state.reverser = value
        rt.logs.remote[#rt.logs.remote + 1] = {method = "setReverser", value = value}
        return true
      end,
      setBrake = function(self, value)
        self.state.brake = value
        rt.logs.remote[#rt.logs.remote + 1] = {method = "setBrake", value = value}
        return true
      end,
      setIndependentBrake = function(self, value)
        self.state.independent_brake = value
        rt.logs.remote[#rt.logs.remote + 1] = {method = "setIndependentBrake", value = value}
        return true
      end,
      getIgnition = function(self)
        return self.state.ignition
      end,
      setIgnition = function(self, value)
        self.state.ignition = value == true
        rt.logs.remote[#rt.logs.remote + 1] = {method = "setIgnition", value = self.state.ignition}
        return true
      end,
    },
  })
end

return M
