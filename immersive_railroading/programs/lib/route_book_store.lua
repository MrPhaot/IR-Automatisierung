local M = {}

local TOP_LEVEL_ORDER = {"AUGMENTS", "STATIONS", "ROUTES", "SCHEDULES"}

local function copy_array(values)
  local out = {}
  for i, value in ipairs(values or {}) do
    out[i] = value
  end
  return out
end

local function sorted_keys(source)
  local keys = {}
  for key in pairs(source or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys, function(a, b)
    local na = tonumber(a)
    local nb = tonumber(b)
    if na and nb then
      return na < nb
    end
    return tostring(a) < tostring(b)
  end)
  return keys
end

function M.new_book()
  return {
    AUGMENTS = {DETECTORS = {}},
    STATIONS = {},
    ROUTES = {},
    SCHEDULES = {},
  }
end

function M.canonicalize(book)
  book = book or {}
  local out = M.new_book()
  out.AUGMENTS = book.AUGMENTS or out.AUGMENTS
  out.AUGMENTS.DETECTORS = out.AUGMENTS.DETECTORS or {}
  out.STATIONS = book.STATIONS or {}
  out.ROUTES = book.ROUTES or {}
  out.SCHEDULES = book.SCHEDULES or {}

  for _, station in pairs(out.STATIONS) do
    station.detector_ids = copy_array(station.detector_ids or {})
    station.redstone_outputs = station.redstone_outputs or {}
  end
  for _, schedule in pairs(out.SCHEDULES) do
    schedule.entries = copy_array(schedule.entries or {})
  end
  return out
end

local function quote_string(value)
  return string.format("%q", value)
end

local function is_identifier(key)
  return type(key) == "string" and key:match("^[A-Za-z_][A-Za-z0-9_]*$")
end

local function serialize_value(value, indent)
  indent = indent or ""
  local next_indent = indent .. "  "
  local value_type = type(value)
  if value_type == "string" then
    return quote_string(value)
  end
  if value_type == "number" or value_type == "boolean" then
    return tostring(value)
  end
  if value_type ~= "table" then
    error("unsupported route book value type: " .. value_type)
  end

  local is_array = (#value > 0)
  local parts = {"{"}
  if is_array then
    for index, item in ipairs(value) do
      parts[#parts + 1] = ("\n%s%s,"):format(next_indent, serialize_value(item, next_indent))
    end
  else
    for _, key in ipairs(sorted_keys(value)) do
      local key_text = is_identifier(key) and key or ("[" .. quote_string(tostring(key)) .. "]")
      parts[#parts + 1] = ("\n%s%s = %s,"):format(next_indent, key_text, serialize_value(value[key], next_indent))
    end
  end
  if #parts > 1 then
    parts[#parts + 1] = "\n" .. indent
  end
  parts[#parts + 1] = "}"
  return table.concat(parts)
end

function M.serialize(book)
  book = M.canonicalize(book)
  local lines = {"return {"}
  for _, key in ipairs(TOP_LEVEL_ORDER) do
    lines[#lines + 1] = ("  %s = %s,"):format(key, serialize_value(book[key], "  "))
  end
  lines[#lines + 1] = "}"
  lines[#lines + 1] = ""
  return table.concat(lines, "\n")
end

function M.load(path)
  local chunk, load_error = loadfile(path)
  if not chunk then
    return nil, load_error
  end
  local ok, book = pcall(chunk)
  if not ok then
    return nil, book
  end
  if type(book) ~= "table" then
    return nil, "route book must return a table"
  end
  return M.canonicalize(book)
end

function M.save(path, book)
  local handle, open_error = io.open(path, "w")
  if not handle then
    return nil, open_error
  end
  handle:write(M.serialize(book))
  handle:close()
  return true
end

return M
