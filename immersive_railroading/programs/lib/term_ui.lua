local M = {
  API_VERSION = 2,
}
local component = (function()
  local ok, value = pcall(require, "component")
  if ok then
    return value
  end
  return nil
end)()
local oc_proxy = require("lib.oc_proxy")

local function as_positive_integer(value)
  if type(value) ~= "number" then
    return nil
  end
  value = math.floor(value)
  if value <= 0 then
    return nil
  end
  return value
end

local function fit_text(text, width)
  text = tostring(text or "")
  width = math.max(width or #text, 0)
  if #text <= width then
    return text .. string.rep(" ", width - #text)
  end
  if width <= 1 then
    return text:sub(1, width)
  end
  return text:sub(1, width - 1) .. ">"
end

function M.fit_text(text, width)
  return fit_text(text, width)
end

function M.box(x, y, width, height, title)
  return {
    x = x,
    y = y,
    width = width,
    height = height,
    title = title,
  }
end

function M.button(id, label, x, y, width)
  local text = ("[ %s ]"):format(label or "")
  return {
    id = id,
    label = label,
    x = x,
    y = y,
    width = width or #text,
    height = 1,
  }
end

function M.is_valid_target(target)
  return type(target) == "table"
    and type(target.x) == "number"
    and type(target.y) == "number"
    and type(target.width) == "number"
    and type(target.height) == "number"
    and target.width > 0
    and target.height > 0
end

function M.hit(rect, px, py)
  if not M.is_valid_target(rect)
    or type(px) ~= "number"
    or type(py) ~= "number" then
    return false
  end
  return px >= rect.x
    and px < rect.x + rect.width
    and py >= rect.y
    and py < rect.y + rect.height
end

local function add_line(buffer, x, y, text)
  if type(buffer) ~= "table" or type(x) ~= "number" or type(y) ~= "number" or type(text) ~= "string" then
    return
  end
  buffer[#buffer + 1] = {
    x = math.floor(x),
    y = math.floor(y),
    text = text,
  }
end

function M.render_box(buffer, box)
  if type(box) ~= "table" then
    return
  end

  local x = as_positive_integer(box.x)
  local y = as_positive_integer(box.y)
  local width = as_positive_integer(box.width)
  local height = as_positive_integer(box.height)
  if not x or not y or not width or not height then
    return
  end

  if width == 1 or height == 1 then
    add_line(buffer, x, y, fit_text(box.title or "", width))
    return
  end

  if width == 2 or height == 2 then
    add_line(buffer, x, y, "+" .. string.rep("-", math.max(width - 2, 0)) .. "+")
    if height > 1 then
      add_line(buffer, x, y + height - 1, "+" .. string.rep("-", math.max(width - 2, 0)) .. "+")
    end
    return
  end

  local horizontal = string.rep("-", math.max(width - 2, 0))
  add_line(buffer, x, y, "+" .. horizontal .. "+")
  for row = y + 1, y + height - 2 do
    add_line(buffer, x, row, "|" .. string.rep(" ", math.max(width - 2, 0)) .. "|")
  end
  add_line(buffer, x, y + height - 1, "+" .. horizontal .. "+")

  if box.title and width > 4 then
    add_line(buffer, x + 2, y, fit_text(box.title, width - 4))
  end
end

function M.render_tabs(buffer, tabs, active_index, x, y)
  local click_targets = {}
  if type(x) ~= "number" or type(y) ~= "number" then
    return click_targets
  end

  local cursor_x = x
  for index, label in ipairs(tabs or {}) do
    local text = index == active_index and ("[> %s <]"):format(label) or ("[ %s ]"):format(label)
    add_line(buffer, cursor_x, y, text)
    local target = {
      id = "tab:" .. tostring(label),
      x = cursor_x,
      y = y,
      width = #text,
      height = 1,
      tab_index = index,
    }
    if M.is_valid_target(target) then
      click_targets[#click_targets + 1] = target
    end
    cursor_x = cursor_x + #text + 1
  end

  return click_targets
end

function M.render_list(buffer, x, y, width, items, selected_index, max_rows)
  local targets = {}
  if type(x) ~= "number" or type(y) ~= "number" then
    return targets
  end

  width = math.max(math.floor(width or 0), 1)
  max_rows = max_rows and math.max(math.floor(max_rows), 0) or math.huge
  local row_count = 0

  for index, item in ipairs(items or {}) do
    if row_count >= max_rows then
      break
    end
    row_count = row_count + 1
    local prefix = index == selected_index and ">" or " "
    local text = fit_text(prefix .. " " .. tostring(item.label or item), width)
    add_line(buffer, x, y + row_count - 1, text)
    local target = {
      id = item.id or ("row:" .. index),
      x = x,
      y = y + row_count - 1,
      width = width,
      height = 1,
      index = index,
    }
    if M.is_valid_target(target) then
      targets[#targets + 1] = target
    end
  end

  return targets
end

function M.render_buttons(buffer, buttons)
  local targets = {}
  for _, button in ipairs(buttons or {}) do
    local width = math.max(math.floor(button.width or 0), 1)
    local target = {
      id = button.id,
      x = button.x,
      y = button.y,
      width = width,
      height = 1,
    }
    if M.is_valid_target(target) then
      add_line(buffer, target.x, target.y, fit_text(("[ %s ]"):format(button.label or ""), target.width))
      targets[#targets + 1] = target
    end
  end
  return targets
end

function M.render_lines(width, height, buffer)
  width = as_positive_integer(width)
  height = as_positive_integer(height)
  if not width or not height then
    return {}
  end

  local full_lines = {}
  for y = 1, height do
    full_lines[y] = string.rep(" ", width)
  end

  for _, row in ipairs(buffer or {}) do
    if type(row.x) == "number"
      and type(row.y) == "number"
      and type(row.text) == "string"
      and row.y >= 1
      and row.y <= height
      and row.x <= width then
      local x = math.max(math.floor(row.x), 1)
      local text = row.text
      if x + #text - 1 > width then
        text = text:sub(1, width - x + 1)
      end
      if #text > 0 then
        local line = full_lines[row.y]
        full_lines[row.y] = line:sub(1, x - 1) .. text .. line:sub(x + #text)
      end
    end
  end

  return full_lines
end

function M.reset_cache()
  M._frame_cache = nil
end

local function clear_screen(gpu_api, width, height, origin_x, origin_y)
  local ok, result = oc_proxy.invoke(component, gpu_api, "fill", origin_x, origin_y, width, height, " ")
  if ok then
    return true
  end
  return nil, tostring(result or "gpu fill failed")
end

local function write_line(gpu_api, x, y, line)
  local ok, result = oc_proxy.invoke(component, gpu_api, "set", x, y, line)
  if ok then
    return true
  end
  return nil, tostring(result or "gpu set failed")
end

function M.flush(term_api, gpu_api, width, height, buffer, origin_x, origin_y)
  width = as_positive_integer(width)
  height = as_positive_integer(height)
  origin_x = as_positive_integer(origin_x) or 1
  origin_y = as_positive_integer(origin_y) or 1
  if not width or not height then
    return nil, "invalid frame size"
  end
  if not oc_proxy.can_invoke(component, gpu_api, "set") then
    return nil, "active gpu required for fullscreen ui"
  end

  M._frame_cache = M._frame_cache or {
    width = nil,
    height = nil,
    origin_x = nil,
    origin_y = nil,
    lines = {},
  }

  local full_lines = M.render_lines(width, height, buffer)
  local cache_invalid = M._frame_cache.width ~= width
    or M._frame_cache.height ~= height
    or M._frame_cache.origin_x ~= origin_x
    or M._frame_cache.origin_y ~= origin_y
  if cache_invalid then
    M._frame_cache = {
      width = width,
      height = height,
      origin_x = origin_x,
      origin_y = origin_y,
      lines = {},
    }
    local ok, err = clear_screen(gpu_api, width, height, origin_x, origin_y)
    if not ok then
      return nil, err or "gpu fill failed"
    end
  end

  for y = 1, height do
    if M._frame_cache.lines[y] ~= full_lines[y] then
      local ok, err = write_line(gpu_api, origin_x, origin_y + y - 1, full_lines[y])
      if not ok then
        return nil, err or "gpu set failed"
      end
      M._frame_cache.lines[y] = full_lines[y]
    end
  end

  return true
end

return M
