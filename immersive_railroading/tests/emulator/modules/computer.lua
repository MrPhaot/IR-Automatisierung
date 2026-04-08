local M = {}

function M.make(rt)
  return {
    uptime = function()
      return rt.time
    end,
    pullSignal = function(timeout)
      rt:tick(timeout or 0)
      local signal = table.remove(rt.signals, 1)
      if not signal then
        return nil
      end
      return table.unpack(signal)
    end,
  }
end

return M
