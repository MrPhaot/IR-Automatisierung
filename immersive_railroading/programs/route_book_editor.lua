local mode = ...

local function split_path(path)
  local directory, name = path:match("^(.*)/([^/]+)$")
  if directory then
    return directory, name
  end
  return ".", path
end

local function script_source_path()
  local source = debug.getinfo(1, "S").source
  if type(source) == "string" and source:sub(1, 1) == "@" then
    return source:sub(2)
  end
  return "route_book_editor.lua"
end

local function join_paths(base, child)
  if base == "." or base == "" then
    return child
  end
  if base:sub(-1) == "/" then
    return base .. child
  end
  return base .. "/" .. child
end

local function ensure_package_path(base)
  if not package or not package.path then
    return
  end
  local patterns = {
    join_paths(base, "?.lua"),
    join_paths(base, "lib/?.lua"),
  }
  for _, pattern in ipairs(patterns) do
    if not package.path:find(pattern, 1, true) then
      package.path = pattern .. ";" .. package.path
    end
  end
end

local function safe_require(name)
  local ok, value = pcall(require, name)
  if ok then
    return value
  end
  return nil
end

local function fresh_require(name)
  if package and package.loaded then
    package.loaded[name] = nil
  end
  return require(name)
end

local SCRIPT_DIR = split_path(script_source_path())
ensure_package_path(SCRIPT_DIR)

local component = safe_require("component")
local event = safe_require("event")
local term = safe_require("term")
local tty = safe_require("tty")
local unicode = safe_require("unicode")
local keyboard = safe_require("keyboard")

local route_book_store = fresh_require("lib.route_book_store")
local augment_registry = fresh_require("lib.augment_registry")
local oc_proxy = fresh_require("lib.oc_proxy")
local term_ui = fresh_require("lib.term_ui")

local dispatcher_chunk = assert(loadfile(join_paths(SCRIPT_DIR, "station_dispatch.lua")))
local station_dispatch = dispatcher_chunk("__module__")

local TABS_COMFORT = {"Detectors", "Stations", "Routes", "Schedules", "Save / Validate"}
local TABS_COMPACT = {"Det", "Sta", "Rou", "Sch", "Save"}

local KEY = {
  backspace = 14,
  enter = 28,
  tab = 15,
  esc = 1,
  left = 203,
  right = 205,
  home = 199,
  ["end"] = 207,
  delete = 211,
  c = 46,
  v = 47,
}

local function clamp(n, low, high)
  if n < low then
    return low
  end
  if n > high then
    return high
  end
  return n
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

local function route_book_path()
  return join_paths(SCRIPT_DIR, "route_book.lua")
end

local function load_book()
  local book, err = route_book_store.load(route_book_path())
  if not book then
    return route_book_store.new_book(), err
  end
  return book
end

local function new_state()
  local book, load_error = load_book()
  return {
    book = book,
    dirty = false,
    active_tab = 1,
    selections = {
      detectors = 1,
      stations = 1,
      routes = 1,
      schedules = 1,
    },
    message = load_error and ("load fallback: " .. tostring(load_error)) or "Ready",
    modal = nil,
    editor_clipboard = "",
  }
end

local function detector_items(book)
  local items = {}
  for _, item in ipairs(augment_registry.list(book)) do
    items[#items + 1] = {
      id = item.id,
      label = item.label,
      detail = item.address,
    }
  end
  return items
end

local function station_items(book)
  local items = {}
  for _, id in ipairs(sorted_keys(book.STATIONS)) do
    local station = book.STATIONS[id]
    items[#items + 1] = {
      id = id,
      label = ("%s  %s"):format(id, station.display_name or id),
    }
  end
  return items
end

