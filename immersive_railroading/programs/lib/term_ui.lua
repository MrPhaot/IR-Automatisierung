local M = {}

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
  return {
    id = id,
    label = label,
    x = x,
    y = y,
    width = width or (#label + 2),
    height = 1,
  }
end

function M.hit(rect, px, py)
  if type(rect) ~= "table"
    or type(rect.x) ~= "number"
    or type(rect.y) ~= "number"
    or type(rect.width) ~= "number"
    or type(rect.height) ~= "number"
    or type(px) ~= "number"
    or type(py) ~= "number" then
    return false
  end
  return px >= rect.x and px < rect.x + rect.width and py >= rect.y and py < rect.y + rect.height
end

function M.render_box(buffer, box)
  local x1 = box.x
  local x2 = box.x + box.width - 1
  local y1 = box.y
  local y2 = box.y + box.height - 1
  buffer[#buffer + 1] = {x = x1, y = y1, text = "+" .. string.rep("-", box.width - 2) .. "+"}
  for y = y1 + 1, y2 - 1 do
    buffer[#buffer + 1] = {x = x1, y = y, text = "|" .. string.rep(" ", box.width - 2) .. "|"}
  end
  if box.height > 1 then
    buffer[#buffer + 1] = {x = x1, y = y2, text = "+" .. string.rep("-", box.width - 2) .. "+"}
  end
  if box.title and box.width > 4 then
    buffer[#buffer + 1] = {x = x1 + 2, y = y1, text = fit_text(box.title, box.width - 4)}
  end
end

function M.render_tabs(buffer, tabs, active_index, x, y)
  local cursor_x = x
  local click_targets = {}
  for index, label in ipairs(tabs) do
    local text = index == active_index and ("[> %s <]"):format(label) or ("[ %s ]"):format(label)
    buffer[#buffer + 1] = {x = cursor_x, y = y, text = text}
    click_targets[#click_targets + 1] = {
      id = "tab:" .. label,
      x = cursor_x,
      y = y,
      width = #text,
      height = 1,
      tab_index = index,
    }
    cursor_x = cursor_x + #text + 1
  end
  return click_targets
end

function M.render_list(buffer, x, y, width, items, selected_index)
  local targets = {}
  for index, item in ipairs(items or {}) do
    local prefix = index == selected_index and ">" or " "
    local text = fit_text(prefix .. " " .. tostring(item.label or item), width)
    buffer[#buffer + 1] = {x = x, y = y + index - 1, text = text}
    targets[#targets + 1] = {
      id = item.id or ("row:" .. index),
      x = x,
      y = y + index - 1,
      width = width,
      height = 1,
      index = index,
    }
  end
  return targets
end

function M.render_buttons(buffer, buttons)
  for _, button in ipairs(buttons or {}) do
    buffer[#buffer + 1] = {
      x = button.x,
      y = button.y,
      text = fit_text(("[ %s ]"):format(button.label), button.width),
    }
  end
  return buttons or {}
end

function M.flush(term_api, gpu_api, width, height, buffer)
  M._frame_cache = M._frame_cache or {
    width = nil,
    height = nil,
    lines = {},
  }

  local full_lines = {}
  for y = 1, height do
    full_lines[y] = string.rep(" ", width)
  end

  for _, row in ipairs(buffer) do
    if type(row.x) == "number" and type(row.y) == "number" and type(row.text) == "string"
      and row.y >= 1 and row.y <= height and row.x <= width then
      local x = math.max(row.x, 1)
      local text = row.text
      if x + #text - 1 > width then
        text = text:sub(1, width - x + 1)
      end
      local line = full_lines[row.y]
      full_lines[row.y] = line:sub(1, x - 1) .. text .. line:sub(x + #text)
    end
  end

  local cache_invalid = M._frame_cache.width ~= width or M._frame_cache.height ~= height
  if cache_invalid then
    M._frame_cache = {
      width = width,
      height = height,
      lines = {},
    }
    if gpu_api and type(gpu_api.fill) == "function" then
      gpu_api.fill(1, 1, width, height, " ")
    elseif term_api and type(term_api.clear) == "function" then
      term_api.clear()
    end
  end

  for y = 1, height do
    if M._frame_cache.lines[y] ~= full_lines[y] then
      if term_api and type(term_api.setCursor) == "function" and type(io.write) == "function" then
        term_api.setCursor(1, y)
        io.write(full_lines[y])
      end
      M._frame_cache.lines[y] = full_lines[y]
    end
  end
end

function M.fit_text(text, width)
  return fit_text(text, width)
end

return M
