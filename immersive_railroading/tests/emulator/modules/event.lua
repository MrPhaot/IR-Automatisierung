local M = {}

function M.make(rt)
  local event = {}

  function event.pull(timeout)
    local terminated = rt:take_failure("event_pull_terminated")
    if terminated then
      error({
        reason = "terminated",
        code = terminated.code or 130,
        message = terminated.message or "terminated",
      }, 0)
    end
    rt:tick(timeout or 0)
    local signal = table.remove(rt.signals, 1)
    if not signal then
      return nil
    end
    return table.unpack(signal)
  end

  function event.push(signal, ...)
    rt:queue_signal({signal, ...})
    return true
  end

  function event.clear()
    rt.signals = {}
  end

  return event
end

return M
