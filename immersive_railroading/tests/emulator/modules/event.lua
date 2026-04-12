local M = {}

function M.make(rt)
  local event = {}

  function event.pull(timeout)
    rt.metrics.event_pulls = (rt.metrics.event_pulls or 0) + 1
    if rt.metrics.event_pulls > (rt.limits and rt.limits.max_event_pulls or 2000) then
      error({
        reason = "timeout",
        code = 124,
        message = "event pull limit exceeded",
      }, 0)
    end

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
