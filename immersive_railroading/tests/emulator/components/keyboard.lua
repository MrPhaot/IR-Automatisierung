local M = {}

function M.register(rt, spec)
  spec = spec or {}
  local keyboard = rt:register_component("keyboard", {
    address = spec.address,
    proxy_mode = spec.proxy_mode,
    primary = spec.primary ~= false,
    state = {
      screen_address = spec.screen_address,
      usable = spec.usable ~= false,
      owner = spec.owner,
    },
    methods = {},
  })

  if spec.screen_address then
    local screen = rt.components.by_address[spec.screen_address]
    if screen and screen.state and screen.state.keyboards then
      screen.state.keyboards[keyboard.address] = true
    end
  end

  return keyboard
end

return M
