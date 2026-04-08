local util = require("tests.emulator.util")
local screen_component = require("tests.emulator.components.screen")
local keyboard_component = require("tests.emulator.components.keyboard")
local gpu_component = require("tests.emulator.components.gpu")
local redstone_component = require("tests.emulator.components.redstone")
local remote_component = require("tests.emulator.components.ir_remote_control")
local generic_component = require("tests.emulator.components.generic")

local M = {}

local function default_proxy_mode(spec)
  local configured = spec.proxy_mode or {}
  return {
    gpu = configured.gpu or "invoke_only",
    screen = configured.screen or "invoke_only",
    keyboard = configured.keyboard or "invoke_only",
    redstone = configured.redstone or "direct",
    ir_remote_control = configured.ir_remote_control or "direct",
    generic = configured.generic or "direct",
  }
end

local function can_accept_owner(rt, owner, player)
  if rt.ownership.enabled ~= true then
    return true
  end
  return owner == nil or owner == player
end

function M.make_runtime(spec)
  spec = spec or {}
  local rt = {
    time = spec.time or 0,
    next_address = 1,
    logs = {
      invocations = {},
      signals = {},
      shell = {},
      screen_syncs = {},
      redstone = {},
      remote = {},
    },
    components = {
      by_address = {},
      by_type = {},
      primary = {},
    },
    signals = {},
    windows = {},
    shell = {
      cwd = spec.cwd or "/home/immersive_railroading/programs",
      prompt = spec.prompt or "/home/immersive_railroading/programs # ",
      stdout = {},
      stderr = {},
    },
    text = {
      server = {},
      client = {},
      dirty = {},
    },
    ownership = {
      enabled = spec.can_computers_be_owned ~= false,
      player = spec.player or "player",
    },
    input = {
      control_down = false,
    },
    fs = {
      nodes = {
        ["/"] = {kind = "dir"},
      },
    },
    downloads = spec.downloads or {},
    proxy_mode = default_proxy_mode(spec),
    timers = {},
    failures = spec.failures or {},
  }

  function rt:take_failure(name)
    local failure = self.failures[name]
    if type(failure) == "table" and failure.once ~= false then
      self.failures[name] = nil
    end
    if failure == true then
      self.failures[name] = nil
      return {message = name}
    end
    return failure
  end

  function rt:allocate_address(kind)
    local value = ("%s-%d"):format(kind, self.next_address)
    self.next_address = self.next_address + 1
    return value
  end

  function rt:register_component(kind, spec_)
    local component = {
      address = spec_.address or self:allocate_address(kind),
      type = kind,
      proxy_mode = spec_.proxy_mode or self.proxy_mode[kind] or self.proxy_mode.generic,
      methods = spec_.methods or {},
      state = spec_.state or {},
    }
    self.components.by_address[component.address] = component
    self.components.by_type[kind] = self.components.by_type[kind] or {}
    self.components.by_type[kind][component.address] = component
    if spec_.primary or self.components.primary[kind] == nil then
      self.components.primary[kind] = component
    end
    if kind == "screen" then
      self:ensure_screen_buffers(component.address, component.state.width, component.state.height)
    end
    return component
  end

  function rt:proxy_for(address)
    local component = self.components.by_address[address]
    if not component then
      return nil
    end
    local proxy = {address = address}
    if component.proxy_mode == "direct" then
      for name in pairs(component.methods) do
        proxy[name] = function(...)
          return component.methods[name](component, ...)
        end
      end
    end
    return proxy
  end

  function rt:ensure_screen_buffers(screen_address, width, height)
    local server = self.text.server[screen_address]
    local client = self.text.client[screen_address]
    if not server or #server ~= height or #(server[1] or "") ~= width then
      self.text.server[screen_address] = util.blank_lines(width, height)
    end
    if not client or #client ~= height or #(client[1] or "") ~= width then
      self.text.client[screen_address] = util.blank_lines(width, height)
    end
  end

  function rt:sync_screen(screen_address)
    local screen = self.components.by_address[screen_address]
    if not screen then
      return
    end
    self:ensure_screen_buffers(screen_address, screen.state.width, screen.state.height)
    self.text.client[screen_address] = util.copy_lines(self.text.server[screen_address])
    self.logs.screen_syncs[#self.logs.screen_syncs + 1] = {
      screen_address = screen_address,
      lines = util.copy_lines(self.text.client[screen_address]),
      time = self.time,
    }
  end

  function rt:visible_lines(screen_address)
    return util.copy_lines(self.text.client[screen_address] or {})
  end

  function rt:write_screen(screen_address, x, y, text)
    local screen = self.components.by_address[screen_address]
    assert(screen and screen.type == "screen", "no such screen: " .. tostring(screen_address))
    self:ensure_screen_buffers(screen_address, screen.state.width, screen.state.height)
    util.write_line(self.text.server[screen_address], x, y, text)
    self:sync_screen(screen_address)
  end

  function rt:fill_screen(screen_address, x, y, width, height, char)
    local screen = self.components.by_address[screen_address]
    assert(screen and screen.type == "screen", "no such screen: " .. tostring(screen_address))
    self:ensure_screen_buffers(screen_address, screen.state.width, screen.state.height)
    util.fill_rect(self.text.server[screen_address], x, y, width, height, char)
    self:sync_screen(screen_address)
  end

  function rt:current_window()
    return self.windows.active
  end

  function rt:tick(dt)
    self.time = self.time + (dt or 0)
    local remaining = {}
    for _, timer in ipairs(self.timers) do
      if self.time >= timer.at then
        timer.fn()
      else
        remaining[#remaining + 1] = timer
      end
    end
    self.timers = remaining
  end

  function rt:after(delay, fn)
    self.timers[#self.timers + 1] = {
      at = self.time + (delay or 0),
      fn = fn,
    }
  end

  function rt:queue_signal(signal)
    self.signals[#self.signals + 1] = signal
    self.logs.signals[#self.logs.signals + 1] = signal
  end

  function rt:queue_touch(screen_address, x, y, button, player)
    local screen = self.components.by_address[screen_address]
    player = player or self.ownership.player
    if not screen or screen.type ~= "screen" or screen.state.usable == false then
      return
    end
    if not can_accept_owner(self, screen.state.owner, player) then
      return
    end
    self:queue_signal({"touch", screen_address, x, y, button or 0, player})
  end

  function rt:queue_scroll(screen_address, x, y, delta, player)
    local screen = self.components.by_address[screen_address]
    player = player or self.ownership.player
    if not screen or screen.type ~= "screen" or screen.state.usable == false then
      return
    end
    if not can_accept_owner(self, screen.state.owner, player) then
      return
    end
    self:queue_signal({"scroll", screen_address, x, y, delta or 0, player})
  end

  function rt:queue_key_down(keyboard_address, char_code, key_code, player)
    local keyboard = self.components.by_address[keyboard_address]
    player = player or self.ownership.player
    if not keyboard or keyboard.type ~= "keyboard" or keyboard.state.usable == false then
      return
    end
    local screen = self.components.by_address[keyboard.state.screen_address]
    if screen and not can_accept_owner(self, screen.state.owner, player) then
      return
    end
    self:queue_signal({"key_down", keyboard_address, char_code or 0, key_code or 0, player})
  end

  function rt:queue_clipboard(keyboard_address, text, player)
    local keyboard = self.components.by_address[keyboard_address]
    player = player or self.ownership.player
    if not keyboard or keyboard.type ~= "keyboard" or keyboard.state.usable == false then
      return
    end
    local screen = self.components.by_address[keyboard.state.screen_address]
    if screen and not can_accept_owner(self, screen.state.owner, player) then
      return
    end
    self:queue_signal({"clipboard", keyboard_address, text or "", player})
  end

  function rt:queue_interrupted()
    self:queue_signal({"interrupted"})
  end

  function rt:resize_screen(screen_address, width, height)
    local screen = self.components.by_address[screen_address]
    if not screen or screen.type ~= "screen" then
      return
    end
    screen.state.width = width
    screen.state.height = height
    self:ensure_screen_buffers(screen_address, width, height)
    if self.windows.active and self.windows.active.screen_address == screen_address then
      self.windows.active.width = width
      self.windows.active.height = height
    end
    self:queue_signal({"screen_resized", screen_address, width, height})
  end

  function rt:shell_redraw(message)
    local win = self:current_window()
    if not win or not win.screen_address then
      return
    end
    local screen = self.components.by_address[win.screen_address]
    self.text.client[win.screen_address] = util.blank_lines(screen.state.width, screen.state.height)
    if message then
      util.write_line(self.text.client[win.screen_address], 1, 1, tostring(message))
    end
    util.write_line(self.text.client[win.screen_address], 1, message and 2 or 1, self.shell.prompt)
    self.logs.shell[#self.logs.shell + 1] = {
      message = message,
      prompt = self.shell.prompt,
    }
  end

  function rt:register_screen(spec_)
    spec_ = spec_ or {}
    spec_.proxy_mode = spec_.proxy_mode or self.proxy_mode.screen
    return screen_component.register(self, spec_)
  end

  function rt:register_keyboard(spec_)
    spec_ = spec_ or {}
    spec_.proxy_mode = spec_.proxy_mode or self.proxy_mode.keyboard
    return keyboard_component.register(self, spec_)
  end

  function rt:register_gpu(spec_)
    spec_ = spec_ or {}
    spec_.proxy_mode = spec_.proxy_mode or self.proxy_mode.gpu
    return gpu_component.register(self, spec_)
  end

  function rt:register_redstone(spec_)
    spec_ = spec_ or {}
    spec_.proxy_mode = spec_.proxy_mode or self.proxy_mode.redstone
    return redstone_component.register(self, spec_)
  end

  function rt:register_ir_remote_control(spec_)
    spec_ = spec_ or {}
    spec_.proxy_mode = spec_.proxy_mode or self.proxy_mode.ir_remote_control
    return remote_component.register(self, spec_)
  end

  function rt:register_component_kind(kind, spec_)
    spec_ = spec_ or {}
    spec_.proxy_mode = spec_.proxy_mode or self.proxy_mode[kind] or self.proxy_mode.generic
    return generic_component.register(self, kind, spec_)
  end

  local screen = rt:register_screen(spec.screen or {})
  local keyboard = rt:register_keyboard({
    screen_address = screen.address,
    owner = (spec.screen and spec.screen.owner) or nil,
  })
  local gpu = rt:register_gpu({
    screen_address = screen.address,
  })
  rt.windows.active = {
    x = (spec.window and spec.window.x) or 1,
    y = (spec.window and spec.window.y) or 1,
    width = screen.state.width,
    height = screen.state.height,
    screen_address = screen.address,
    keyboard_address = keyboard.address,
    gpu_address = gpu.address,
    cursor_x = 1,
    cursor_y = 1,
  }
  rt.term = rt.windows.active

  if spec.redstone ~= false then
    rt:register_redstone(spec.redstone or {})
  end
  if spec.ir_remote_control ~= false then
    rt:register_ir_remote_control(spec.ir_remote_control or {})
  end

  util.ensure_dir(rt.fs.nodes, "/home")
  util.ensure_dir(rt.fs.nodes, "/home/immersive_railroading")
  util.ensure_dir(rt.fs.nodes, "/home/immersive_railroading/programs")

  return rt
end

return M
