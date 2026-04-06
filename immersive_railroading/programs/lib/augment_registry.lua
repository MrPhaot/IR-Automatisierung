local M = {}

local function copy_table(value)
  local out = {}
  for key, item in pairs(value or {}) do
    out[key] = item
  end
  return out
end

local function sort_keys(source)
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

function M.normalize(book)
  book = book or {}
  book.AUGMENTS = book.AUGMENTS or {}
  book.AUGMENTS.DETECTORS = book.AUGMENTS.DETECTORS or {}
  return book
end

function M.list(book)
  local detectors = M.normalize(book).AUGMENTS.DETECTORS
  local items = {}
  for id, detector in pairs(detectors) do
    items[#items + 1] = {
      id = id,
      address = detector.address,
      label = detector.label or id,
      sort_order = detector.sort_order or math.huge,
    }
  end
  table.sort(items, function(a, b)
    if a.sort_order ~= b.sort_order then
      return a.sort_order < b.sort_order
    end
    return a.id < b.id
  end)
  return items
end

function M.address_index(book)
  local index = {}
  local detectors = M.normalize(book).AUGMENTS.DETECTORS
  for id, detector in pairs(detectors) do
    if detector.address then
      index[detector.address] = id
    end
  end
  return index
end

function M.bound_station_index(book)
  local stations = (book and book.STATIONS) or {}
  local index = {}
  for station_id, station in pairs(stations) do
    for _, detector_id in ipairs(station.detector_ids or {}) do
      index[detector_id] = station_id
    end
  end
  return index
end

function M.scan(component_api)
  local discovered = {}
  if not component_api or type(component_api.list) ~= "function" then
    return discovered
  end
  for address, kind in component_api.list("ir_augment_detector") do
    discovered[#discovered + 1] = {
      address = address,
      kind = kind,
    }
  end
  table.sort(discovered, function(a, b)
    return a.address < b.address
  end)
  return discovered
end

function M.merge_scan(book, discovered)
  book = M.normalize(book)
  local detectors = book.AUGMENTS.DETECTORS
  local by_address = M.address_index(book)
  local next_sort = #M.list(book) * 10 + 10
  local changed = false

  for _, item in ipairs(discovered or {}) do
    local detector_id = by_address[item.address]
    if not detector_id then
      detector_id = ("detector_%02d"):format(#M.list(book) + 1)
      while detectors[detector_id] do
        detector_id = detector_id .. "_x"
      end
      detectors[detector_id] = {
        address = item.address,
        label = detector_id,
        sort_order = next_sort,
      }
      next_sort = next_sort + 10
      changed = true
    end
  end

  return changed, book
end

function M.validate(book)
  local errors = {}
  local warnings = {}
  book = M.normalize(book)
  local detectors = book.AUGMENTS.DETECTORS
  local seen_address = {}
  local station_index = {}

  for detector_id in ipairs(sort_keys(detectors)) do
  end

  for detector_id, detector in pairs(detectors) do
    if type(detector) ~= "table" then
      errors[#errors + 1] = ("AUGMENTS.DETECTORS.%s must be a table"):format(detector_id)
    else
      if type(detector.address) ~= "string" or detector.address == "" then
        errors[#errors + 1] = ("AUGMENTS.DETECTORS.%s.address must be a non-empty string"):format(detector_id)
      elseif seen_address[detector.address] then
        errors[#errors + 1] = ("detector address %s is duplicated by %s and %s"):format(
          detector.address,
          seen_address[detector.address],
          detector_id
        )
      else
        seen_address[detector.address] = detector_id
      end
    end
  end

  for station_id, station in pairs(book.STATIONS or {}) do
    for _, detector_id in ipairs(station.detector_ids or {}) do
      if not detectors[detector_id] then
        errors[#errors + 1] = ("station %s references unknown detector_id %s"):format(station_id, detector_id)
      elseif station_index[detector_id] then
        errors[#errors + 1] = ("detector %s is assigned to both station %s and %s"):format(
          detector_id,
          station_index[detector_id],
          station_id
        )
      else
        station_index[detector_id] = station_id
      end
    end
  end

  if next(seen_address) == nil then
    warnings[#warnings + 1] = "no detectors registered"
  end

  return {
    ok = #errors == 0,
    errors = errors,
    warnings = warnings,
    station_index = station_index,
  }
end

function M.inspect_runtime(component_api, book)
  local results = {}
  local detector_map = M.normalize(book).AUGMENTS.DETECTORS
  local bound_station = M.bound_station_index(book)
  local by_address = M.address_index(book)

  for _, item in ipairs(M.scan(component_api)) do
    local detector_id = by_address[item.address]
    local detector = detector_id and detector_map[detector_id] or nil
    results[#results + 1] = {
      detector_id = detector_id,
      label = detector and (detector.label or detector_id) or nil,
      address = item.address,
      station_id = detector_id and bound_station[detector_id] or nil,
    }
  end

  return results
end

return M
