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

local SCRIPT_DIR = split_path(script_source_path())
ensure_package_path(SCRIPT_DIR)

local component = rawget(_G, "component") or safe_require("component")
local event = safe_require("event")
local term = safe_require("term")
local unicode = safe_require("unicode")

local route_book_store = require("lib.route_book_store")
local augment_registry = require("lib.augment_registry")
local term_ui = require("lib.term_ui")

local dispatcher_chunk = assert(loadfile(join_paths(SCRIPT_DIR, "station_dispatch.lua")))
local station_dispatch = dispatcher_chunk("__module__")

local TABS_COMFORT = {"Detectors", "Stations", "Routes", "Schedules", "Save / Validate"}
local TABS_COMPACT = {"Det", "Sta", "Rou", "Sch", "Save"}

local KEY = {
  backspace = 14,
  enter = 28,
  tab = 15,
  esc = 1,
}

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

local function clamp(n, low, high)
  if n < low then
    return low
  end
  if n > high then
    return high
  end
  return n
end

local function add_targets(targets, incoming, extra)
  for _, target in ipairs(incoming or {}) do
    if extra then
      for key, value in pairs(extra) do
        target[key] = value
      end
    end
    if term_ui.is_valid_target(target) then
      targets[#targets + 1] = target
    end
  end
end

local function layout_for(width, height)
  local tier
  if width < 54 or height < 18 then
    tier = "minimum"
  elseif width < 80 or height < 24 then
    tier = "compact"
  else
    tier = "comfort"
  end

  local bottom_rows = tier == "compact" and 5 or 3
  local content_top = 4
  local content_height = math.max(height - content_top - bottom_rows, 1)
  return {
    tier = tier,
    tabs = tier == "comfort" and TABS_COMFORT or TABS_COMPACT,
    width = width,
    height = height,
    content_top = content_top,
    content_height = content_height,
    buttons_top = height - bottom_rows + 1,
  }
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
      {3, layout.buttons_top},
      {16, layout.buttons_top},
      {29, layout.buttons_top},
      {3, layout.buttons_top + 2},
      {18, layout.buttons_top + 2},
    }
    for index, spec in ipairs(specs) do
      buttons[#buttons + 1] = term_ui.button(spec[1], spec[2], positions[index][1], positions[index][2], math.max(#spec[2] + 4, 10))
    end
  else
    local x = 3
    for _, spec in ipairs(specs) do
      local width = math.max(#spec[2] + 4, 10)
      buttons[#buttons + 1] = term_ui.button(spec[1], spec[2], x, layout.height - 2, width)
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

local function render_modal(buffer, targets, layout, modal)
  if not modal then
    return
  end

  local width = math.max(math.min(layout.width - 6, 52), 24)
  local height = math.max(#modal.fields + 7, 10)
  local x = math.max(math.floor((layout.width - width) / 2) + 1, 2)
  local y = math.max(math.floor((layout.height - height) / 2) + 1, 2)

  term_ui.render_box(buffer, term_ui.box(x, y, width, height, modal.title or "Dialog"))
  for index, field in ipairs(modal.fields) do
    local row_y = y + 1 + index
    local prefix = index == modal.active_index and ">" or " "
    render_text(buffer, x + 2, row_y, ("%s %s: %s"):format(prefix, field.label, field.value or ""), width - 4)
    local target = {
      id = "modal:field:" .. index,
      x = x + 1,
      y = row_y,
      width = width - 2,
      height = 1,
      modal_field_index = index,
    }
    if term_ui.is_valid_target(target) then
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
    fields[#fields + 1] = {
      key = field.key,
      label = field.label,
      value = tostring(field.value or ""),
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

local function modal_field_value(modal, key)
  for _, field in ipairs(modal.fields) do
    if field.key == key then
      return field.value
    end
  end
  return nil
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

  local left_width = layout.tier == "comfort" and 36 or (width - 4)
  local right_x = layout.tier == "comfort" and 41 or 3
  local right_width = layout.tier == "comfort" and math.max(width - 43, 1) or math.max(width - 4, 1)
  local list_rows = layout.tier == "comfort" and math.max(layout.content_height - 2, 1) or math.max(math.floor((layout.content_height - 4) / 2), 1)
  local detail_top = layout.tier == "comfort" and layout.content_top or (layout.content_top + list_rows + 2)
  local detail_height = layout.tier == "comfort" and layout.content_height or math.max(height - detail_top - 5, 1)

  if state.active_tab == 1 then
    local items = detector_items(state.book)
    local _, selected_index = selected_from(items, state.selections.detectors)
    term_ui.render_box(buffer, term_ui.box(3, layout.content_top, left_width, layout.content_height, "Known Detectors"))
    add_targets(targets, term_ui.render_list(buffer, 5, layout.content_top + 2, left_width - 4, items, selected_index, list_rows), {area = "detectors"})
    if layout.tier == "comfort" then
      term_ui.render_box(buffer, term_ui.box(right_x, layout.content_top, right_width, layout.content_height, "Detector Details"))
      local selected = select(1, selected_from(items, selected_index))
      if selected then
        local detector = state.book.AUGMENTS.DETECTORS[selected.id]
        render_text(buffer, right_x + 2, layout.content_top + 2, "ID: " .. selected.id, right_width - 4)
        render_text(buffer, right_x + 2, layout.content_top + 3, "Label: " .. tostring(detector.label or selected.id), right_width - 4)
        render_text(buffer, right_x + 2, layout.content_top + 4, "Address: " .. tostring(detector.address or ""), right_width - 4)
      end
    end
  elseif state.active_tab == 2 then
    local items = station_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.stations)
    term_ui.render_box(buffer, term_ui.box(3, layout.content_top, left_width, layout.content_height, "Stations"))
    add_targets(targets, term_ui.render_list(buffer, 5, layout.content_top + 2, left_width - 4, items, selected_index, list_rows), {area = "stations"})
    term_ui.render_box(buffer, term_ui.box(right_x, detail_top, right_width, detail_height, "Station Details"))
    if selected then
      local station = state.book.STATIONS[selected.id]
      render_text(buffer, right_x + 2, detail_top + 2, ("ID: %s"):format(selected.id), right_width - 4)
      render_text(buffer, right_x + 2, detail_top + 3, ("Name: %s"):format(station.display_name or selected.id), right_width - 4)
      render_text(buffer, right_x + 2, detail_top + 4, ("Pos: %s, %s, %s"):format(station.x, station.y, station.z), right_width - 4)
      render_text(buffer, right_x + 2, detail_top + 6, "Detectors", right_width - 4)
      for index, detector_id in ipairs(station.detector_ids or {}) do
        render_text(buffer, right_x + 4, detail_top + 6 + index, ((index == 1) and "> " or "  ") .. detector_id, right_width - 6)
      end
    end
  elseif state.active_tab == 3 then
    local items = route_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.routes)
    term_ui.render_box(buffer, term_ui.box(3, layout.content_top, left_width, layout.content_height, "Routes"))
    add_targets(targets, term_ui.render_list(buffer, 5, layout.content_top + 2, left_width - 4, items, selected_index, list_rows), {area = "routes"})
    term_ui.render_box(buffer, term_ui.box(right_x, detail_top, right_width, detail_height, "Route Details"))
    if selected then
      local route = state.book.ROUTES[selected.id]
      render_text(buffer, right_x + 2, detail_top + 2, ("Route: %s"):format(selected.id), right_width - 4)
      render_text(buffer, right_x + 2, detail_top + 3, ("Profile: %s"):format(route.profile or "conservative"), right_width - 4)
      for index, waypoint in ipairs(route.waypoints or {}) do
        local waypoint_text = type(waypoint) == "string" and waypoint or ("%s,%s,%s"):format(waypoint.x, waypoint.y, waypoint.z)
        render_text(buffer, right_x + 2, detail_top + 4 + index, ("[%d] %s"):format(index, waypoint_text), right_width - 4)
      end
    end
  elseif state.active_tab == 4 then
    local items = schedule_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.schedules)
    local center_x = layout.tier == "comfort" and 29 or 3
    local center_width = layout.tier == "comfort" and 30 or math.max(width - 4, 1)
    local right_column_x = layout.tier == "comfort" and 61 or 3
    local right_column_width = layout.tier == "comfort" and math.max(width - 63, 1) or math.max(width - 4, 1)
    local second_panel_top = layout.tier == "comfort" and layout.content_top or (layout.content_top + math.max(math.floor(layout.content_height / 3), 3))
    local third_panel_top = layout.tier == "comfort" and layout.content_top or (second_panel_top + math.max(math.floor(layout.content_height / 3), 3))

    term_ui.render_box(buffer, term_ui.box(3, layout.content_top, 24, layout.content_height, "Schedules"))
    add_targets(targets, term_ui.render_list(buffer, 5, layout.content_top + 2, 20, items, selected_index, list_rows), {area = "schedules"})
    term_ui.render_box(buffer, term_ui.box(center_x, second_panel_top, center_width, layout.tier == "comfort" and layout.content_height or math.max(math.floor(layout.content_height / 3), 3), "Entries"))
    term_ui.render_box(buffer, term_ui.box(right_column_x, third_panel_top, right_column_width, layout.tier == "comfort" and layout.content_height or math.max(height - third_panel_top - 5, 3), "Wait Conditions"))
    if selected then
      local schedule = state.book.SCHEDULES[selected.id]
      for index, entry in ipairs(schedule.entries or {}) do
        render_text(buffer, center_x + 2, second_panel_top + 2 + index, ("[%d] %s"):format(index, entry.route), center_width - 4)
      end
      local first_entry = schedule.entries and schedule.entries[1]
      if first_entry and first_entry.wait then
        for group_index, group in ipairs(first_entry.wait.groups or {}) do
          local first_condition = group[1]
          render_text(buffer, right_column_x + 2, third_panel_top + 1 + group_index * 2, ("Group %s"):format(string.char(64 + group_index)), right_column_width - 4)
          if first_condition then
            render_text(buffer, right_column_x + 2, third_panel_top + 2 + group_index * 2, ("%s %s %s"):format(first_condition.type, tostring(first_condition.comparator or ">="), tostring(first_condition.value or first_condition.seconds)), right_column_width - 4)
          end
        end
      end
    end
  else
    term_ui.render_box(buffer, term_ui.box(3, layout.content_top, width - 4, layout.content_height, "Save / Validate"))
    local validation = station_dispatch.validate_route_book(state.book)
    render_text(buffer, 5, layout.content_top + 2, ("Dirty: %s"):format(state.dirty and "[*]" or "[ ]"), width - 8)
    render_text(buffer, 5, layout.content_top + 3, ("Validation: %s"):format(validation.ok and "OK" or "Errors"), width - 8)
    for index, message in ipairs(validation.errors or {}) do
      render_text(buffer, 5, layout.content_top + 4 + index, "ERROR: " .. message, width - 8)
    end
  end

  add_targets(targets, term_ui.render_buttons(buffer, make_action_buttons(layout)))
  render_text(buffer, 3, height - 1, state.message or "", math.max(width - 4, 1))

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

local function handle_key_down(state, char_code, key_code)
  if not state.modal then
    return false
  end

  local modal = state.modal
  local field = modal.fields[modal.active_index]
  if not field then
    return false
  end

  if key_code == KEY.esc then
    close_modal(state, "Canceled")
    return true
  end
  if key_code == KEY.tab then
    modal.active_index = modal.active_index % #modal.fields + 1
    return true
  end
  if key_code == KEY.enter then
    if modal.active_index < #modal.fields then
      modal.active_index = modal.active_index + 1
      return true
    end
    submit_modal(state)
    return true
  end
  if key_code == KEY.backspace then
    field.value = field.value:sub(1, math.max(#field.value - 1, 0))
    return true
  end

  local char = char_from_event(char_code)
  if char and char >= " " then
    field.value = field.value .. char
    return true
  end

  return false
end

local function resolution(gpu)
  local width, height = 100, 32
  if gpu and type(gpu.getResolution) == "function" then
    width, height = gpu.getResolution()
  end
  return width, height
end

local function run()
  local state = new_state()
  local gpu = component and component.gpu or nil
  local width, height = resolution(gpu)
  local screen
  local needs_render = true

  while true do
    local new_width, new_height = resolution(gpu)
    if new_width ~= width or new_height ~= height then
      width, height = new_width, new_height
      needs_render = true
      state.message = ("Resized to %dx%d"):format(width, height)
    end

    if needs_render or not screen then
      screen = build_screen(state, width, height)
      term_ui.flush(term, gpu, width, height, screen.buffer)
      needs_render = false
    end

    local pulled = event and {event.pull(0.1)} or {nil}
    local signal = pulled[1]

    if signal == nil then
      -- timeout poll
    elseif signal == "interrupted" then
      return true
    elseif signal == "key_down" then
      if not handle_key_down(state, pulled[3], pulled[4]) and pulled[4] == KEY.esc then
        return true
      end
      needs_render = true
    elseif signal == "touch" then
      if handle_click(state, pulled[3], pulled[4], screen) then
        needs_render = true
      end
    elseif signal == "scroll" then
      local direction = (pulled[5] or 0) > 0 and -1 or 1
      if handle_scroll(state, direction) then
        needs_render = true
      end
    elseif signal == "drag" or signal == "drop" then
      -- explicitly ignored in V1, but consumed so they do not destabilize the loop
    end
  end
end

local exports = {
  new_state = new_state,
  build_screen = build_screen,
  handle_click = handle_click,
  run = run,
}

if mode == "__module__" then
  return exports
end

local ok, err = run()
if ok == nil then
  io.stderr:write(tostring(err) .. "\n")
  os.exit(1)
end
