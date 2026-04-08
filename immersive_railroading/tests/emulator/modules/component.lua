local M = {}

function M.make(rt)
  local component = {}

  local mt = {
    __index = function(_, key)
      local primary = rt.components.primary[key]
      if primary then
        return rt:proxy_for(primary.address)
      end
      return nil
    end,
  }
  setmetatable(component, mt)

  function component.isAvailable(kind)
    return rt.components.primary[kind] ~= nil
  end

  function component.getPrimary(kind)
    local primary = rt.components.primary[kind]
    return primary and rt:proxy_for(primary.address) or nil
  end

  function component.proxy(address)
    return rt:proxy_for(address)
  end

  function component.invoke(address, method, ...)
    local invoke_failure = rt:take_failure("component_invoke_error")
    if invoke_failure then
      error(invoke_failure.message or "invoke unavailable", 0)
    end
    local c = rt.components.by_address[address]
    assert(c, "no such component: " .. tostring(address))
    local fn = c.methods[method]
    assert(type(fn) == "function", "no such method: " .. tostring(method))
    rt.logs.invocations[#rt.logs.invocations + 1] = {address = address, method = method, args = {...}}
    return fn(c, ...)
  end

  return component
end

return M
