local M = {}

function M.register(rt, spec)
  spec = spec or {}
  local component

  component = rt:register_component("gpu", {
    address = spec.address,
    proxy_mode = spec.proxy_mode,
    primary = spec.primary ~= false,
    state = {
      screen_address = spec.screen_address,
    },
    methods = {
      bind = function(self, screen_address)
        local screen = rt.components.by_address[screen_address]
        assert(screen and screen.type == "screen", "no such screen: " .. tostring(screen_address))
        self.state.screen_address = screen_address
        rt.components.primary.gpu = self
        if rt.windows.active then
          rt.windows.active.gpu_address = self.address
          rt.windows.active.screen_address = screen_address
          rt.windows.active.width = screen.state.width
          rt.windows.active.height = screen.state.height
        end
        return true
      end,
      getScreen = function(self)
        return self.state.screen_address
      end,
      getResolution = function(self)
        local screen = rt.components.by_address[self.state.screen_address]
        if not screen then
          return nil
        end
        return screen.state.width, screen.state.height
      end,
      set = function(self, x, y, text)
        local failure = rt:take_failure("gpu_set_error")
        if failure then
          error(failure.message or "gpu set failed", 0)
        end
        assert(self.state.screen_address, "gpu is not bound to a screen")
        rt:write_screen(self.state.screen_address, x, y, text)
        return true
      end,
      fill = function(self, x, y, width, height, char)
        local failure = rt:take_failure("gpu_fill_error")
        if failure then
          error(failure.message or "gpu fill failed", 0)
        end
        assert(self.state.screen_address, "gpu is not bound to a screen")
        rt:fill_screen(self.state.screen_address, x, y, width, height, char)
        return true
      end,
    },
  })

  return component
end

return M
