local M = {}

function M.make(rt)
  return {
    execute = function(command)
      local url, path = command:match('^wget %-f "([^"]+)" "([^"]+)"$')
      if not url then
        return nil, "unsupported shell command"
      end
      local body = rt.downloads[url]
      if body == nil then
        return nil, "download unavailable"
      end
      rt.fs.nodes[path] = {kind = "file", content = body}
      return true
    end,
    getWorkingDirectory = function()
      return rt.shell.cwd
    end,
    setWorkingDirectory = function(path)
      rt.shell.cwd = path
      return true
    end,
  }
end

return M
