local util = require("tests.emulator.util")

local M = {}

function M.register(rt, spec)
  spec = spec or {}
  local tier = spec.tier or 2
  local width, height = util.screen_size_for_tier(tier)
  return rt:register_component("screen", {
    address = spec.address,
    proxy_mode = spec.proxy_mode,
    primary = spec.primary ~= false,
    state = {
      tier = tier,
      width = spec.width or width,
      height = spec.height or height,
      precise = spec.precise ~= nil and spec.precise or (tier == 3),
      keyboards = {},
      usable = spec.usable ~= false,
      owner = spec.owner,
    },
    methods = {},
  })
end

return M
