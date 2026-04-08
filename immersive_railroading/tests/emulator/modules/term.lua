local M = {}

function M.make(rt)
  local term = {}

  function term.gpu()
    if rt.failures.term_gpu_nil then
      return nil
    end
    local win = rt:current_window()
    return win and rt:proxy_for(win.gpu_address) or nil
  end

  function term.screen()
    local win = rt:current_window()
    return win and win.screen_address or nil
  end

  function term.keyboard()
    local win = rt:current_window()
    return win and win.keyboard_address or nil
  end

  function term.getGlobalArea()
    local win = rt:current_window()
    return win.x, win.y, win.width, win.height
  end

  function term.setCursor(x, y)
    local win = rt:current_window()
    win.cursor_x = x
    win.cursor_y = y
  end

  function term.getCursor()
    local win = rt:current_window()
    return win.cursor_x or 1, win.cursor_y or 1
  end

  function term.clear()
    local failure = rt:take_failure("term_clear_error")
    if failure then
      error(failure.message or "term.clear failed", 0)
    end
    local win = rt:current_window()
    if not win or not win.gpu_address or not win.screen_address then
      return nil, "inactive terminal"
    end
    rt:fill_screen(win.screen_address, win.x, win.y, win.width, win.height, " ")
    win.cursor_x = 1
    win.cursor_y = 1
    return true
  end

  return term
end

return M
