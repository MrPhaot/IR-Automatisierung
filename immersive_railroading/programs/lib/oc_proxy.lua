local M = {}

function M.read(target, key)
  if target == nil then
    return nil
  end
  local ok, value = pcall(function()
    return target[key]
  end)
  if ok then
    return value
  end
  return nil
end

function M.address_of(target)
  local address = M.read(target, "address")
  if type(address) == "string" and address ~= "" then
    return address
  end
  return nil
end

function M.can_invoke(component_api, target, method)
  if type(M.read(target, method)) == "function" then
    return true
  end
  return type(M.address_of(target)) == "string"
    and component_api ~= nil
    and type(component_api.invoke) == "function"
end

function M.invoke(component_api, target, method, ...)
  local direct = M.read(target, method)
  if type(direct) == "function" then
    local ok, first, second, third, fourth, fifth, sixth = pcall(direct, ...)
    if ok then
      return true, first, second, third, fourth, fifth, sixth
    end
    return false, first
  end

  local address = M.address_of(target)
  if component_api and type(component_api.invoke) == "function" and address then
    local ok, first, second, third, fourth, fifth, sixth = pcall(component_api.invoke, address, method, ...)
    if ok then
      return true, first, second, third, fourth, fifth, sixth
    end
    return false, first
  end

  return false, "invoke unavailable"
end

return M
