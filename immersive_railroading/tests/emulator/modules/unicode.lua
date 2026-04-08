local M = {}

function M.make()
  return {
    char = function(code)
      return utf8.char(code)
    end,
    len = function(text)
      return utf8.len(text)
    end,
    sub = function(text, i, j)
      return string.sub(text, i, j)
    end,
  }
end

return M