local function route_items(book)
  local items = {}
  for _, id in ipairs(sorted_keys(book.ROUTES)) do
    items[#items + 1] = {id = id, label = id}
  end
  return items
end

local function schedule_items(book)
  local items = {}
  for _, id in ipairs(sorted_keys(book.SCHEDULES)) do
    items[#items + 1] = {id = id, label = id}
  end
  return items
end

local function selected_from(items, index)
  if #items == 0 then
    return nil, 0
  end
  index = math.max(1, math.min(index or 1, #items))
  return items[index], index
end

local function current_detector_id(state)
  local items = detector_items(state.book)
  local selected = select(1, selected_from(items, state.selections.detectors))
  return selected and selected.id or nil
end

local function current_station_id(state)
  local items = station_items(state.book)
  local selected = select(1, selected_from(items, state.selections.stations))
  return selected and selected.id or nil
end

local function current_route_id(state)
  local items = route_items(state.book)
  local selected = select(1, selected_from(items, state.selections.routes))
  return selected and selected.id or nil
end

local function current_schedule_id(state)
  local items = schedule_items(state.book)
  local selected = select(1, selected_from(items, state.selections.schedules))
  return selected and selected.id or nil
end

local function parse_waypoints(raw)
  local waypoints = {}
  for token in tostring(raw or ""):gmatch("[^;]+") do
    local trimmed = token:gsub("^%s+", ""):gsub("%s+$", "")
    local x, y, z = trimmed:match("^([^,]+),([^,]+),([^,]+)$")
    if x and y and z then
      waypoints[#waypoints + 1] = {
        x = tonumber(x),
        y = tonumber(y),
        z = tonumber(z),
      }
    elseif trimmed ~= "" then
      waypoints[#waypoints + 1] = trimmed
    end
  end
  return waypoints
end

local function is_valid_target(target)
  if type(term_ui.is_valid_target) == "function" then
    return term_ui.is_valid_target(target)
  end
  return type(target) == "table"
    and type(target.x) == "number"
    and type(target.y) == "number"
    and type(target.width) == "number"
    and type(target.height) == "number"
    and target.width > 0
    and target.height > 0
end

local function add_targets(targets, incoming, extra)
  for _, target in ipairs(incoming or {}) do
    if extra then
      for key, value in pairs(extra) do
        target[key] = value
      end
    end
    if is_valid_target(target) then
      targets[#targets + 1] = target
    end
  end
end

local function rect(x, y, width, height, title)
  return {
    x = x,
    y = y,
    width = width,
    height = height,
    title = title,
  }
end

local function layout_for(width, height)
  local tier
  if width < 54 or height < 18 then
    tier = "minimum"
  elseif width < 100 or height < 30 then
    tier = "compact"
  else
    tier = "comfort"
  end

  local layout = {
    tier = tier,
    width = width,
    height = height,
    tabs = tier == "comfort" and TABS_COMFORT or TABS_COMPACT,
    status_y = height - 1,
    button_rows = tier == "compact" and 2 or 1,
    button_y = tier == "compact" and (height - 4) or (height - 2),
  }

  if tier == "minimum" then
    return layout
  end

  local content_top = 4
  local content_bottom = layout.button_y - 2
  local content_height = math.max(content_bottom - content_top + 1, 3)
  layout.content_top = content_top
  layout.content_height = content_height

  if tier == "comfort" then
    layout.left = rect(3, content_top, 36, content_height)
    layout.right = rect(41, content_top, math.max(width - 43, 10), content_height)
    layout.schedule_list = rect(3, content_top, 24, content_height)
    layout.schedule_entries = rect(29, content_top, 30, content_height)
    layout.schedule_wait = rect(61, content_top, math.max(width - 63, 10), content_height)
    layout.save = rect(3, content_top, math.max(width - 4, 10), content_height)
  else
    local inner_width = math.max(width - 4, 10)
    local list_height = math.max(math.floor(content_height / 2), 4)
    local detail_height = math.max(content_height - list_height - 1, 4)
    layout.primary_list = rect(3, content_top, inner_width, list_height)
    layout.primary_detail = rect(3, content_top + list_height + 1, inner_width, detail_height)

    local third = math.max(math.floor(content_height / 3), 3)
    layout.schedule_list = rect(3, content_top, inner_width, third)
    layout.schedule_entries = rect(3, content_top + third + 1, inner_width, third)
    layout.schedule_wait = rect(3, content_top + third * 2 + 2, inner_width, math.max(content_height - third * 2 - 2, 3))
    layout.save = rect(3, content_top, inner_width, content_height)
  end

  return layout
end

local function make_action_buttons(layout)
  local specs = {
    {"add", "Add"},
    {"edit", "Edit"},
    {"delete", "Delete"},
    {"move_up", "Move Up"},
    {"move_down", "Move Down"},
  }
  local buttons = {}
  if layout.tier == "compact" then
    local positions = {
      {3, layout.button_y},
      {16, layout.button_y},
      {29, layout.button_y},
      {3, layout.button_y + 1},
      {18, layout.button_y + 1},
    }
    for index, spec in ipairs(specs) do
      buttons[#buttons + 1] = term_ui.button(spec[1], spec[2], positions[index][1], positions[index][2], math.max(#spec[2] + 4, 10))
    end
  else
    local x = 3
    for _, spec in ipairs(specs) do
      local width = math.max(#spec[2] + 4, 10)
      buttons[#buttons + 1] = term_ui.button(spec[1], spec[2], x, layout.button_y, width)
      x = x + width + 2
    end
  end
  return buttons
end

local function render_text(buffer, x, y, text, width)
  buffer[#buffer + 1] = {
    x = x,
    y = y,
    text = width and term_ui.fit_text(text, width) or tostring(text),
  }
end

local function normalize_clipboard_text(text)
  text = tostring(text or ""):gsub("\r\n", "\n"):gsub("\r", "\n"):gsub("\n", " ")
  return text
end

local function modal_field_visible_value(field, available)
  local prefix = tostring(field.label or "") .. ": "
  local raw_value = tostring(field.value or "")
  local cursor = clamp(field.cursor or (#raw_value + 1), 1, #raw_value + 1)
  local viewport = math.max(available - #prefix - 2, 1)
  local scroll_x = clamp(field.scroll_x or 0, 0, math.max(#raw_value - viewport, 0))
  if cursor - 1 < scroll_x then
    scroll_x = cursor - 1
  elseif cursor - 1 > scroll_x + viewport then
    scroll_x = cursor - 1 - viewport
  end
  field.scroll_x = math.max(scroll_x, 0)

  local display = raw_value:sub(field.scroll_x + 1, field.scroll_x + viewport)
  local cursor_index = clamp(cursor - field.scroll_x, 1, viewport + 1)
  display = display:sub(1, cursor_index - 1) .. "|" .. display:sub(cursor_index)
  return prefix .. display
end

local function render_modal(buffer, targets, layout, modal)
  if not modal then
    return
  end

  local width = math.max(math.min(layout.width - 6, 56), 26)
  local height = math.max(#modal.fields + 7, 10)
  local x = math.max(math.floor((layout.width - width) / 2) + 1, 2)
  local y = math.max(math.floor((layout.height - height) / 2) + 1, 2)

  term_ui.render_box(buffer, term_ui.box(x, y, width, height, modal.title or "Dialog"))
  for index, field in ipairs(modal.fields) do
    local row_y = y + 1 + index
    local prefix = index == modal.active_index and ">" or " "
    render_text(buffer, x + 2, row_y, prefix .. modal_field_visible_value(field, width - 4), width - 4)
    local target = {
      id = "modal:field:" .. index,
      x = x + 1,
      y = row_y,
      width = width - 2,
      height = 1,
      modal_field_index = index,
    }
    if is_valid_target(target) then
      targets[#targets + 1] = target
    end
  end

  local confirm = term_ui.button("modal:confirm", "Confirm", x + 2, y + height - 2, 12)
  local cancel = term_ui.button("modal:cancel", "Cancel", x + 16, y + height - 2, 10)
  add_targets(targets, term_ui.render_buttons(buffer, {confirm, cancel}))
end

local function open_modal(state, spec)
  local fields = {}
  for _, field in ipairs(spec.fields or {}) do
    local value = tostring(field.value or "")
    fields[#fields + 1] = {
      key = field.key,
      label = field.label,
      value = value,
      cursor = #value + 1,
      scroll_x = 0,
    }
  end
  state.modal = {
    title = spec.title,
    fields = fields,
    active_index = 1,
    on_submit = spec.on_submit,
  }
end

local function close_modal(state, message)
  state.modal = nil
  if message then
    state.message = message
  end
end

local function submit_modal(state)
  if not state.modal then
    return false
  end
  local values = {}
  for _, field in ipairs(state.modal.fields) do
    values[field.key] = field.value
  end
  local ok, message = state.modal.on_submit(state, values)
  close_modal(state, message or (ok and "Saved" or "Canceled"))
  return ok ~= false
end

local function move_detector(state, step)
  local detectors = augment_registry.list(state.book)
  local selected_id = current_detector_id(state)
  local current_index
  for index, item in ipairs(detectors) do
    if item.id == selected_id then
      current_index = index
      break
    end
  end
  if not current_index then
    return false
  end
  local swap_index = current_index + step
  if not detectors[swap_index] then
    return false
  end
  local current = state.book.AUGMENTS.DETECTORS[detectors[current_index].id]
  local other = state.book.AUGMENTS.DETECTORS[detectors[swap_index].id]
  current.sort_order, other.sort_order = other.sort_order, current.sort_order
  state.dirty = true
  state.message = "Detector order updated"
  return true
end

local function save_route_book(state)
  local ok, err = route_book_store.save(route_book_path(), state.book)
  if ok then
    state.dirty = false
    state.message = "route_book.lua saved"
    return true
  end
  state.message = tostring(err)
  return false
end

local function validate_route_book(state)
  local validation = station_dispatch.validate_route_book(state.book)
  state.message = validation.ok and "Validation OK" or ("Validation errors: " .. #validation.errors)
  return validation.ok
end

local function open_action_modal(state, action)
  if state.active_tab == 1 then
    if action == "add" then
      open_modal(state, {
        title = "Add Detector",
        fields = {
          {key = "id", label = "Detector ID"},
          {key = "label", label = "Label"},
          {key = "address", label = "Address"},
        },
        on_submit = function(current_state, values)
          if values.id == "" then
            return false, "Detector ID required"
          end
          current_state.book.AUGMENTS.DETECTORS[values.id] = {
            address = values.address,
            label = values.label ~= "" and values.label or values.id,
            sort_order = #augment_registry.list(current_state.book) * 10 + 10,
          }
          current_state.dirty = true
          return true, "Detector added"
        end,
      })
      return true
    end

    local id = current_detector_id(state)
    local detector = id and state.book.AUGMENTS.DETECTORS[id]
    if action == "edit" and detector then
      open_modal(state, {
        title = "Edit Detector",
        fields = {
          {key = "label", label = "Label", value = detector.label or id},
          {key = "address", label = "Address", value = detector.address or ""},
        },
        on_submit = function(current_state, values)
          detector.label = values.label ~= "" and values.label or id
          detector.address = values.address
          current_state.dirty = true
          return true, "Detector updated"
        end,
      })
      return true
    elseif action == "delete" and id then
      state.book.AUGMENTS.DETECTORS[id] = nil
      state.dirty = true
      state.message = "Detector deleted"
      return true
    elseif action == "move_up" then
      return move_detector(state, -1)
    elseif action == "move_down" then
      return move_detector(state, 1)
    end
  elseif state.active_tab == 2 then
    if action == "add" then
      open_modal(state, {
        title = "Add Station",
        fields = {
          {key = "id", label = "Station ID"},
          {key = "name", label = "Name"},
          {key = "x", label = "X", value = "0"},
          {key = "y", label = "Y", value = "64"},
          {key = "z", label = "Z", value = "0"},
          {key = "detector_ids", label = "Detector IDs", value = ""},
        },
        on_submit = function(current_state, values)
          if values.id == "" then
            return false, "Station ID required"
          end
          current_state.book.STATIONS[values.id] = {
            display_name = values.name ~= "" and values.name or values.id,
            x = tonumber(values.x) or 0,
            y = tonumber(values.y) or 64,
            z = tonumber(values.z) or 0,
            detector_ids = parse_waypoints(values.detector_ids),
            redstone_outputs = {},
          }
          current_state.dirty = true
          return true, "Station added"
        end,
      })
      return true
    end

    local id = current_station_id(state)
    local station = id and state.book.STATIONS[id]
    if action == "edit" and station then
      open_modal(state, {
        title = "Edit Station",
        fields = {
          {key = "name", label = "Name", value = station.display_name or id},
          {key = "x", label = "X", value = tostring(station.x or 0)},
          {key = "y", label = "Y", value = tostring(station.y or 64)},
          {key = "z", label = "Z", value = tostring(station.z or 0)},
          {key = "detector_ids", label = "Detector IDs", value = table.concat(station.detector_ids or {}, ";")},
        },
        on_submit = function(current_state, values)
          station.display_name = values.name ~= "" and values.name or id
          station.x = tonumber(values.x) or station.x or 0
          station.y = tonumber(values.y) or station.y or 64
          station.z = tonumber(values.z) or station.z or 0
          station.detector_ids = parse_waypoints(values.detector_ids)
          current_state.dirty = true
          return true, "Station updated"
        end,
      })
      return true
    elseif action == "delete" and id then
      state.book.STATIONS[id] = nil
      state.dirty = true
      state.message = "Station deleted"
      return true
    end
  elseif state.active_tab == 3 then
    if action == "add" then
      open_modal(state, {
        title = "Add Route",
        fields = {
          {key = "id", label = "Route ID"},
          {key = "waypoints", label = "Waypoints"},
          {key = "cruise_kmh", label = "Cruise km/h", value = "40"},
          {key = "stop_buffer_m", label = "Stop buffer", value = "2"},
          {key = "profile", label = "Profile", value = "conservative"},
        },
        on_submit = function(current_state, values)
          if values.id == "" then
            return false, "Route ID required"
          end
          current_state.book.ROUTES[values.id] = {
            waypoints = parse_waypoints(values.waypoints),
            cruise_kmh = tonumber(values.cruise_kmh) or 40,
            stop_buffer_m = tonumber(values.stop_buffer_m) or 2,
            profile = values.profile ~= "" and values.profile or "conservative",
          }
          current_state.dirty = true
          return true, "Route added"
        end,
      })
      return true
    end

    local id = current_route_id(state)
    local route = id and state.book.ROUTES[id]
    if action == "edit" and route then
      local waypoint_text = {}
      for _, waypoint in ipairs(route.waypoints or {}) do
        if type(waypoint) == "string" then
          waypoint_text[#waypoint_text + 1] = waypoint
        else
          waypoint_text[#waypoint_text + 1] = ("%s,%s,%s"):format(waypoint.x, waypoint.y, waypoint.z)
        end
      end
      open_modal(state, {
        title = "Edit Route",
        fields = {
          {key = "waypoints", label = "Waypoints", value = table.concat(waypoint_text, ";")},
          {key = "cruise_kmh", label = "Cruise km/h", value = tostring(route.cruise_kmh or 40)},
          {key = "stop_buffer_m", label = "Stop buffer", value = tostring(route.stop_buffer_m or 2)},
          {key = "profile", label = "Profile", value = route.profile or "conservative"},
        },
        on_submit = function(current_state, values)
          route.waypoints = parse_waypoints(values.waypoints)
          route.cruise_kmh = tonumber(values.cruise_kmh) or route.cruise_kmh or 40
          route.stop_buffer_m = tonumber(values.stop_buffer_m) or route.stop_buffer_m or 2
          route.profile = values.profile ~= "" and values.profile or route.profile or "conservative"
          current_state.dirty = true
          return true, "Route updated"
        end,
      })
      return true
    elseif action == "delete" and id then
      state.book.ROUTES[id] = nil
      state.dirty = true
      state.message = "Route deleted"
      return true
    end
  elseif state.active_tab == 4 then
    if action == "add" then
      open_modal(state, {
        title = "Add Schedule",
        fields = {
          {key = "id", label = "Schedule ID"},
          {key = "route", label = "First Route"},
          {key = "seconds", label = "Wait Seconds", value = "0"},
          {key = "cyclic", label = "Cyclic", value = "false"},
        },
        on_submit = function(current_state, values)
          if values.id == "" then
            return false, "Schedule ID required"
          end
          current_state.book.SCHEDULES[values.id] = {
            cyclic = values.cyclic == "true",
            entries = values.route ~= "" and {
              {
                route = values.route,
                wait = {
                  groups = {
                    {
                      {
                        type = "time_passed",
                        seconds = tonumber(values.seconds) or 0,
                      },
                    },
                  },
                },
              },
            } or {},
          }
          current_state.dirty = true
          return true, "Schedule added"
        end,
      })
      return true
    end

    local id = current_schedule_id(state)
    local schedule = id and state.book.SCHEDULES[id]
    if action == "edit" and schedule then
      open_modal(state, {
        title = "Edit Schedule",
        fields = {
          {key = "route", label = "First Route", value = (schedule.entries[1] and schedule.entries[1].route) or ""},
          {key = "seconds", label = "Wait Seconds", value = tostring(schedule.entries[1] and schedule.entries[1].wait and schedule.entries[1].wait.groups and schedule.entries[1].wait.groups[1] and schedule.entries[1].wait.groups[1][1] and schedule.entries[1].wait.groups[1][1].seconds or 0)},
          {key = "cyclic", label = "Cyclic", value = tostring(schedule.cyclic == true)},
        },
        on_submit = function(current_state, values)
          schedule.cyclic = values.cyclic == "true"
          if values.route ~= "" then
            schedule.entries[1] = {
              route = values.route,
              wait = {
                groups = {
                  {
                    {
                      type = "time_passed",
                      seconds = tonumber(values.seconds) or 0,
                    },
                  },
                },
              },
            }
          end
          current_state.dirty = true
          return true, "Schedule updated"
        end,
      })
      return true
    elseif action == "delete" and id then
      state.book.SCHEDULES[id] = nil
      state.dirty = true
      state.message = "Schedule deleted"
      return true
    end
  else
    if action == "add" then
      return save_route_book(state)
    elseif action == "edit" then
      return validate_route_book(state)
    end
  end

  return false
end

local function render_minimum_screen(buffer, layout)
  term_ui.render_box(buffer, term_ui.box(1, 1, layout.width, layout.height, "IR Schedule Editor"))
  render_text(buffer, 3, 4, "Screen too small for the editor.", math.max(layout.width - 4, 1))
  render_text(buffer, 3, 6, "Need at least 54x18.", math.max(layout.width - 4, 1))
  render_text(buffer, 3, 8, ("Current: %dx%d"):format(layout.width, layout.height), math.max(layout.width - 4, 1))
end

local function render_primary_split(buffer, targets, list_rect, detail_rect, title, items, selected_index, area, detail_lines)
  term_ui.render_box(buffer, term_ui.box(list_rect.x, list_rect.y, list_rect.width, list_rect.height, title))
  add_targets(targets, term_ui.render_list(buffer, list_rect.x + 2, list_rect.y + 2, list_rect.width - 4, items, selected_index, math.max(list_rect.height - 4, 1)), {area = area})
  term_ui.render_box(buffer, term_ui.box(detail_rect.x, detail_rect.y, detail_rect.width, detail_rect.height, title .. " Details"))
  for index, line in ipairs(detail_lines or {}) do
    render_text(buffer, detail_rect.x + 2, detail_rect.y + 1 + index, line, detail_rect.width - 4)
  end
end

local function build_screen(state, width, height)
  width = math.max(width or 100, 1)
  height = math.max(height or 32, 1)
  local layout = layout_for(width, height)
  local buffer = {}
  local targets = {}

  if layout.tier == "minimum" then
    render_minimum_screen(buffer, layout)
    if state.modal then
      render_modal(buffer, targets, layout, state.modal)
    end
    return {
      buffer = buffer,
      targets = targets,
      layout = layout,
    }
  end

  term_ui.render_box(buffer, term_ui.box(1, 1, width, height, "IR Schedule Editor"))
  add_targets(targets, term_ui.render_tabs(buffer, layout.tabs, state.active_tab, 3, 2))

  if state.active_tab == 1 then
    local items = detector_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.detectors)
    local detail_lines = {}
    if selected then
      local detector = state.book.AUGMENTS.DETECTORS[selected.id]
      detail_lines = {
        "ID: " .. selected.id,
        "Label: " .. tostring(detector.label or selected.id),
        "Address: " .. tostring(detector.address or ""),
      }
    end
    if layout.tier == "comfort" then
      render_primary_split(buffer, targets, layout.left, layout.right, "Known Detectors", items, selected_index, "detectors", detail_lines)
    else
      render_primary_split(buffer, targets, layout.primary_list, layout.primary_detail, "Detectors", items, selected_index, "detectors", detail_lines)
    end
  elseif state.active_tab == 2 then
    local items = station_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.stations)
    local detail_lines = {}
    if selected then
      local station = state.book.STATIONS[selected.id]
      detail_lines = {
        ("ID: %s"):format(selected.id),
        ("Name: %s"):format(station.display_name or selected.id),
        ("Pos: %s, %s, %s"):format(station.x, station.y, station.z),
        "Detectors:",
      }
      for _, detector_id in ipairs(station.detector_ids or {}) do
        detail_lines[#detail_lines + 1] = "  " .. detector_id
      end
    end
    if layout.tier == "comfort" then
      render_primary_split(buffer, targets, layout.left, layout.right, "Stations", items, selected_index, "stations", detail_lines)
    else
      render_primary_split(buffer, targets, layout.primary_list, layout.primary_detail, "Stations", items, selected_index, "stations", detail_lines)
    end
  elseif state.active_tab == 3 then
    local items = route_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.routes)
    local detail_lines = {}
    if selected then
      local route = state.book.ROUTES[selected.id]
      detail_lines = {
        ("Route: %s"):format(selected.id),
        ("Profile: %s"):format(route.profile or "conservative"),
      }
      for index, waypoint in ipairs(route.waypoints or {}) do
        local waypoint_text = type(waypoint) == "string" and waypoint or ("%s,%s,%s"):format(waypoint.x, waypoint.y, waypoint.z)
        detail_lines[#detail_lines + 1] = ("[%d] %s"):format(index, waypoint_text)
      end
    end
    if layout.tier == "comfort" then
      render_primary_split(buffer, targets, layout.left, layout.right, "Routes", items, selected_index, "routes", detail_lines)
    else
      render_primary_split(buffer, targets, layout.primary_list, layout.primary_detail, "Routes", items, selected_index, "routes", detail_lines)
    end
  elseif state.active_tab == 4 then
    local items = schedule_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.schedules)
    term_ui.render_box(buffer, term_ui.box(layout.schedule_list.x, layout.schedule_list.y, layout.schedule_list.width, layout.schedule_list.height, "Schedules"))
    add_targets(targets, term_ui.render_list(buffer, layout.schedule_list.x + 2, layout.schedule_list.y + 2, layout.schedule_list.width - 4, items, selected_index, math.max(layout.schedule_list.height - 4, 1)), {area = "schedules"})
    term_ui.render_box(buffer, term_ui.box(layout.schedule_entries.x, layout.schedule_entries.y, layout.schedule_entries.width, layout.schedule_entries.height, "Entries"))
    term_ui.render_box(buffer, term_ui.box(layout.schedule_wait.x, layout.schedule_wait.y, layout.schedule_wait.width, layout.schedule_wait.height, "Wait Conditions"))
    if selected then
      local schedule = state.book.SCHEDULES[selected.id]
      for index, entry in ipairs(schedule.entries or {}) do
        render_text(buffer, layout.schedule_entries.x + 2, layout.schedule_entries.y + 1 + index, ("[%d] %s"):format(index, entry.route), layout.schedule_entries.width - 4)
      end
      local first_entry = schedule.entries and schedule.entries[1]
      if first_entry and first_entry.wait then
        for group_index, group in ipairs(first_entry.wait.groups or {}) do
          local first_condition = group[1]
          render_text(buffer, layout.schedule_wait.x + 2, layout.schedule_wait.y + group_index * 2, ("Group %s"):format(string.char(64 + group_index)), layout.schedule_wait.width - 4)
          if first_condition then
            render_text(buffer, layout.schedule_wait.x + 2, layout.schedule_wait.y + group_index * 2 + 1, ("%s %s %s"):format(first_condition.type, tostring(first_condition.comparator or ">="), tostring(first_condition.value or first_condition.seconds)), layout.schedule_wait.width - 4)
          end
        end
      end
    end
  else
    term_ui.render_box(buffer, term_ui.box(layout.save.x, layout.save.y, layout.save.width, layout.save.height, "Save / Validate"))
    local validation = station_dispatch.validate_route_book(state.book)
    render_text(buffer, layout.save.x + 2, layout.save.y + 2, ("Dirty: %s"):format(state.dirty and "[*]" or "[ ]"), layout.save.width - 4)
    render_text(buffer, layout.save.x + 2, layout.save.y + 3, ("Validation: %s"):format(validation.ok and "OK" or "Errors"), layout.save.width - 4)
    for index, message in ipairs(validation.errors or {}) do
      render_text(buffer, layout.save.x + 2, layout.save.y + 3 + index, "ERROR: " .. message, layout.save.width - 4)
    end
  end

  add_targets(targets, term_ui.render_buttons(buffer, make_action_buttons(layout)))
  render_text(buffer, 3, layout.status_y, state.message or "", math.max(width - 4, 1))

  if state.modal then
    render_modal(buffer, targets, layout, state.modal)
  end

  return {
    buffer = buffer,
    targets = targets,
    layout = layout,
  }
end

local function handle_click(state, x, y, screen)
  if type(x) ~= "number" or type(y) ~= "number" or type(screen) ~= "table" or type(screen.targets) ~= "table" then
    return false
  end

  for _, target in ipairs(screen.targets) do
    if term_ui.hit(target, x, y) then
      if state.modal then
        if target.modal_field_index then
          state.modal.active_index = target.modal_field_index
          return true
        end
        if target.id == "modal:confirm" then
          submit_modal(state)
          return true
        end
        if target.id == "modal:cancel" then
          close_modal(state, "Canceled")
          return true
        end
        return false
      end

      if target.tab_index then
        state.active_tab = target.tab_index
        return true
      end
      if target.area then
        state.selections[target.area] = target.index
        return true
      end
      if target.id then
        return open_action_modal(state, target.id)
      end
    end
  end

  return false
end

local function current_list_area(state)
  if state.active_tab == 1 then
    return "detectors", #detector_items(state.book)
  end
  if state.active_tab == 2 then
    return "stations", #station_items(state.book)
  end
  if state.active_tab == 3 then
    return "routes", #route_items(state.book)
  end
  if state.active_tab == 4 then
    return "schedules", #schedule_items(state.book)
  end
  return nil, 0
end

local function handle_scroll(state, direction)
  if state.modal then
    return false
  end
  local area, count = current_list_area(state)
  if not area or count == 0 then
    return false
  end
  local current = state.selections[area] or 1
  state.selections[area] = clamp(current + direction, 1, count)
  return true
end

local function char_from_event(char_code)
  if type(char_code) ~= "number" or char_code <= 0 then
    return nil
  end
  if unicode and type(unicode.char) == "function" then
    return unicode.char(char_code)
  end
  if char_code <= 255 then
    return string.char(char_code)
  end
  return nil
end

local function current_modal_field(state)
  local modal = state.modal
  if not modal then
    return nil
  end
  return modal.fields[modal.active_index]
end

local function insert_into_field(field, text)
  text = tostring(text or "")
  local cursor = clamp(field.cursor or (#field.value + 1), 1, #field.value + 1)
  field.value = field.value:sub(1, cursor - 1) .. text .. field.value:sub(cursor)
  field.cursor = cursor + #text
end

local function delete_left(field)
  local cursor = clamp(field.cursor or (#field.value + 1), 1, #field.value + 1)
  if cursor <= 1 then
    return
  end
  field.value = field.value:sub(1, cursor - 2) .. field.value:sub(cursor)
  field.cursor = cursor - 1
end

local function delete_right(field)
  local cursor = clamp(field.cursor or (#field.value + 1), 1, #field.value + 1)
  if cursor > #field.value then
    return
  end
  field.value = field.value:sub(1, cursor - 1) .. field.value:sub(cursor + 1)
end

local function control_down()
  if keyboard and type(keyboard.isControlDown) == "function" then
    local ok, value = pcall(keyboard.isControlDown)
    return ok and value == true
  end
  return false
end

local function handle_clipboard(state, text)
  local field = current_modal_field(state)
  if not field then
    return false
  end
  insert_into_field(field, normalize_clipboard_text(text))
  return true
end

local function handle_key_down(state, char_code, key_code)
  local field = current_modal_field(state)
  if not field then
    return false
  end

  if control_down() and key_code == KEY.c then
    state.editor_clipboard = field.value
    state.message = "Field copied"
    return true
  end
  if control_down() and key_code == KEY.v then
    insert_into_field(field, normalize_clipboard_text(state.editor_clipboard))
    return true
  end

  if key_code == KEY.esc then
    close_modal(state, "Canceled")
    return true
  end
  if key_code == KEY.tab then
    state.modal.active_index = state.modal.active_index % #state.modal.fields + 1
    return true
  end
  if key_code == KEY.enter then
    if state.modal.active_index < #state.modal.fields then
      state.modal.active_index = state.modal.active_index + 1
      return true
    end
    submit_modal(state)
    return true
  end
  if key_code == KEY.left then
    field.cursor = clamp((field.cursor or 1) - 1, 1, #field.value + 1)
    return true
  end
  if key_code == KEY.right then
    field.cursor = clamp((field.cursor or 1) + 1, 1, #field.value + 1)
    return true
  end
  if key_code == KEY.home then
    field.cursor = 1
    return true
  end
  if key_code == KEY["end"] then
    field.cursor = #field.value + 1
    return true
  end
  if key_code == KEY.backspace then
    delete_left(field)
    return true
  end
  if key_code == KEY.delete then
    delete_right(field)
    return true
  end

  local char = char_from_event(char_code)
  if char and char >= " " then
    insert_into_field(field, char)
    return true
  end

  return false
end

local function call_api(target, method, ...)
  local ok, first, second, third, fourth, fifth, sixth = oc_proxy.invoke(component, target, method, ...)
  if ok then
    return first, second, third, fourth, fifth, sixth
  end
  return nil
end

local function parse_wh(a, b)
  if type(a) == "number" and type(b) == "number" then
    return math.floor(a), math.floor(b)
  end
  return nil, nil
end

local function parse_global_area(x, y, width, height)
  local origin_x, origin_y = parse_wh(x, y)
  local viewport_width, viewport_height = parse_wh(width, height)
  if origin_x and origin_y and viewport_width and viewport_height then
    return origin_x, origin_y, viewport_width, viewport_height
  end
  return nil, nil
end

local function read_member(target, key)
  return oc_proxy.read(target, key)
end

local function proxy_from_component(component_api, kind)
  if not component_api then
    return nil
  end

  if type(component_api.getPrimary) == "function" then
    local ok, primary = pcall(component_api.getPrimary, kind)
    if ok and primary ~= nil then
      return primary
    end
  end

  local value = read_member(component_api, kind)
  if value ~= nil and type(value) ~= "string" then
    return value
  end

  if type(component_api.proxy) == "function" and type(value) == "string" then
    local ok, proxy = pcall(component_api.proxy, value)
    if ok and proxy ~= nil then
      return proxy
    end
  end
  return nil
end

local function attempt_terminal_rebind(component_api, tty_api, diagnostics)
  diagnostics.rebind_attempted = "yes"
  diagnostics.rebind_ok = "no"
  diagnostics.tty_bind_before_gpu_bind = "no"
  diagnostics.tty_bind_after_gpu_bind = "no"
  diagnostics.gpu_bind_attempted = "no"
  diagnostics.gpu_bind_ok = "no"
  diagnostics.component_gpu = "no"
  diagnostics.component_screen = "no"
  diagnostics.gpu_bound_screen = diagnostics.gpu_bound_screen or "nil"

  if not component_api or type(component_api.isAvailable) ~= "function" then
    return nil, "no gpu component"
  end

  local has_gpu = component_api.isAvailable("gpu") == true
  diagnostics.component_gpu = has_gpu and "yes" or "no"
  if not has_gpu then
    return nil, "no gpu component"
  end

  local has_screen = component_api.isAvailable("screen") == true
  diagnostics.component_screen = has_screen and "yes" or "no"
  if not has_screen then
    return nil, "no screen component"
  end

  local gpu = proxy_from_component(component_api, "gpu")
  local screen = proxy_from_component(component_api, "screen")
  diagnostics.gpu_proxy_type = type(gpu)
  diagnostics.screen_proxy_type = type(screen)
  diagnostics.gpu_address = tostring(oc_proxy.address_of(gpu) or "nil")
  diagnostics.screen_address = tostring(oc_proxy.address_of(screen) or read_member(screen, "address") or "nil")
  diagnostics.gpu_has_bind = oc_proxy.can_invoke(component_api, gpu, "bind") and "yes" or "no"
  diagnostics.gpu_has_getScreen = oc_proxy.can_invoke(component_api, gpu, "getScreen") and "yes" or "no"
  if not gpu or diagnostics.gpu_has_getScreen == "no" or diagnostics.gpu_has_bind == "no" then
    return nil, "gpu invoke unavailable"
  end
  local screen_address = read_member(screen, "address")
  if not screen or type(screen_address) ~= "string" then
    if call_api(gpu, "getScreen") then
      screen = nil
    else
      return nil, "screen proxy unavailable"
    end
  end

  local current_screen = call_api(gpu, "getScreen")
  diagnostics.gpu_current_screen = tostring(current_screen or "nil")
  diagnostics.gpu_bound_screen = diagnostics.gpu_current_screen

  diagnostics.tty_bind_before_gpu_bind = "yes"
  local ok, bind_result = pcall(tty_api.bind, gpu)
  local rebound = call_api(tty_api, "gpu")
  diagnostics.invoke_getScreen_ok = diagnostics.gpu_has_getScreen
  diagnostics.tty_gpu_after = rebound and "yes" or "no"
  if ok and bind_result ~= false and rebound and oc_proxy.can_invoke(component_api, rebound, "set") then
    diagnostics.invoke_set_ok = "yes"
    diagnostics.rebind_ok = "yes"
    return rebound
  end

  if not current_screen then
    if not screen or type(screen_address) ~= "string" then
      return nil, "screen proxy unavailable"
    end
    diagnostics.gpu_bind_attempted = "yes"
    local bind_ok, gpu_bind_result = pcall(gpu.bind, screen_address)
    if not bind_ok or gpu_bind_result == false then
      return nil, "gpu has no screen and gpu bind failed"
    end
    diagnostics.gpu_bind_ok = "yes"
    diagnostics.invoke_bind_ok = "yes"
    diagnostics.gpu_bound_screen = tostring(call_api(gpu, "getScreen") or "nil")
  end

  diagnostics.tty_bind_after_gpu_bind = "yes"
  ok, bind_result = pcall(tty_api.bind, gpu)
  if not ok or bind_result == false then
    return nil, "tty bind failed"
  end

  rebound = call_api(tty_api, "gpu")
  diagnostics.tty_gpu_after = rebound and "yes" or "no"
  diagnostics.rebind_ok = rebound and "yes" or "no"
  diagnostics.invoke_set_ok = oc_proxy.can_invoke(component_api, rebound, "set") and "yes" or "no"
  if not rebound or diagnostics.invoke_set_ok ~= "yes" then
    return nil, "tty bind failed"
  end
  return rebound
end

local function resolve_terminal_context(term_api, tty_api, component_api)
  local diagnostics = {
    term_module = term_api ~= nil,
    tty_module = tty_api ~= nil,
    tty_available = "unknown",
    term_gpu = "no",
    tty_gpu = "no",
    tty_gpu_before = "no",
    tty_gpu_after = "no",
    rebind_attempted = "no",
    rebind_ok = "no",
    component_gpu = "unknown",
    component_screen = "unknown",
    gpu_bound_screen = "nil",
    gpu_current_screen = "nil",
    viewport = "unknown",
    origin = "unknown",
    raw_viewport = "unknown",
    tty_bind_before_gpu_bind = "no",
    tty_bind_after_gpu_bind = "no",
    gpu_bind_attempted = "no",
    gpu_bind_ok = "no",
    gpu_proxy_type = "nil",
    screen_proxy_type = "nil",
    gpu_has_bind = "no",
    gpu_has_getScreen = "no",
    gpu_address = "nil",
    screen_address = "nil",
    invoke_getScreen_ok = "no",
    invoke_bind_ok = "no",
    invoke_set_ok = "no",
  }

  if not tty_api then
    return nil, "tty unavailable", diagnostics
  end

  local tty_available = call_api(tty_api, "isAvailable")
  if tty_available ~= nil then
    diagnostics.tty_available = tty_available and "yes" or "no"
  end

  local term_gpu = call_api(term_api, "gpu")
  diagnostics.term_gpu = term_gpu and "yes" or "no"

  local gpu = call_api(tty_api, "gpu")
  diagnostics.tty_gpu_before = gpu and "yes" or "no"
  diagnostics.tty_gpu = diagnostics.tty_gpu_before
  diagnostics.invoke_set_ok = oc_proxy.can_invoke(component_api, gpu, "set") and "yes" or "no"
  diagnostics.invoke_getScreen_ok = oc_proxy.can_invoke(component_api, gpu, "getScreen") and "yes" or "no"
  diagnostics.gpu_address = tostring(oc_proxy.address_of(gpu) or "nil")
  if not gpu or diagnostics.invoke_set_ok ~= "yes" then
    local rebound, rebind_error = attempt_terminal_rebind(component_api, tty_api, diagnostics)
    if not rebound then
      diagnostics.tty_gpu_after = "no"
      return nil, rebind_error or "no bound terminal gpu", diagnostics
    end
    gpu = rebound
    diagnostics.tty_gpu = "yes"
  else
    diagnostics.tty_gpu_after = "yes"
  end

  local screen_address = call_api(gpu, "getScreen")
  if screen_address then
    diagnostics.gpu_bound_screen = tostring(screen_address)
  end

  local viewport_1, viewport_2, viewport_3, viewport_4, viewport_5, viewport_6 = call_api(tty_api, "getViewport")
  local viewport_width, viewport_height = parse_wh(viewport_1, viewport_2)
  local origin_x, origin_y = 1, 1
  local area_x, area_y, area_width, area_height = parse_global_area(call_api(term_api, "getGlobalArea"))
  if area_x and area_y then
    origin_x, origin_y = area_x, area_y
    if not viewport_width or not viewport_height then
      viewport_width, viewport_height = area_width, area_height
    end
  end
  if not viewport_width or viewport_width <= 0 or not viewport_height or viewport_height <= 0 then
    return nil, "viewport unavailable", diagnostics
  end

  diagnostics.origin = ("%d,%d"):format(origin_x, origin_y)
  diagnostics.viewport = ("%dx%d"):format(viewport_width, viewport_height)
  diagnostics.raw_viewport = table.concat({
    tostring(viewport_1 or "nil"),
    tostring(viewport_2 or "nil"),
    tostring(viewport_3 or "nil"),
    tostring(viewport_4 or "nil"),
    tostring(viewport_5 or "nil"),
    tostring(viewport_6 or "nil"),
  }, ",")
  local physical_width, physical_height = parse_wh(call_api(gpu, "getResolution"))
  return {
    renderer = "term-gpu",
    gpu = gpu,
    screen_address = screen_address,
    keyboard_address = call_api(term_api, "keyboard"),
    viewport_width = viewport_width,
    viewport_height = viewport_height,
    origin_x = origin_x,
    origin_y = origin_y,
    physical_width = physical_width,
    physical_height = physical_height,
    diagnostics = diagnostics,
  }, nil, diagnostics
end

local function diagnostic_summary(context, problem, diagnostics)
  local api = tostring(term_ui.API_VERSION or "?")
  if not context then
    diagnostics = diagnostics or {}
    return table.concat({
      "renderer=unavailable",
      ("error=%s"):format(problem or "unsupported renderer"),
      ("term_module=%s"):format(diagnostics.term_module and "yes" or "no"),
      ("tty_module=%s"):format(diagnostics.tty_module and "yes" or "no"),
      ("tty_available=%s"):format(diagnostics.tty_available or "unknown"),
      ("component_gpu=%s"):format(diagnostics.component_gpu or "unknown"),
      ("component_screen=%s"):format(diagnostics.component_screen or "unknown"),
      ("gpu_proxy_type=%s"):format(diagnostics.gpu_proxy_type or "nil"),
      ("screen_proxy_type=%s"):format(diagnostics.screen_proxy_type or "nil"),
      ("gpu_address=%s"):format(diagnostics.gpu_address or "nil"),
      ("screen_address=%s"):format(diagnostics.screen_address or "nil"),
      ("gpu_has_bind=%s"):format(diagnostics.gpu_has_bind or "no"),
      ("gpu_has_getScreen=%s"):format(diagnostics.gpu_has_getScreen or "no"),
      ("invoke_getScreen_ok=%s"):format(diagnostics.invoke_getScreen_ok or "no"),
      ("invoke_bind_ok=%s"):format(diagnostics.invoke_bind_ok or "no"),
      ("invoke_set_ok=%s"):format(diagnostics.invoke_set_ok or "no"),
      ("gpu_current_screen=%s"):format(diagnostics.gpu_current_screen or "nil"),
      ("gpu_bound_screen=%s"):format(diagnostics.gpu_bound_screen or "nil"),
      ("term_gpu=%s"):format(diagnostics.term_gpu or "no"),
      ("tty_gpu=%s"):format(diagnostics.tty_gpu or "no"),
      ("tty_gpu_before=%s"):format(diagnostics.tty_gpu_before or "no"),
      ("tty_gpu_after=%s"):format(diagnostics.tty_gpu_after or "no"),
      ("tty_bind_before_gpu_bind=%s"):format(diagnostics.tty_bind_before_gpu_bind or "no"),
      ("tty_bind_after_gpu_bind=%s"):format(diagnostics.tty_bind_after_gpu_bind or "no"),
      ("gpu_bind_attempted=%s"):format(diagnostics.gpu_bind_attempted or "no"),
      ("gpu_bind_ok=%s"):format(diagnostics.gpu_bind_ok or "no"),
      ("rebind_attempted=%s"):format(diagnostics.rebind_attempted or "no"),
      ("rebind_ok=%s"):format(diagnostics.rebind_ok or "no"),
      ("origin=%s"):format(diagnostics.origin or "unknown"),
      ("viewport=%s"):format(diagnostics.viewport or "unknown"),
      ("raw_viewport=%s"):format(diagnostics.raw_viewport or "unknown"),
      ("api=v%s"):format(api),
    }, " ")
  end

  diagnostics = diagnostics or context.diagnostics or {}
  local tier = layout_for(context.viewport_width, context.viewport_height).tier
  local parts = {
    ("renderer=%s"):format(context.renderer),
    ("viewport=%dx%d"):format(context.viewport_width, context.viewport_height),
    ("tier=%s"):format(tier),
    ("term_module=%s"):format(diagnostics.term_module and "yes" or "no"),
    ("tty_module=%s"):format(diagnostics.tty_module and "yes" or "no"),
    ("tty_available=%s"):format(diagnostics.tty_available or "unknown"),
    ("component_gpu=%s"):format(diagnostics.component_gpu or "unknown"),
    ("component_screen=%s"):format(diagnostics.component_screen or "unknown"),
    ("gpu_proxy_type=%s"):format(diagnostics.gpu_proxy_type or "nil"),
    ("screen_proxy_type=%s"):format(diagnostics.screen_proxy_type or "nil"),
    ("gpu_address=%s"):format(diagnostics.gpu_address or "nil"),
    ("screen_address=%s"):format(diagnostics.screen_address or "nil"),
    ("gpu_has_bind=%s"):format(diagnostics.gpu_has_bind or "no"),
    ("gpu_has_getScreen=%s"):format(diagnostics.gpu_has_getScreen or "no"),
    ("invoke_getScreen_ok=%s"):format(diagnostics.invoke_getScreen_ok or "no"),
    ("invoke_bind_ok=%s"):format(diagnostics.invoke_bind_ok or "no"),
    ("invoke_set_ok=%s"):format(diagnostics.invoke_set_ok or "no"),
    ("gpu_current_screen=%s"):format(diagnostics.gpu_current_screen or "nil"),
    ("gpu_bound_screen=%s"):format(diagnostics.gpu_bound_screen or "nil"),
    ("term_gpu=%s"):format(diagnostics.term_gpu or "no"),
    ("tty_gpu=%s"):format(diagnostics.tty_gpu or "no"),
    ("tty_gpu_before=%s"):format(diagnostics.tty_gpu_before or "no"),
    ("tty_gpu_after=%s"):format(diagnostics.tty_gpu_after or "no"),
    ("tty_bind_before_gpu_bind=%s"):format(diagnostics.tty_bind_before_gpu_bind or "no"),
    ("tty_bind_after_gpu_bind=%s"):format(diagnostics.tty_bind_after_gpu_bind or "no"),
    ("gpu_bind_attempted=%s"):format(diagnostics.gpu_bind_attempted or "no"),
    ("gpu_bind_ok=%s"):format(diagnostics.gpu_bind_ok or "no"),
    ("rebind_attempted=%s"):format(diagnostics.rebind_attempted or "no"),
    ("rebind_ok=%s"):format(diagnostics.rebind_ok or "no"),
    ("origin=%d,%d"):format(context.origin_x or 1, context.origin_y or 1),
    ("raw_viewport=%s"):format(diagnostics.raw_viewport or "unknown"),
  }
  if context.physical_width and context.physical_height then
    parts[#parts + 1] = ("gpu=%dx%d"):format(context.physical_width, context.physical_height)
  end
  parts[#parts + 1] = ("api=v%s"):format(api)
  return table.concat(parts, " ")
end

local function startup_summary(context, problem, diagnostics)
  diagnostics = diagnostics or {}
  local mode_name = diagnostics.mode_name or "run"
  if mode_name == "diagnose-ui" then
    return diagnostic_summary(context, problem, diagnostics)
  end
  if not context then
    return ("UI error: %s"):format(problem or "unsupported renderer")
  end
  return nil
end

local function apply_startup_status(state, context, problem, diagnostics, mode_name)
  diagnostics = diagnostics or {}
  diagnostics.mode_name = mode_name or diagnostics.mode_name or "run"
  local summary = startup_summary(context, problem, diagnostics)
  if summary then
    state.message = summary
  end
end

local function context_error(problem)
  return ("route_book_editor requires a bound OpenOS terminal with GPU (%s); use 'lua route_book_editor.lua diagnose-ui'"):format(problem or "unsupported renderer")
end

local function parse_cli_mode(argv)
  local args = type(argv) == "table" and argv or {}
  for index = 1, #args do
    local value = tostring(args[index] or "")
    if value == "diagnose-ui" or value == "--diagnose-ui" then
      return "diagnose-ui"
    end
    if value == "--" then
      local next_value = tostring(args[index + 1] or "")
      if next_value == "--diagnose-ui" or next_value == "diagnose-ui" then
        return "diagnose-ui"
      end
    end
  end
  return "run"
end

local function normalize_pointer_event(context, address, x, y)
  if not context or type(x) ~= "number" or type(y) ~= "number" then
    return nil, nil
  end
  if context.screen_address and type(address) == "string" and address ~= context.screen_address then
    return nil, nil
  end

  local local_x = math.floor(x) - (context.origin_x or 1) + 1
  local local_y = math.floor(y) - (context.origin_y or 1) + 1
  if local_x < 1 or local_x > context.viewport_width or local_y < 1 or local_y > context.viewport_height then
    return nil, nil
  end
  return local_x, local_y
end

local function stringify_error(err)
  if err == nil then
    return "unknown error"
  end
  if type(err) == "string" then
    return err
  end
  if type(err) == "number" or type(err) == "boolean" then
    return tostring(err)
  end
  if type(err) == "table" then
    local parts = {}
    if err.message ~= nil then
      parts[#parts + 1] = tostring(err.message)
    end
    if err.reason ~= nil and err.reason ~= err.message then
      parts[#parts + 1] = tostring(err.reason)
    end
    if err.code ~= nil then
      parts[#parts + 1] = ("code=%s"):format(tostring(err.code))
    end
    if #parts > 0 then
      return table.concat(parts, " ")
    end
  end
  return tostring(err)
end

local function make_exit(kind, context, message, code)
  return {
    kind = kind,
    context = context,
    message = stringify_error(message),
    code = code,
  }
end

local function normalize_runtime_failure(err)
  if type(err) == "table" then
    if err.kind == "terminated" or err.reason == "terminated" then
      return make_exit("terminated", err.context, err.message or err.reason or "terminated", err.code)
    end
    if err.kind == "error" then
      return make_exit("error", err.context, err.message or err.reason or err)
    end
  end
  return make_exit("error", nil, stringify_error(err))
end

local function finalize_exit(context, exit_result)
  exit_result = type(exit_result) == "table" and exit_result or make_exit("ok", context)
  context = exit_result.context or context

  local cleanup_error
  if context and context.gpu then
    local ok, flush_error = term_ui.flush(term, context.gpu, context.viewport_width, context.viewport_height, {}, context.origin_x, context.origin_y)
    if ok ~= true then
      cleanup_error = stringify_error(flush_error)
    end
  end
  if type(term_ui.reset_cache) == "function" then
    term_ui.reset_cache()
  end
  if term and type(term.setCursor) == "function" then
    pcall(term.setCursor, 1, 1)
  end
  if term and type(term.clear) == "function" then
    pcall(term.clear)
  end

  if exit_result.kind == "error" then
    if cleanup_error then
      return nil, ("%s (cleanup: %s)"):format(stringify_error(exit_result.message), cleanup_error)
    end
    return nil, stringify_error(exit_result.message)
  end
  if cleanup_error then
    return nil, cleanup_error
  end
  return true
end

local function run_loop(state, context, mode_name, on_context)
  local current_context = context
  local width = current_context and current_context.viewport_width or 100
  local height = current_context and current_context.viewport_height or 32
  local screen
  local needs_render = true

  while true do
    local new_context, new_problem, new_diagnostics = resolve_terminal_context(term, tty, component)
    if not new_context then
      return make_exit("error", current_context, context_error(new_problem))
    end

    if new_context.viewport_width ~= width
      or new_context.viewport_height ~= height
      or new_context.gpu ~= current_context.gpu then
      current_context = new_context
      width = current_context.viewport_width
      height = current_context.viewport_height
      needs_render = true
      if on_context then
        on_context(current_context)
      end
      apply_startup_status(state, current_context, new_problem, new_diagnostics, mode_name)
    end

    if needs_render or not screen then
      screen = build_screen(state, width, height)
      local ok, flush_error = term_ui.flush(term, current_context.gpu, width, height, screen.buffer, current_context.origin_x, current_context.origin_y)
      if not ok then
        return make_exit("error", current_context, flush_error)
      end
      needs_render = false
    end

    local pulled = event and {event.pull(0.1)} or {nil}
    local signal = pulled[1]

    if signal == nil then
      -- timeout poll
    elseif signal == "interrupted" then
      return make_exit("interrupted", current_context)
    elseif signal == "key_down" then
      if current_context.keyboard_address == nil or pulled[2] == current_context.keyboard_address then
        if not handle_key_down(state, pulled[3], pulled[4]) and pulled[4] == KEY.esc then
          return make_exit("ok", current_context)
        end
        needs_render = true
      end
    elseif signal == "clipboard" then
      if (current_context.keyboard_address == nil or pulled[2] == current_context.keyboard_address)
        and handle_clipboard(state, pulled[3]) then
        needs_render = true
      end
    elseif signal == "touch" then
      local local_x, local_y = normalize_pointer_event(current_context, pulled[2], pulled[3], pulled[4])
      if local_x and handle_click(state, local_x, local_y, screen) then
        needs_render = true
      end
    elseif signal == "scroll" then
      local local_x, local_y = normalize_pointer_event(current_context, pulled[2], pulled[3], pulled[4])
      local direction = (pulled[5] or 0) > 0 and -1 or 1
      if local_x and local_y and handle_scroll(state, direction) then
        needs_render = true
      end
    elseif signal == "drag" or signal == "drop" then
      -- consumed but intentionally ignored in V1
    end
  end
end

local function run(argv)
  local state = new_state()
  local context, problem, diagnostics = resolve_terminal_context(term, tty, component)
  local latest_context = context
  local mode_name = parse_cli_mode(argv)
  local diagnose = mode_name == "diagnose-ui"

  apply_startup_status(state, context, problem, diagnostics, mode_name)
  if diagnose then
    io.write(diagnostic_summary(context, problem, diagnostics) .. "\n")
    return true
  end
  if not context then
    return nil, context_error(problem)
  end

  local ok, exit_result = xpcall(function()
    return run_loop(state, context, mode_name, function(updated_context)
      latest_context = updated_context
    end)
  end, normalize_runtime_failure)
  if ok ~= true then
    exit_result = exit_result or make_exit("error", latest_context, "unknown error")
  end

  if type(exit_result) ~= "table" or not exit_result.kind then
    exit_result = make_exit("ok", latest_context)
  elseif not exit_result.context then
    exit_result.context = latest_context
  end
  return finalize_exit(latest_context, exit_result)
end

local exports = {
  new_state = new_state,
  build_screen = build_screen,
  handle_click = handle_click,
  resolve_terminal_context = resolve_terminal_context,
  diagnostic_summary = diagnostic_summary,
  normalize_pointer_event = normalize_pointer_event,
  stringify_error = stringify_error,
  startup_summary = startup_summary,
  apply_startup_status = apply_startup_status,
  normalize_runtime_failure = normalize_runtime_failure,
  finalize_exit = finalize_exit,
  run_loop = run_loop,
  run = run,
  parse_cli_mode = parse_cli_mode,
}

if mode == "__module__" then
  return exports
end

local ok, err = run({...})
if ok == nil then
  io.stderr:write(tostring(err) .. "\n")
  os.exit(1)
end
