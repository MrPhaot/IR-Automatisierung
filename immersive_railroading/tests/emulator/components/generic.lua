local M = {}

function M.register(rt, kind, spec)
  spec = spec or {}
  local methods = {}
  for name, fn in pairs(spec.methods or {}) do
    methods[name] = function(self, ...)
      return fn(self, ...)
    end
  end
  return rt:register_component(kind, {
    address = spec.address,
    proxy_mode = spec.proxy_mode,
    primary = spec.primary == true,
    state = spec.state or {},
    methods = methods,
  })
end

return M
