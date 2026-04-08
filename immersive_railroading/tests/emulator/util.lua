local M = {}

function M.screen_size_for_tier(tier)
  if tier == 3 then
    return 160, 50
  end
  if tier == 1 then
    return 50, 16
  end
  return 80, 25
end

function M.blank_lines(width, height)
  local lines = {}
  for y = 1, height do
    lines[y] = string.rep(" ", width)
  end
  return lines
end

function M.copy_lines(lines)
  local out = {}
  for index, line in ipairs(lines or {}) do
    out[index] = line
  end
  return out
end

function M.write_line(lines, x, y, text)
  if type(lines) ~= "table" or not lines[y] then
    return
  end
  local width = #lines[y]
  if type(x) ~= "number" or x < 1 or x > width then
    return
  end
  text = tostring(text or "")
  if x + #text - 1 > width then
    text = text:sub(1, width - x + 1)
  end
  lines[y] = lines[y]:sub(1, x - 1) .. text .. lines[y]:sub(x + #text)
end

function M.fill_rect(lines, x, y, width, height, char)
  char = tostring(char or " "):sub(1, 1)
  for row = y, y + height - 1 do
    if lines[row] then
      M.write_line(lines, x, row, string.rep(char, width))
    end
  end
end

function M.ensure_dir(fs_nodes, path)
  fs_nodes[path] = fs_nodes[path] or {kind = "dir"}
  return fs_nodes[path]
end

return M
