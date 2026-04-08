local util = require("tests.emulator.util")

local M = {}

function M.make(rt)
  return {
    exists = function(path)
      return rt.fs.nodes[path] ~= nil
    end,
    isDirectory = function(path)
      return rt.fs.nodes[path] and rt.fs.nodes[path].kind == "dir" or false
    end,
    makeDirectory = function(path)
      util.ensure_dir(rt.fs.nodes, path)
      return true
    end,
  }
end

return M
