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

local route_book_store = require("lib.route_book_store")
local augment_registry = require("lib.augment_registry")
local station_schedule = require("lib.station_schedule")
local redstone_io = require("lib.redstone_io")
local term_ui = require("lib.term_ui")

local dispatcher_chunk = assert(loadfile(join_paths(SCRIPT_DIR, "station_dispatch.lua")))
local station_dispatch = dispatcher_chunk("__module__")

local TABS = {"Detectors", "Stations", "Routes", "Schedules", "Save / Validate"}

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
      schedule_entries = 1,
    },
    message = load_error and ("load fallback: " .. tostring(load_error)) or "Ready",
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

local function build_screen(state, width, height)
  width = width or 100
  height = height or 32
  local buffer = {}
  local targets = {}
  local buttons = {
    term_ui.button("add", "Add", 3, height - 3, 8),
    term_ui.button("edit", "Edit", 13, height - 3, 8),
    term_ui.button("delete", "Delete", 23, height - 3, 10),
    term_ui.button("move_up", "Move Up", 35, height - 3, 11),
    term_ui.button("move_down", "Move Down", 48, height - 3, 13),
  }

  term_ui.render_box(buffer, term_ui.box(1, 1, width, height, "IR Schedule Editor"))
  local tab_targets = term_ui.render_tabs(buffer, TABS, state.active_tab, 3, 2)
  for _, target in ipairs(tab_targets) do
    targets[#targets + 1] = target
  end

  if state.active_tab == 1 then
    local items = detector_items(state.book)
    local _, selected_index = selected_from(items, state.selections.detectors)
    term_ui.render_box(buffer, term_ui.box(3, 4, 36, height - 8, "Known Detectors"))
    local list_targets = term_ui.render_list(buffer, 5, 6, 32, items, selected_index)
    for _, target in ipairs(list_targets) do
      target.area = "detectors"
      targets[#targets + 1] = target
    end
  elseif state.active_tab == 2 then
    local items = station_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.stations)
    term_ui.render_box(buffer, term_ui.box(3, 4, 36, height - 8, "Stations"))
    local list_targets = term_ui.render_list(buffer, 5, 6, 32, items, selected_index)
    for _, target in ipairs(list_targets) do
      target.area = "stations"
      targets[#targets + 1] = target
    end
    term_ui.render_box(buffer, term_ui.box(41, 4, width - 43, height - 8, "Station Details"))
    if selected then
      local station = state.book.STATIONS[selected.id]
      buffer[#buffer + 1] = {x = 43, y = 6, text = ("ID: %s"):format(selected.id)}
      buffer[#buffer + 1] = {x = 43, y = 7, text = ("Name: %s"):format(station.display_name or selected.id)}
      buffer[#buffer + 1] = {x = 43, y = 8, text = ("Pos: %s, %s, %s"):format(station.x, station.y, station.z)}
      local y = 10
      buffer[#buffer + 1] = {x = 43, y = y, text = "Detectors"}
      for index, detector_id in ipairs(station.detector_ids or {}) do
        buffer[#buffer + 1] = {x = 45, y = y + index, text = term_ui.fit_text(((index == 1) and "> " or "  ") .. detector_id, width - 50)}
      end
    end
  elseif state.active_tab == 3 then
    local items = route_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.routes)
    term_ui.render_box(buffer, term_ui.box(3, 4, 36, height - 8, "Routes"))
    local list_targets = term_ui.render_list(buffer, 5, 6, 32, items, selected_index)
    for _, target in ipairs(list_targets) do
      target.area = "routes"
      targets[#targets + 1] = target
    end
    term_ui.render_box(buffer, term_ui.box(41, 4, width - 43, height - 8, "Route Details"))
    if selected then
      local route = state.book.ROUTES[selected.id]
      buffer[#buffer + 1] = {x = 43, y = 6, text = ("Route: %s"):format(selected.id)}
      buffer[#buffer + 1] = {x = 43, y = 7, text = ("Profile: %s"):format(route.profile or "conservative")}
      for index, waypoint in ipairs(route.waypoints or {}) do
        buffer[#buffer + 1] = {
          x = 43,
          y = 8 + index,
          text = term_ui.fit_text(("[%d] %s"):format(index, type(waypoint) == "string" and waypoint or (("%s,%s,%s"):format(waypoint.x, waypoint.y, waypoint.z))), width - 46),
        }
      end
    end
  elseif state.active_tab == 4 then
    local items = schedule_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.schedules)
    term_ui.render_box(buffer, term_ui.box(3, 4, 24, height - 8, "Schedules"))
    local list_targets = term_ui.render_list(buffer, 5, 6, 20, items, selected_index)
    for _, target in ipairs(list_targets) do
      target.area = "schedules"
      targets[#targets + 1] = target
    end
    term_ui.render_box(buffer, term_ui.box(29, 4, 30, height - 8, "Entries"))
    term_ui.render_box(buffer, term_ui.box(61, 4, width - 63, height - 8, "Wait Conditions"))
    if selected then
      local schedule = state.book.SCHEDULES[selected.id]
      for index, entry in ipairs(schedule.entries or {}) do
        buffer[#buffer + 1] = {x = 31, y = 6 + index, text = term_ui.fit_text(("[%d] %s"):format(index, entry.route), 24)}
      end
      local first_entry = schedule.entries and schedule.entries[1]
      if first_entry and first_entry.wait then
        for group_index, group in ipairs(first_entry.wait.groups or {}) do
          buffer[#buffer + 1] = {x = 63, y = 5 + group_index * 2, text = ("Group %s"):format(string.char(64 + group_index))}
          local first_condition = group[1]
          if first_condition then
            buffer[#buffer + 1] = {
              x = 63,
              y = 6 + group_index * 2,
              text = term_ui.fit_text(("%s %s %s"):format(first_condition.type, tostring(first_condition.comparator or ">="), tostring(first_condition.value or first_condition.seconds)), width - 66),
            }
          end
        end
      end
    end
  else
    term_ui.render_box(buffer, term_ui.box(3, 4, width - 4, height - 8, "Save / Validate"))
    local validation = station_dispatch.validate_route_book(state.book)
    buffer[#buffer + 1] = {x = 5, y = 6, text = ("Dirty: %s"):format(state.dirty and "[*]" or "[ ]")}
    buffer[#buffer + 1] = {x = 5, y = 7, text = ("Validation: %s"):format(validation.ok and "OK" or "Errors")}
    for index, message in ipairs(validation.errors) do
      buffer[#buffer + 1] = {x = 5, y = 8 + index, text = term_ui.fit_text("ERROR: " .. message, width - 8)}
    end
  end

  for _, button in ipairs(term_ui.render_buttons(buffer, buttons)) do
    targets[#targets + 1] = button
  end
  buffer[#buffer + 1] = {x = 3, y = height - 2, text = term_ui.fit_text(state.message or "", width - 4)}

  return {
    buffer = buffer,
    targets = targets,
  }
end

local function prompt(label, default)
  io.write(("%s%s: "):format(label, default and (" [" .. tostring(default) .. "]") or ""))
  local value = io.read()
  if value == nil or value == "" then
    return default
  end
  return value
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
    return
  end
  local swap_index = current_index + step
  if not detectors[swap_index] then
    return
  end
  local current = state.book.AUGMENTS.DETECTORS[detectors[current_index].id]
  local other = state.book.AUGMENTS.DETECTORS[detectors[swap_index].id]
  current.sort_order, other.sort_order = other.sort_order, current.sort_order
  state.dirty = true
end

local function handle_action(state, action)
  if state.active_tab == 1 then
    if action == "add" then
      local id = prompt("Detector ID")
      if id and id ~= "" then
        state.book.AUGMENTS.DETECTORS[id] = {
          address = prompt("Address", ""),
          label = prompt("Label", id),
          sort_order = #augment_registry.list(state.book) * 10 + 10,
        }
        state.dirty = true
        state.message = "Detector added"
      end
    elseif action == "edit" then
      local id = current_detector_id(state)
      local detector = id and state.book.AUGMENTS.DETECTORS[id]
      if detector then
        detector.label = prompt("Label", detector.label or id)
        detector.address = prompt("Address", detector.address or "")
        state.dirty = true
        state.message = "Detector updated"
      end
    elseif action == "delete" then
      local id = current_detector_id(state)
      if id then
        state.book.AUGMENTS.DETECTORS[id] = nil
        state.dirty = true
        state.message = "Detector deleted"
      end
    elseif action == "move_up" then
      move_detector(state, -1)
    elseif action == "move_down" then
      move_detector(state, 1)
    end
  elseif state.active_tab == 2 then
    if action == "add" then
      local id = prompt("Station ID")
      if id and id ~= "" then
        state.book.STATIONS[id] = {
          display_name = prompt("Name", id),
          x = tonumber(prompt("X", "0")),
          y = tonumber(prompt("Y", "64")),
          z = tonumber(prompt("Z", "0")),
          detector_ids = {},
          redstone_outputs = {},
        }
        state.dirty = true
        state.message = "Station added"
      end
    elseif action == "edit" then
      local id = current_station_id(state)
      local station = id and state.book.STATIONS[id]
      if station then
        station.display_name = prompt("Name", station.display_name or id)
        station.x = tonumber(prompt("X", station.x))
        station.y = tonumber(prompt("Y", station.y))
        station.z = tonumber(prompt("Z", station.z))
        local assign = prompt("Detector IDs (; separated)", table.concat(station.detector_ids or {}, ";"))
        station.detector_ids = parse_waypoints(assign)
        state.dirty = true
        state.message = "Station updated"
      end
    elseif action == "delete" then
      local id = current_station_id(state)
      if id then
        state.book.STATIONS[id] = nil
        state.dirty = true
        state.message = "Station deleted"
      end
    end
  elseif state.active_tab == 3 then
    if action == "add" then
      local id = prompt("Route ID")
      if id and id ~= "" then
        state.book.ROUTES[id] = {
          waypoints = parse_waypoints(prompt("Waypoints (; separated station ids or x,y,z)", "")),
          cruise_kmh = tonumber(prompt("Cruise km/h", "40")),
          stop_buffer_m = tonumber(prompt("Stop buffer", "2")),
          profile = prompt("Profile", "conservative"),
        }
        state.dirty = true
        state.message = "Route added"
      end
    elseif action == "edit" then
      local id = current_route_id(state)
      local route = id and state.book.ROUTES[id]
      if route then
        route.waypoints = parse_waypoints(prompt("Waypoints", ""))
        route.cruise_kmh = tonumber(prompt("Cruise km/h", route.cruise_kmh or 40))
        route.stop_buffer_m = tonumber(prompt("Stop buffer", route.stop_buffer_m or 2))
        route.profile = prompt("Profile", route.profile or "conservative")
        state.dirty = true
        state.message = "Route updated"
      end
    elseif action == "delete" then
      local id = current_route_id(state)
      if id then
        state.book.ROUTES[id] = nil
        state.dirty = true
        state.message = "Route deleted"
      end
    end
  elseif state.active_tab == 4 then
    if action == "add" then
      local id = prompt("Schedule ID")
      if id and id ~= "" then
        state.book.SCHEDULES[id] = {
          cyclic = prompt("Cyclic (true/false)", "false") == "true",
          entries = {},
        }
        state.dirty = true
        state.message = "Schedule added"
      end
    elseif action == "edit" then
      local id = current_schedule_id(state)
      local schedule = id and state.book.SCHEDULES[id]
      if schedule then
        local route = prompt("Entry route", (schedule.entries[1] and schedule.entries[1].route) or "")
        if route and route ~= "" then
          schedule.entries[1] = {
            route = route,
            wait = {
              groups = {
                {
                  {
                    type = "time_passed",
                    seconds = tonumber(prompt("Wait seconds", "0")),
                  },
                },
              },
            },
          }
        end
        schedule.cyclic = prompt("Cyclic (true/false)", tostring(schedule.cyclic == true)) == "true"
        state.dirty = true
        state.message = "Schedule updated"
      end
    elseif action == "delete" then
      local id = current_schedule_id(state)
      if id then
        state.book.SCHEDULES[id] = nil
        state.dirty = true
        state.message = "Schedule deleted"
      end
    end
  else
    if action == "add" or action == "edit" then
      local ok, err = route_book_store.save(route_book_path(), state.book)
      if ok then
        state.dirty = false
        state.message = "route_book.lua saved"
      else
        state.message = tostring(err)
      end
    elseif action == "delete" then
      local validation = station_dispatch.validate_route_book(state.book)
      state.message = validation.ok and "Validation OK" or ("Validation errors: " .. #validation.errors)
    end
  end
end

local function handle_click(state, x, y, screen)
  for _, target in ipairs(screen.targets or {}) do
    if term_ui.hit(target, x, y) then
      if target.tab_index then
        state.active_tab = target.tab_index
        return true
      end
      if target.area then
        state.selections[target.area] = target.index
        return true
      end
      if target.id then
        handle_action(state, target.id)
        return true
      end
    end
  end
  return false
end

local function run()
  local state = new_state()
  local gpu = component and component.gpu or nil
  local width, height = 100, 32
  if gpu and type(gpu.getResolution) == "function" then
    width, height = gpu.getResolution()
  end

  while true do
    local screen = build_screen(state, width, height)
    term_ui.flush(term, gpu, width, height, screen.buffer)
    local signal = {event and event.pull() or io.read()}
    if signal[1] == "interrupted" or signal[1] == "key_down" and signal[4] == 1 then
      return true
    end
    if signal[1] == "touch" then
      handle_click(state, signal[3], signal[4], screen)
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
