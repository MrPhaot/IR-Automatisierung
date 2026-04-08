local M = {}

function M.make(rt)
  return {
    isControlDown = function()
      return rt.input.control_down == true
    end,
  }
end

return M
