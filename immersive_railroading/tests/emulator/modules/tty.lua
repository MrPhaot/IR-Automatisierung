local M = {}

function M.make(rt)
  local tty = {}

  function tty.isAvailable()
    return rt:current_window() ~= nil
  end

  function tty.gpu()
    if rt.failures.tty_gpu_nil then
      return nil
    end
    local win = rt:current_window()
    return win and rt:proxy_for(win.gpu_address) or nil
  end

  function tty.bind(gpu_proxy)
    local address = gpu_proxy and gpu_proxy.address
    if not address or not rt.components.by_address[address] then
      return nil, "invalid gpu"
    end
    rt:current_window().gpu_address = address
    return true
  end

  function tty.getViewport()
    local win = rt:current_window()
    return win.width, win.height, 0, 0, 1, 1
  end

  return tty
end

return M
