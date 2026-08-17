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
local SCHEDULE_CONDITION_TYPES = {
  "time_passed",
  "inactivity",
  "arrived_at_station",
  "passengers",
  "cargo_percent",
  "fluid_percent",
}
local SCHEDULE_COMPARATORS = {"<", "<=", ">", ">=", "=="}
local SCHEDULE_REDSTONE_MODES = {"while_pending", "on_departure_pulse"}
local BOOLEAN_OPTIONS = {"false", "true"}
local REDSTONE_SIDE_OPTIONS = {"north", "south", "east", "west", "top", "bottom", "front", "back", "left", "right"}

local KEY = {
  backspace = 14,
  enter = 28,
  tab = 15,
  esc = 1,
  space = 57,
  up = 200,
  down = 208,
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
    panel_scrolls = {
      detector_detail = 0,
      station_detail = 0,
      route_detail = 0,
      schedule_entries = 0,
      schedule_wait = 0,
      save = 0,
    },
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

local function trim(text)
  return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function make_text_field(spec)
  local value = tostring(spec.value or "")
  return {
    kind = "text",
    key = spec.key,
    label = spec.label,
    value = value,
    cursor = #value + 1,
    scroll_x = 0,
  }
end

local function make_choice_field(spec)
  local options = {}
  for _, option in ipairs(spec.options or {}) do
    options[#options + 1] = tostring(option)
  end
  local value = tostring(spec.value or options[1] or "")
  local found = false
  for _, option in ipairs(options) do
    if option == value then
      found = true
      break
    end
  end
  if not found and #options > 0 then
    options[#options + 1] = value
  end
  return {
    kind = "choice",
    key = spec.key,
    label = spec.label,
    options = options,
    value = value,
  }
end

local function make_section_field(label)
  return {
    kind = "section",
    label = label,
  }
end

local function make_note_field(label, lines)
  return {
    kind = "note",
    label = label,
    lines = lines or {},
  }
end

local function make_repeatable_text_field(spec)
  local items = {}
  local values = spec.values or {}
  if #values == 0 then
    values = {""}
  end
  for _, value in ipairs(values) do
    local text = tostring(value or "")
    items[#items + 1] = {
      value = text,
      cursor = #text + 1,
      scroll_x = 0,
    }
  end
  return {
    kind = "repeatable_text",
    key = spec.key,
    label = spec.label,
    add_label = spec.add_label or "+",
    items = items,
    min_items = spec.min_items or 1,
  }
end

local function build_group_item_fields(defs, item)
  local fields = {}
  for _, def in ipairs(defs or {}) do
    local value = tostring(item and item[def.key] or def.default or "")
    if def.options then
      fields[#fields + 1] = make_choice_field({
        key = def.key,
        label = def.label,
        value = value,
        options = def.options,
      })
    else
      fields[#fields + 1] = {
        kind = "text",
        key = def.key,
        label = def.label,
        value = value,
        cursor = #value + 1,
        scroll_x = 0,
      }
    end
  end
  return fields
end

local function make_repeatable_group_field(spec)
  local items = {}
  for _, item in ipairs(spec.items or {}) do
    items[#items + 1] = {
      fields = build_group_item_fields(spec.item_fields, item),
    }
  end
  return {
    kind = "repeatable_group",
    key = spec.key,
    label = spec.label,
    add_label = spec.add_label or "+",
    item_fields = spec.item_fields,
    items = items,
    min_items = spec.min_items or 0,
  }
end

-- Editor-internal scope stays a string (the chain field holds this output); the
-- persisted schedule stores a table. The table form carries an explicit station id
-- so the picker no longer needs the old single-string station_any/all choices.
local function scope_to_editor_text(scope)
  if type(scope) == "table" and type(scope.station_id) == "string" then
    if scope.all_detectors then
      return ("station:%s:all"):format(scope.station_id)
    end
    if type(scope.detector_ids) == "table" then
      local ids = {}
      for _, d in ipairs(scope.detector_ids) do
        ids[#ids + 1] = d
      end
      table.sort(ids)
      return ("station:%s:detectors:%s"):format(scope.station_id, table.concat(ids, ","))
    end
  end
  if scope == "station_all_detectors" or scope == "station_any_detector" then
    return scope
  end
  if type(scope) == "table" and type(scope.detector_id) == "string" then
    return "detector:" .. scope.detector_id
  end
  return "station_any_detector"
end

local function scope_from_editor_text(text, fallback_station_id)
  text = trim(text)
  local sid, kind, rest = text:match("^station:([^:]+):([^:]+):(.*)$")
  if sid and sid ~= "" and (kind == "all" or kind == "detectors") then
    if kind == "all" then
      return {station_id = sid, all_detectors = true}
    end
    local ids = {}
    for id in (rest or ""):gmatch("([^,]+)") do
      local t = trim(id)
      if t ~= "" then
        ids[#ids + 1] = t
      end
    end
    table.sort(ids)
    return {station_id = sid, detector_ids = ids}
  end
  if text == "station_all_detectors" or text == "station_any_detector" then
    return {station_id = fallback_station_id, all_detectors = true}
  end
  if text:match("^detector:") then
    local d = trim(text:sub(#"detector:" + 1))
    if d ~= "" then
      return {detector_id = d}
    end
  end
  return {station_id = fallback_station_id, all_detectors = true}
end

local route_destination_station_id

local function make_chain_condition(condition)
  condition = condition or {}
  return {
    type = condition.type or "time_passed",
    station = tostring(condition.station or ""),
    seconds = tostring(condition.seconds or 0),
    comparator = tostring(condition.comparator or ">="),
    value = tostring(condition.value or 0),
    scope = scope_to_editor_text(condition.scope),
  }
end

local function make_condition_chain_field(schedule)
  local field = {
    kind = "condition_chain",
    key = "wait_chain",
    label = "Wait Conditions",
    groups = {},
    selected_group_index = nil,
    selected_condition_index = nil,
    chooser = nil,
    pending_insert = nil,
    pending_condition = nil,
  }

  local first_entry = schedule and schedule.entries and schedule.entries[1] or nil
  for _, runtime_group in ipairs(first_entry and first_entry.wait and first_entry.wait.groups or {}) do
    local group = {conditions = {}}
    for _, condition in ipairs(runtime_group or {}) do
      group.conditions[#group.conditions + 1] = make_chain_condition(condition)
    end
    if #group.conditions > 0 then
      field.groups[#field.groups + 1] = group
    end
  end
  if field.groups[1] and field.groups[1].conditions[1] then
    field.selected_group_index = 1
    field.selected_condition_index = 1
  end
  return field
end

local function make_redstone_rule(rule, book)
  local field = {
    kind = "logic_chain",
    label = "Redstone Rule",
    book = book,
    groups = {},
    selected_group_index = nil,
    selected_condition_index = nil,
    chooser = nil,
    pending_insert = nil,
    pending_condition = nil,
    output = make_choice_field({
      key = "output",
      label = "Output",
      value = tostring(rule and rule.output or ""),
      options = {},
    }),
    signal = make_choice_field({
      key = "signal",
      label = "Signal",
      value = tostring(rule and rule.signal or "constant"),
      options = {"pulse", "constant"},
    }),
    pulse_ticks = make_text_field({
      key = "pulse_ticks",
      label = "Pulse ticks",
      value = tostring(rule and rule.pulse_ticks or ""),
    }),
  }

  for _, runtime_group in ipairs(rule and rule.groups or {}) do
    local group = {conditions = {}}
    for _, condition in ipairs(runtime_group or {}) do
      group.conditions[#group.conditions + 1] = make_chain_condition(condition)
    end
    if #group.conditions > 0 then
      field.groups[#field.groups + 1] = group
    end
  end
  if field.groups[1] and field.groups[1].conditions[1] then
    field.selected_group_index = 1
    field.selected_condition_index = 1
  end
  return field
end

local function make_redstone_rules_field(schedule, book)
  local field = {
    kind = "redstone_rules",
    key = "redstone_rules",
    label = "Redstone Rules",
    book = book,
    rules = {},
    selected_rule_index = nil,
  }

  local first_entry = schedule and schedule.entries and schedule.entries[1] or nil
  for _, rule in ipairs(first_entry and first_entry.redstone and first_entry.redstone.rules or {}) do
    field.rules[#field.rules + 1] = make_redstone_rule(rule, book)
  end
  if field.rules[1] then
    field.selected_rule_index = 1
  end
  return field
end

route_destination_station_id = function(book, route_id)
  if type(route_id) ~= "string" or route_id == "" then
    return nil
  end
  local route = book and book.ROUTES and book.ROUTES[route_id]
  if type(route and route.to) == "string" then
    return route.to
  end
  local last_waypoint = route and route.waypoints and route.waypoints[#route.waypoints]
  if type(last_waypoint) == "string" then
    return last_waypoint
  end
  return nil
end

local function available_redstone_ids_for_route_destination(book, route_id)
  local station_id = route_destination_station_id(book, route_id)
  local station = station_id and book and book.STATIONS and book.STATIONS[station_id] or nil
  return sorted_keys(station and station.redstone_outputs or {})
end

local function chain_condition_label(condition)
  local label
  if condition.type == "time_passed" or condition.type == "inactivity" then
    label = ("%s %ss"):format(condition.type, tostring(condition.seconds or "0"))
  elseif condition.type == "arrived_at_station" then
    label = ("arrived at %s"):format(tostring(condition.station or "?"))
  else
    label = ("%s %s %s %s"):format(
      tostring(condition.type or "?"),
      tostring(condition.comparator or ">="),
      tostring(condition.value or "0"),
      tostring(condition.scope or "station_any_detector")
    )
  end
  return label
end

local function chain_tokens_from_groups(groups)
  local tokens = {}
  groups = groups or {}
  if #groups == 0 then
    tokens[#tokens + 1] = {
      kind = "plus",
      label = "[+]",
      position = {
        location = "start",
      },
    }
    return tokens
  end
  tokens[#tokens + 1] = {
    kind = "plus",
    label = "[+]",
    position = {
      location = "start",
      right_group_index = 1,
      right_condition_index = 1,
    },
  }
  for group_index, group in ipairs(groups) do
    for condition_index, condition in ipairs(group.conditions or {}) do
      tokens[#tokens + 1] = {
        kind = "condition",
        group_index = group_index,
        condition_index = condition_index,
        label = "[" .. chain_condition_label(condition) .. "]",
      }
      if group.conditions[condition_index + 1] then
        tokens[#tokens + 1] = {
          kind = "operator",
          operator = "AND",
          group_index = group_index,
          after_condition_index = condition_index,
          label = "[AND]",
        }
        tokens[#tokens + 1] = {
          kind = "plus",
          label = "[+]",
          position = {
            location = "within_group",
            left_group_index = group_index,
            left_condition_index = condition_index,
            right_group_index = group_index,
            right_condition_index = condition_index + 1,
          },
        }
      elseif groups[group_index + 1] then
        tokens[#tokens + 1] = {
          kind = "operator",
          operator = "OR",
          after_group_index = group_index,
          label = "[OR]",
        }
        tokens[#tokens + 1] = {
          kind = "plus",
          label = "[+]",
          position = {
            location = "between_groups",
            left_group_index = group_index,
            left_condition_index = #group.conditions,
            right_group_index = group_index + 1,
            right_condition_index = 1,
          },
        }
      end
    end
  end

  local last_group = groups[#groups]
  tokens[#tokens + 1] = {
    kind = "plus",
    label = "[+]",
    position = {
      location = "end",
      left_group_index = #groups,
      left_condition_index = last_group and #last_group.conditions or nil,
    },
  }

  return tokens
end

local function chain_token_lines(field, width)
  local lines = {}
  local current = {tokens = {}, width = 0}
  width = math.max(tonumber(width) or 0, 10)

  local function push_current()
    if #current.tokens > 0 then
      lines[#lines + 1] = current
      current = {tokens = {}, width = 0}
    end
  end

  for _, token in ipairs(chain_tokens_from_groups(field.groups)) do
    local text = tostring(token.label or "")
    local token_width = #text
    local spacer = current.width > 0 and 1 or 0
    if current.width > 0 and current.width + spacer + token_width > width then
      push_current()
      spacer = 0
    end
    current.tokens[#current.tokens + 1] = token
    current.width = current.width + spacer + token_width
  end
  push_current()
  if #lines == 0 then
    lines[1] = {tokens = {{kind = "plus", slot = "start", label = "[+]"}}, width = 3}
  end
  return lines
end

local function runtime_condition_from_editor(condition)
  local out = {type = condition.type}
  if condition.type == "time_passed" or condition.type == "inactivity" then
    out.seconds = tonumber(condition.seconds) or 0
  elseif condition.type == "arrived_at_station" then
    out.station = tostring(condition.station or "")
  else
    out.comparator = condition.comparator or ">="
    out.value = tonumber(condition.value) or 0
    out.scope = scope_from_editor_text(condition.scope)
  end
  return out
end

local function runtime_groups_from_chain(field)
  local groups = {}
  for _, group in ipairs(field.groups or {}) do
    local runtime_group = {}
    for _, condition in ipairs(group.conditions or {}) do
      runtime_group[#runtime_group + 1] = runtime_condition_from_editor(condition)
    end
    if #runtime_group > 0 then
      groups[#groups + 1] = runtime_group
    end
  end
  if #groups == 0 then
    groups[1] = {
      {type = "time_passed", seconds = 0},
    }
  end
  return groups
end

local function runtime_redstone_rules_from_editor(field)
  local rules = {}
  for _, rule in ipairs(field and field.rules or {}) do
    local output = trim(rule.output and rule.output.value or "")
    if output ~= "" then
      rules[#rules + 1] = {
        output = output,
        signal = rule.signal and rule.signal.value or "constant",
        pulse_ticks = tonumber(rule.pulse_ticks and rule.pulse_ticks.value) or nil,
        groups = runtime_groups_from_chain(rule),
      }
    end
  end
  return rules
end

local function group_field_by_key(item, key)
  for _, field in ipairs(item and item.fields or {}) do
    if field.key == key then
      return field
    end
  end
  return nil
end

local function split_legacy_waypoint_string(raw)
  raw = trim(raw)
  if raw == "" then
    return {}
  end
  local items = {}
  if raw:find("%b[]") then
    for group in raw:gmatch("%b[]") do
      local inner = trim(group:sub(2, -2))
      if inner ~= "" then
        items[#items + 1] = inner
      end
    end
    if #items > 0 then
      return items
    end
  end
  return {raw}
end

local function waypoint_rows_from_route(waypoints)
  local rows = {}
  for _, waypoint in ipairs(waypoints or {}) do
    if type(waypoint) == "string" then
      local split = split_legacy_waypoint_string(waypoint)
      if #split > 0 then
        for _, item in ipairs(split) do
          rows[#rows + 1] = item
        end
      else
        rows[#rows + 1] = waypoint
      end
    else
      rows[#rows + 1] = ("%s,%s,%s"):format(waypoint.x, waypoint.y, waypoint.z)
    end
  end
  if #rows == 0 then
    rows[1] = ""
  end
  return rows
end

local function collect_detector_ids(values)
  local out = {}
  for _, raw in ipairs(values.detector_ids or {}) do
    local text = trim(raw)
    if text ~= "" then
      out[#out + 1] = text
    end
  end
  return out
end

local function collect_waypoints(values)
  local out = {}
  for _, raw in ipairs(values.waypoints or {}) do
    local text = trim(raw)
    if text ~= "" then
      local split = split_legacy_waypoint_string(text)
      local parts = #split > 0 and split or {text}
      for _, entry in ipairs(parts) do
        local trimmed = trim(entry)
        local a, b, c = trimmed:match("^%[?%s*([^,%]]+)%s*,%s*([^,%]]+)%s*,%s*([^,%]]+)%s*%]?$")
        if a and b and c then
          local x = tonumber(a)
          local y = tonumber(b)
          local z = tonumber(c)
          if x and y and z then
            out[#out + 1] = {x = x, y = y, z = z}
          else
            out[#out + 1] = trimmed
          end
        else
          out[#out + 1] = trimmed
        end
      end
    end
  end
  return out
end

local function route_via_rows(route)
  return waypoint_rows_from_route(route and (route.via or route.waypoints) or {})
end

local function schedule_entry_rows(schedule)
  local rows = {}
  for _, entry in ipairs(schedule and schedule.entries or {}) do
    rows[#rows + 1] = ("%s | %s"):format(entry.station or "", entry.route or "")
  end
  if #rows == 0 then
    rows[1] = ""
  end
  return rows
end

local function collect_schedule_entry_refs(values)
  local out = {}
  for _, raw in ipairs(values.entries or {}) do
    local text = trim(raw)
    if text ~= "" then
      local station, route = text:match("^%s*([^|]*)%s*|%s*(.-)%s*$")
      if not station then
        station = text
        route = ""
      end
      out[#out + 1] = {
        station = trim(station) ~= "" and trim(station) or nil,
        route = trim(route) ~= "" and trim(route) or nil,
      }
    end
  end
  return out
end

local function redstone_output_rows_from_station(station)
  local rows = {}
  local names = sorted_keys(station and station.redstone_outputs or {})
  for _, name in ipairs(names) do
    local output = station.redstone_outputs[name] or {}
    rows[#rows + 1] = {
      id = name,
      address = tostring(output.address or ""),
      side = tostring(output.side or ""),
      strength = tostring(output.strength ~= nil and output.strength or 15),
      pulse_ticks = tostring(output.pulse_ticks ~= nil and output.pulse_ticks or 20),
      active_high = tostring(output.active_high ~= false),
    }
  end
  return rows
end

local function collect_redstone_outputs(values)
  local outputs = {}
  for _, item in ipairs(values.redstone_outputs or {}) do
    local id = trim(item.id)
    if id ~= "" then
      local address = trim(item.address)
      outputs[id] = {
        address = address ~= "" and address or nil,
        side = trim(item.side),
        strength = tonumber(item.strength) or 15,
        pulse_ticks = tonumber(item.pulse_ticks) or 20,
        active_high = trim(item.active_high):lower() ~= "false",
      }
    end
  end
  return outputs
end

local function validate_redstone_output_rows(rows)
  local seen = {}
  for _, item in ipairs(rows or {}) do
    local id = trim(item.id)
    if id ~= "" then
      if seen[id] then
        return false, ("Redstone I/O ID duplicated: %s"):format(id)
      end
      seen[id] = true
    end
  end
  return true
end

local function inspect_redstone_runtime(book)
  local outputs = {}
  local condition_refs = {}

  for station_id, station in pairs(book.STATIONS or {}) do
    for output_name, output in pairs(station.redstone_outputs or {}) do
      outputs[#outputs + 1] = {
        station_id = station_id,
        output = output_name,
        side = tostring(output.side or "?"),
        strength = output.strength ~= nil and tostring(output.strength) or "15",
        pulse_ticks = output.pulse_ticks ~= nil and tostring(output.pulse_ticks) or "20",
        active_high = output.active_high == false and "false" or "true",
      }
    end
  end

  for schedule_id, schedule in pairs(book.SCHEDULES or {}) do
    for entry_index, entry in ipairs(schedule.entries or {}) do
      for group_index, group in ipairs(entry.wait and entry.wait.groups or {}) do
        for condition_index, condition in ipairs(group or {}) do
          if type(condition.redstone) == "table" then
            condition_refs[#condition_refs + 1] = {
              schedule = schedule_id,
              entry = entry_index,
              group = group_index,
              condition = condition_index,
              output = tostring(condition.redstone.output or "?"),
              mode = tostring(condition.redstone.mode or "?"),
            }
          end
        end
      end
      for rule_index, rule in ipairs(entry.redstone and entry.redstone.rules or {}) do
        condition_refs[#condition_refs + 1] = {
          schedule = schedule_id,
          entry = entry_index,
          group = rule_index,
          condition = 0,
          output = tostring(rule.output or "?"),
          mode = "rule",
        }
      end
    end
  end

  table.sort(outputs, function(a, b)
    if a.station_id ~= b.station_id then
      return tostring(a.station_id) < tostring(b.station_id)
    end
    return tostring(a.output) < tostring(b.output)
  end)

  table.sort(condition_refs, function(a, b)
    if a.schedule ~= b.schedule then
      return tostring(a.schedule) < tostring(b.schedule)
    end
    if a.entry ~= b.entry then
      return a.entry < b.entry
    end
    if a.group ~= b.group then
      return a.group < b.group
    end
    return a.condition < b.condition
  end)

  local component_present = false
  if component and type(component.isAvailable) == "function" then
    local ok, value = pcall(component.isAvailable, "redstone")
    component_present = ok and value == true
  end

  return {
    required = #outputs > 0,
    component_present = component_present,
    outputs = outputs,
    condition_refs = condition_refs,
  }
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

local function group_label(index)
  local out = ""
  index = tonumber(index) or 1
  while index > 0 do
    local rem = (index - 1) % 26
    out = string.char(65 + rem) .. out
    index = math.floor((index - 1) / 26)
  end
  return out
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

local function split_long_token(token, width)
  local out = {}
  token = tostring(token or "")
  width = math.max(tonumber(width) or 0, 1)
  while #token > width do
    out[#out + 1] = token:sub(1, width)
    token = token:sub(width + 1)
  end
  if token ~= "" then
    out[#out + 1] = token
  end
  return out
end

local function wrap_text(text, width)
  text = tostring(text or "")
  width = math.max(tonumber(width) or 0, 1)
  local lines = {}

  for raw_line in (text .. "\n"):gmatch("(.-)\n") do
    if raw_line == "" then
      lines[#lines + 1] = ""
    else
      local current = ""
      for token in raw_line:gmatch("%S+") do
        if #token > width then
          if current ~= "" then
            lines[#lines + 1] = current
            current = ""
          end
          for _, part in ipairs(split_long_token(token, width)) do
            lines[#lines + 1] = part
          end
        else
          local candidate = current == "" and token or (current .. " " .. token)
          if #candidate <= width then
            current = candidate
          else
            if current ~= "" then
              lines[#lines + 1] = current
            end
            current = token
          end
        end
      end
      if current ~= "" then
        lines[#lines + 1] = current
      end
    end
  end

  if #lines == 0 then
    lines[1] = ""
  end
  return lines
end

local function render_wrapped_lines(buffer, x, y, width, height, lines, scroll_y)
  local flat = {}
  width = math.max(tonumber(width) or 0, 1)
  height = math.max(tonumber(height) or 0, 0)
  for _, line in ipairs(lines or {}) do
    for _, wrapped in ipairs(wrap_text(line, width)) do
      flat[#flat + 1] = wrapped
    end
  end

  local max_scroll = math.max(#flat - height, 0)
  scroll_y = clamp(scroll_y or 0, 0, max_scroll)

  for row = 1, height do
    local text = flat[scroll_y + row]
    if not text then
      break
    end
    render_text(buffer, x, y + row - 1, text, width)
  end

  return {
    line_count = #flat,
    scroll_y = scroll_y,
    max_scroll = max_scroll,
  }
end

local function inline_view(raw_value, cursor, scroll_x, viewport, show_cursor)
  raw_value = tostring(raw_value or "")
  cursor = clamp(cursor or (#raw_value + 1), 1, #raw_value + 1)
  viewport = math.max(viewport or 1, 1)
  scroll_x = clamp(scroll_x or 0, 0, math.max(#raw_value - viewport, 0))

  if cursor - 1 < scroll_x then
    scroll_x = cursor - 1
  elseif cursor - 1 > scroll_x + viewport then
    scroll_x = cursor - 1 - viewport
  end

  local display = raw_value:sub(scroll_x + 1, scroll_x + viewport)
  if show_cursor then
    local cursor_index = clamp(cursor - scroll_x, 1, viewport + 1)
    display = display:sub(1, cursor_index - 1) .. "|" .. display:sub(cursor_index)
  end

  return display, scroll_x
end

local function normalize_clipboard_text(text)
  text = tostring(text or ""):gsub("\r\n", "\n"):gsub("\r", "\n"):gsub("\n", " ")
  return text
end

local function modal_field_visible_value(field, available, show_cursor)
  local prefix = tostring(field.label or "") .. ": "
  local viewport = math.max(available - #prefix - 1, 1)
  local display, next_scroll_x = inline_view(field.value or "", field.cursor, field.scroll_x, viewport, show_cursor)
  field.scroll_x = next_scroll_x
  return prefix .. display
end

local function repeatable_item_visible_value(field, item, available, item_index, show_cursor)
  local label = item_index == 1 and field.label or string.rep(" ", #tostring(field.label or ""))
  local prefix = ("%s [%d]: "):format(label, item_index)
  local viewport = math.max(available - #prefix - 1, 1)
  local display, next_scroll_x = inline_view(item.value or "", item.cursor, item.scroll_x, viewport, show_cursor)
  item.scroll_x = next_scroll_x
  return prefix .. display
end

local function repeatable_add_visible_value(field, show_label)
  local add_text = "[" .. tostring(field.add_label or "+") .. "]"
  if show_label then
    return ("%s %s"):format(tostring(field.label or ""), add_text)
  end
  local indent = string.rep(" ", #tostring(field.label or "")) .. " "
  return indent .. add_text
end

local function choice_visible_value(field)
  return ("%s: [%s]"):format(tostring(field.label or ""), tostring(field.value or ""))
end

local function cycle_choice_value(field, step)
  local options = field and field.options or {}
  if #options == 0 then
    return false
  end
  local index = 1
  for option_index, option in ipairs(options) do
    if tostring(option) == tostring(field.value) then
      index = option_index
      break
    end
  end
  index = ((index - 1 + step) % #options) + 1
  field.value = tostring(options[index])
  return true
end

local find_modal_row_index

local function open_choice_chooser(modal, field)
  local options = field and field.options or {}
  if #options == 0 then
    return false
  end
  local selected = 1
  for index, option in ipairs(options) do
    if tostring(option) == tostring(field.value) then
      selected = index
      break
    end
  end
  modal.choice_chooser = {
    field = field,
    title = tostring(field.label or "Choose Option"),
    options = options,
    selected = selected,
  }
  modal.active_row = find_modal_row_index(modal, function(row)
    return row.kind == "choice_chooser" and row.option_index == selected
  end) or modal.active_row
  return true
end

local function group_item_field_visible_value(field, item_index, subfield, available, show_cursor, first_in_item)
  local head = first_in_item
    and ("%s [%d] %s: "):format(field.label, item_index, subfield.label)
    or (string.rep(" ", #tostring(field.label or "")) .. "     " .. subfield.label .. ": ")
  if subfield.kind == "choice" then
    return head .. "[" .. tostring(subfield.value or "") .. "]"
  end
  local viewport = math.max(available - #head - 1, 1)
  local display, next_scroll_x = inline_view(subfield.value or "", subfield.cursor, subfield.scroll_x, viewport, show_cursor)
  subfield.scroll_x = next_scroll_x
  return head .. display
end

local function selected_chain_condition(field)
  local group = field and field.groups and field.groups[field.selected_group_index]
  return group and group.conditions and group.conditions[field.selected_condition_index] or nil
end

local function selected_redstone_rule(field)
  return field and field.rules and field.rules[field.selected_rule_index] or nil
end

local function first_condition_chain_field(modal)
  for _, field in ipairs(modal and modal.fields or {}) do
    if field.kind == "condition_chain" then
      return field
    end
  end
  return nil
end

local function first_redstone_rules_field(modal)
  for _, field in ipairs(modal and modal.fields or {}) do
    if field.kind == "redstone_rules" then
      return field
    end
  end
  return nil
end

-- The schedule modal has no standalone "route" field; entries are stored as
-- "station | route" text rows (see collect_schedule_entry_refs). The editor only
-- writes entry 1's wait/redstone on save, but the offered options span every entry
-- station via schedule_entry_station_ids so all stations stay editable in one place.
local function modal_first_entry_ref(modal)
  for _, field in ipairs(modal and modal.fields or {}) do
    if field.key == "entries" then
      local first = field.items and field.items[1]
      if not first then
        return nil
      end
      local refs = collect_schedule_entry_refs({entries = {first.value}})
      return refs[1]
    end
  end
  return nil
end

-- Prefer the route's terminal station, but fall back to the entry's own station
-- when the route is omitted (the dispatcher auto-resolves it). station_schedule
-- validates that both name the same destination station.
local function entry_destination_station_id(book, station_id, route_id)
  if type(route_id) == "string" and route_id ~= "" then
    local resolved = route_destination_station_id(book, route_id)
    if resolved then
      return resolved
    end
  end
  return type(station_id) == "string" and station_id ~= "" and station_id or nil
end

local function modal_destination_station_id(book, modal)
  local ref = modal_first_entry_ref(modal)
  if not ref then
    return nil
  end
  return entry_destination_station_id(book, ref.station, ref.route)
end

-- Every entry station that the modal's live `entries` field currently resolves to,
-- de-duplicated and stable by first appearance. Used to build the union of redstone
-- outputs and the scope station list while the edit is still in progress.
local function schedule_entry_station_ids(book, modal)
  local ids = {}
  local seen = {}
  if type(modal) == "table" then
    for _, field in ipairs(modal.fields or {}) do
      if field.key == "entries" then
        for _, item in ipairs(field.items or {}) do
          local refs = collect_schedule_entry_refs({entries = {item.value}})
          for _, ref in ipairs(refs) do
            local station_id = entry_destination_station_id(book, ref.station, ref.route)
            if station_id and not seen[station_id] then
              seen[station_id] = true
              ids[#ids + 1] = station_id
            end
          end
        end
        break
      end
    end
  end
  return ids
end

local function available_redstone_ids_for_station(book, station_id)
  local station = station_id and book and book.STATIONS and book.STATIONS[station_id] or nil
  return sorted_keys(station and station.redstone_outputs or {})
end

-- Merge + sort + de-dup the redstone output names across the given stations.
-- Used by the schedule redstone-rule output picker so one entry's outputs are
-- selectable even though the editor only writes entry 1's rules on save.
local function available_redstone_ids_for_schedule(book, station_ids)
  local seen = {}
  local merged = {}
  for _, station_id in ipairs(station_ids or {}) do
    local station = book and book.STATIONS and book.STATIONS[station_id]
    if type(station) == "table" then
      for _, output_id in ipairs(sorted_keys(station.redstone_outputs or {})) do
        if not seen[output_id] then
          seen[output_id] = true
          merged[#merged + 1] = output_id
        end
      end
    end
  end
  table.sort(merged)
  return merged
end

local function refresh_rule_output_options(modal, field)
  local station_ids = schedule_entry_station_ids(field and field.book or nil, modal)
  local options = available_redstone_ids_for_schedule(field and field.book or nil, station_ids)
  if #options == 0 then
    options = available_redstone_ids_for_station(field and field.book or nil, modal_destination_station_id(field and field.book or nil, modal))
  end
  local seen_current = false
  for _, option in ipairs(options) do
    if option == tostring(field.output.value or "") then
      seen_current = true
      break
    end
  end
  if not seen_current and trim(field.output.value) ~= "" then
    options[#options + 1] = tostring(field.output.value)
  end
  field.output.options = options
end

local function legacy_redstone_refs(entry)
  local refs = {}
  for group_index, group in ipairs(entry and entry.wait and entry.wait.groups or {}) do
    for condition_index, condition in ipairs(group or {}) do
      if type(condition.redstone) == "table" and trim(condition.redstone.output) ~= "" then
        refs[#refs + 1] = ("Wait %s.%d -> %s (%s)"):format(
          group_label(group_index),
          condition_index,
          tostring(condition.redstone.output),
          tostring(condition.redstone.mode or "while_pending")
        )
      end
    end
  end
  return refs
end

local function chain_summary_lines(groups)
  local lines = {}
  for group_index, group in ipairs(groups or {}) do
    lines[#lines + 1] = ("Group %s"):format(group_label(group_index))
    for condition_index, condition in ipairs(group.conditions or {}) do
      lines[#lines + 1] = ("  [%d] %s"):format(condition_index, chain_condition_label(condition))
    end
  end
  if #lines == 0 then
    lines[1] = "No conditions."
  end
  return lines
end

local function build_chain_chooser_rows(field_index, field)
  local rows = {}
  local chooser = field.chooser
  if not chooser then
    return rows
  end
  local section_label = ({
    operator = "Choose Join",
    condition_type = "Choose Condition",
    existing_condition_type = "Choose Condition",
    comparator = "Choose Comparator",
    station_chooser = "Choose Station",
  })[chooser.kind]
  if chooser.kind == "scope" then
    section_label = chooser.stage == "detectors" and "Choose Detectors" or "Choose Scope Station"
  end
  rows[#rows + 1] = {
    kind = "section",
    label = section_label or "Choose Option",
  }
  for option_index, option in ipairs(chooser.options or {}) do
    local checked
    if chooser.kind == "scope" and chooser.stage == "detectors" then
      if option == "(all detectors)" then
        checked = chooser.all_selected
      elseif option == "(done)" then
        checked = nil
      else
        checked = chooser.selected_detectors and chooser.selected_detectors[option] == true or false
      end
    end
    rows[#rows + 1] = {
      kind = "chain_chooser",
      field_index = field_index,
      field = field,
      chooser = chooser,
      option_index = option_index,
      option = option,
      checked = checked,
    }
  end
  return rows
end

local function build_modal_rows(modal)
  local rows = {}
  for field_index, field in ipairs(modal.fields or {}) do
    if field.kind == "section" then
      rows[#rows + 1] = field
    elseif field.kind == "note" then
      rows[#rows + 1] = {
        kind = "section",
        label = field.label,
      }
      for _, line in ipairs(field.lines or {}) do
        rows[#rows + 1] = {
          kind = "note_line",
          text = line,
        }
      end
    elseif field.kind == "repeatable_text" then
      for item_index, item in ipairs(field.items or {}) do
        rows[#rows + 1] = {
          kind = "repeat_item",
          field_index = field_index,
          item_index = item_index,
          field = field,
          item = item,
        }
      end
      rows[#rows + 1] = {
        kind = "repeat_add",
        field_index = field_index,
        field = field,
      }
    elseif field.kind == "repeatable_group" then
      for item_index, item in ipairs(field.items or {}) do
        for subfield_index, subfield in ipairs(item.fields or {}) do
          rows[#rows + 1] = {
            kind = "group_item_field",
            field_index = field_index,
            item_index = item_index,
            subfield_index = subfield_index,
            field = field,
            item = item,
            subfield = subfield,
          }
        end
      end
      rows[#rows + 1] = {
        kind = "group_add",
        field_index = field_index,
        field = field,
      }
    elseif field.kind == "condition_chain" then
      local token_lines = chain_token_lines(field, modal.chain_wrap_width or 48)
      for line_index, line in ipairs(token_lines) do
        rows[#rows + 1] = {
          kind = "chain_tokens",
          field_index = field_index,
          field = field,
          line_index = line_index,
          line = line,
        }
      end

      local selected = selected_chain_condition(field)
      if selected then
        rows[#rows + 1] = {
          kind = "section",
          label = "Selected Wait Condition",
        }
        rows[#rows + 1] = {
          kind = "chain_condition_detail",
          field_index = field_index,
          field = field,
          detail = "type",
        }
        if selected.type == "time_passed" or selected.type == "inactivity" then
          rows[#rows + 1] = {
            kind = "chain_condition_detail",
            field_index = field_index,
            field = field,
            detail = "seconds",
            text_field = selected,
          }
        elseif selected.type == "arrived_at_station" then
          rows[#rows + 1] = {
            kind = "chain_condition_detail",
            field_index = field_index,
            field = field,
            detail = "station",
          }
        else
          rows[#rows + 1] = {
            kind = "chain_condition_detail",
            field_index = field_index,
            field = field,
            detail = "comparator",
          }
          rows[#rows + 1] = {
            kind = "chain_condition_detail",
            field_index = field_index,
            field = field,
            detail = "value",
            text_field = selected,
          }
          rows[#rows + 1] = {
            kind = "chain_condition_detail",
            field_index = field_index,
            field = field,
            detail = "scope",
          }
        end
      end

      for _, chooser_row in ipairs(build_chain_chooser_rows(field_index, field)) do
        rows[#rows + 1] = chooser_row
      end
    elseif field.kind == "redstone_rules" then
      rows[#rows + 1] = {
        kind = "redstone_rule_add",
        field_index = field_index,
        field = field,
      }
      for rule_index, rule in ipairs(field.rules or {}) do
        refresh_rule_output_options(modal, rule)
        rows[#rows + 1] = {
          kind = "redstone_rule_summary",
          field_index = field_index,
          field = field,
          rule_index = rule_index,
          rule = rule,
        }
        for _, line in ipairs(chain_summary_lines(rule.groups)) do
          rows[#rows + 1] = {
            kind = "redstone_rule_summary_line",
            field_index = field_index,
            field = field,
            rule_index = rule_index,
            text = line,
          }
        end
      end
      local rule = selected_redstone_rule(field)
      if rule then
        rows[#rows + 1] = {
          kind = "section",
          label = "Selected Redstone Rule",
        }
        rows[#rows + 1] = {
          kind = "redstone_rule_output",
          field_index = field_index,
          field = field,
          rule_index = field.selected_rule_index,
          rule = rule,
        }
        rows[#rows + 1] = {
          kind = "choice",
          field_index = field_index,
          field = rule.signal,
        }
        rows[#rows + 1] = {
          kind = "text",
          field_index = field_index,
          field = rule.pulse_ticks,
        }
        local token_lines = chain_token_lines(rule, modal.chain_wrap_width or 48)
        for line_index, line in ipairs(token_lines) do
          rows[#rows + 1] = {
            kind = "chain_tokens",
            field_index = field_index,
            field = rule,
            line_index = line_index,
            line = line,
          }
        end
        local selected = selected_chain_condition(rule)
        if selected then
          rows[#rows + 1] = {
            kind = "section",
            label = "Selected Redstone Condition",
          }
          rows[#rows + 1] = {
            kind = "chain_condition_detail",
            field_index = field_index,
            field = rule,
            detail = "type",
          }
          if selected.type == "time_passed" or selected.type == "inactivity" then
            rows[#rows + 1] = {
              kind = "chain_condition_detail",
              field_index = field_index,
              field = rule,
              detail = "seconds",
            }
          else
            rows[#rows + 1] = {
              kind = "chain_condition_detail",
              field_index = field_index,
              field = rule,
              detail = "comparator",
            }
            rows[#rows + 1] = {
              kind = "chain_condition_detail",
              field_index = field_index,
              field = rule,
              detail = "value",
            }
            rows[#rows + 1] = {
              kind = "chain_condition_detail",
              field_index = field_index,
              field = rule,
              detail = "scope",
            }
          end
        end
        for _, chooser_row in ipairs(build_chain_chooser_rows(field_index, rule)) do
          rows[#rows + 1] = chooser_row
        end
      end
    elseif field.kind == "choice" then
      rows[#rows + 1] = {
        kind = "choice",
        field_index = field_index,
        field = field,
      }
    else
      rows[#rows + 1] = {
        kind = "text",
        field_index = field_index,
        field = field,
      }
    end
  end
  for option_index, option in ipairs(modal.choice_chooser and modal.choice_chooser.options or {}) do
    rows[#rows + 1] = {
      kind = "choice_chooser",
      chooser = modal.choice_chooser,
      option_index = option_index,
      option = option,
    }
  end
  return rows
end

local function current_modal_row(state)
  if not state.modal then
    return nil
  end
  local rows = build_modal_rows(state.modal)
  return rows[state.modal.active_row], rows
end

local function current_modal_text_cell(state)
  local row = select(1, current_modal_row(state))
  if not row then
    return nil
  end
  if row.kind == "text" then
    return row.field
  end
  if row.kind == "repeat_item" then
    return row.item
  end
  if row.kind == "group_item_field" and row.subfield.kind ~= "choice" then
    return row.subfield
  end
  return nil
end

local function move_modal_row(state, step)
  local row, rows = current_modal_row(state)
  if not state.modal or #rows == 0 then
    return false
  end
  state.modal.active_row = clamp((state.modal.active_row or 1) + step, 1, #rows)
  return true
end

local function ensure_modal_row_visible(modal, body_height)
  local rows = build_modal_rows(modal)
  local max_scroll = math.max(#rows - body_height, 0)
  modal.scroll_y = clamp(modal.scroll_y or 0, 0, max_scroll)
  local active = clamp(modal.active_row or 1, 1, math.max(#rows, 1))
  modal.active_row = active
  if active <= modal.scroll_y then
    modal.scroll_y = active - 1
  elseif active > modal.scroll_y + body_height then
    modal.scroll_y = active - body_height
  end
  modal.scroll_y = clamp(modal.scroll_y, 0, max_scroll)
end

local function insert_repeatable_item(modal, field_index, item_index)
  local field = modal and modal.fields[field_index]
  if not field or (field.kind ~= "repeatable_text" and field.kind ~= "repeatable_group") then
    return nil
  end
  local insert_at = math.max(1, math.min((item_index or #field.items) + 1, #field.items + 1))
  if field.kind == "repeatable_group" then
    table.insert(field.items, insert_at, {
      fields = build_group_item_fields(field.item_fields, {}),
    })
  else
    table.insert(field.items, insert_at, {
      value = "",
      cursor = 1,
      scroll_x = 0,
    })
  end
  local rows = build_modal_rows(modal)
  for row_index, row in ipairs(rows) do
    if (row.kind == "repeat_item" or row.kind == "group_item_field")
      and row.field_index == field_index
      and row.item_index == insert_at then
      modal.active_row = row_index
      return row_index
    end
  end
  return nil
end

find_modal_row_index = function(modal, predicate)
  local rows = build_modal_rows(modal)
  for row_index, row in ipairs(rows) do
    if predicate(row) then
      return row_index
    end
  end
  return nil
end

local function remove_repeatable_item(modal, field_index, item_index)
  local field = modal and modal.fields[field_index]
  if not field or (field.kind ~= "repeatable_text" and field.kind ~= "repeatable_group") then
    return false
  end
  if #field.items <= (field.min_items or 1) then
    return false
  end
  table.remove(field.items, item_index)
  local next_index = find_modal_row_index(modal, function(row)
    return row.field_index == field_index and row.item_index == item_index
  end) or find_modal_row_index(modal, function(row)
    return row.field_index == field_index and row.item_index == (item_index - 1)
  end) or find_modal_row_index(modal, function(row)
    return row.field_index == field_index and (row.kind == "repeat_add" or row.kind == "group_add")
  end)
  local rows = build_modal_rows(modal)
  modal.active_row = next_index or clamp(modal.active_row or 1, 1, math.max(#rows, 1))
  return true
end

local function collect_modal_values(modal)
  local values = {}
  for _, field in ipairs(modal.fields or {}) do
    if field.kind == "section" or field.kind == "note" then
      -- structural only
    elseif field.kind == "repeatable_text" then
      local items = {}
      for _, item in ipairs(field.items or {}) do
        items[#items + 1] = item.value
      end
      values[field.key] = items
    elseif field.kind == "repeatable_group" then
      local items = {}
      for _, item in ipairs(field.items or {}) do
        local out = {}
        for _, subfield in ipairs(item.fields or {}) do
          out[subfield.key] = subfield.value
        end
        items[#items + 1] = out
      end
      values[field.key] = items
    elseif field.kind == "condition_chain" then
      values[field.key] = {
        groups = runtime_groups_from_chain(field),
      }
    elseif field.kind == "redstone_rules" then
      values[field.key] = runtime_redstone_rules_from_editor(field)
    else
      values[field.key] = field.value
    end
  end
  return values
end

local function next_editable_modal_row(modal, start_index)
  local rows = build_modal_rows(modal)
  for index = start_index or 1, #rows do
    if rows[index].kind ~= "repeat_add" and rows[index].kind ~= "group_add" and rows[index].kind ~= "section" and rows[index].kind ~= "note_line" then
      return index
    end
  end
  return nil
end

local function set_chain_detail_cursor(condition, detail, cursor)
  condition[detail .. "_cursor"] = cursor
end

local function set_chain_detail_scroll(condition, detail, scroll_x)
  condition[detail .. "_scroll_x"] = scroll_x
end

local function insert_chain_condition(field, condition)
  local pending = field.pending_insert and field.pending_insert.position or nil
  local operator = field.pending_insert and field.pending_insert.operator or "AND"
  local new_condition = make_chain_condition(condition)

  if not pending or #(field.groups or {}) == 0 then
    field.groups = {
      {conditions = {new_condition}},
    }
    field.selected_group_index = 1
    field.selected_condition_index = 1
    field.pending_insert = nil
    field.pending_condition = nil
    field.chooser = nil
    return new_condition
  end

  if pending.location == "start" then
    if operator == "AND" and field.groups[1] then
      table.insert(field.groups[1].conditions, 1, new_condition)
      field.selected_group_index = 1
      field.selected_condition_index = 1
    else
      table.insert(field.groups, 1, {conditions = {new_condition}})
      field.selected_group_index = 1
      field.selected_condition_index = 1
    end
  elseif pending.location == "within_group" then
    local group = field.groups[pending.left_group_index]
    local insert_at = pending.right_condition_index or ((pending.left_condition_index or 0) + 1)
    if group and operator == "AND" then
      table.insert(group.conditions, insert_at, new_condition)
      field.selected_group_index = pending.left_group_index
      field.selected_condition_index = insert_at
    elseif group then
      local left = {}
      local right = {}
      for index, existing in ipairs(group.conditions or {}) do
        if index < insert_at then
          left[#left + 1] = existing
        else
          right[#right + 1] = existing
        end
      end
      group.conditions = left
      local insert_group_index = pending.left_group_index + 1
      table.insert(field.groups, insert_group_index, {conditions = {new_condition}})
      if #right > 0 then
        table.insert(field.groups, insert_group_index + 1, {conditions = right})
      end
      field.selected_group_index = insert_group_index
      field.selected_condition_index = 1
    end
  elseif pending.location == "between_groups" then
    if operator == "AND" then
      local left_group = field.groups[pending.left_group_index]
      if left_group then
        left_group.conditions[#left_group.conditions + 1] = new_condition
        field.selected_group_index = pending.left_group_index
        field.selected_condition_index = #left_group.conditions
      end
    else
      local insert_group_index = pending.right_group_index or (#field.groups + 1)
      table.insert(field.groups, insert_group_index, {conditions = {new_condition}})
      field.selected_group_index = insert_group_index
      field.selected_condition_index = 1
    end
  elseif pending.location == "end" then
    if operator == "AND" then
      local last_group_index = pending.left_group_index or #field.groups
      local group = field.groups[last_group_index]
      if group then
        group.conditions[#group.conditions + 1] = new_condition
        field.selected_group_index = last_group_index
        field.selected_condition_index = #group.conditions
      end
    else
      field.groups[#field.groups + 1] = {conditions = {new_condition}}
      field.selected_group_index = #field.groups
      field.selected_condition_index = 1
    end
  end

  field.pending_insert = nil
  field.pending_condition = nil
  field.chooser = nil
  return new_condition
end

local function begin_condition_type_chooser(field, anchor)
  field.chooser = {
    kind = "condition_type",
    anchor = anchor,
    options = SCHEDULE_CONDITION_TYPES,
    selected = 1,
  }
end

local function begin_existing_condition_type_chooser(field)
  local condition = selected_chain_condition(field)
  if not condition then
    return false
  end
  local selected = 1
  for index, option in ipairs(SCHEDULE_CONDITION_TYPES) do
    if option == condition.type then
      selected = index
      break
    end
  end
  field.chooser = {
    kind = "existing_condition_type",
    condition_ref = {
      group_index = field.selected_group_index,
      condition_index = field.selected_condition_index,
    },
    options = SCHEDULE_CONDITION_TYPES,
    selected = selected,
  }
  return true
end

local function begin_existing_comparator_chooser(field)
  local condition = selected_chain_condition(field)
  if not condition then
    return false
  end
  local selected = 1
  for index, option in ipairs(SCHEDULE_COMPARATORS) do
    if option == condition.comparator then
      selected = index
      break
    end
  end
  field.chooser = {
    kind = "comparator",
    condition_ref = {
      group_index = field.selected_group_index,
      condition_index = field.selected_condition_index,
    },
    options = SCHEDULE_COMPARATORS,
    selected = selected,
  }
  return true
end

local function begin_station_chooser_for_arrival(state, field)
  local condition = selected_chain_condition(field)
  if not condition then
    return false
  end
  local station_ids = schedule_entry_station_ids(state.book, state.modal)
  if #station_ids == 0 then
    return false
  end
  local selected = 1
  for index, station_id in ipairs(station_ids) do
    if station_id == condition.station then
      selected = index
      break
    end
  end
  field.chooser = {
    kind = "station_chooser",
    condition_ref = {
      group_index = field.selected_group_index,
      condition_index = field.selected_condition_index,
    },
    options = station_ids,
    selected = selected,
  }
  return true
end

local function merge_all_detectors_and_done(detector_options)
  local options = {"(all detectors)"}
  for _, detector_id in ipairs(detector_options or {}) do
    options[#options + 1] = detector_id
  end
  options[#options + 1] = "(done)"
  return options
end

local function begin_scope_chooser(state, field)
  local condition = selected_chain_condition(field)
  if not condition then
    return false
  end
  local station_ids = schedule_entry_station_ids(state.book, state.modal)
  if #station_ids == 0 then
    return false
  end
  local current = scope_from_editor_text(condition.scope)
  local selected = 1
  for index, station_id in ipairs(station_ids) do
    if station_id == current.station_id then
      selected = index
      break
    end
  end
  field.chooser = {
    kind = "scope",
    condition_ref = {
      group_index = field.selected_group_index,
      condition_index = field.selected_condition_index,
    },
    stage = "station",
    station_id = nil,
    selected_detectors = {},
    all_selected = false,
    options = station_ids,
    selected = selected,
  }
  return true
end

local function apply_condition_type(condition, option)
  condition.type = tostring(option or "time_passed")
  if condition.type == "time_passed" or condition.type == "inactivity" then
    condition.seconds = tostring(condition.seconds or 0)
  elseif condition.type == "arrived_at_station" then
    condition.station = tostring(condition.station or "")
  else
    condition.comparator = tostring(condition.comparator or ">=")
    condition.value = tostring(condition.value or 0)
    condition.scope = scope_to_editor_text(scope_from_editor_text(condition.scope))
  end
end

local function choose_chain_option(state, row)
  local field = row and row.field
  local chooser = row and row.chooser
  if not field or not chooser or row.disabled then
    return false
  end

  local option = chooser.options and chooser.options[row.option_index]
  chooser.selected = row.option_index

  if chooser.kind == "operator" then
    field.pending_insert = {
      operator = option,
      position = chooser.anchor.position,
    }
    begin_condition_type_chooser(field, chooser.anchor)
    return true
  end

  if chooser.kind == "condition_type" then
    local is_metric = option == "passengers" or option == "cargo_percent" or option == "fluid_percent"
    local pending = make_chain_condition({type = option})
    if is_metric then
      field.pending_condition = pending
      field.chooser = {
        kind = "comparator",
        options = SCHEDULE_COMPARATORS,
        selected = 4,
      }
      return true
    end
    insert_chain_condition(field, pending)
    return true
  end

  if chooser.kind == "existing_condition_type" then
    local condition = field.groups[chooser.condition_ref.group_index].conditions[chooser.condition_ref.condition_index]
    if not condition then
      return false
    end
    apply_condition_type(condition, option)
    field.selected_group_index = chooser.condition_ref.group_index
    field.selected_condition_index = chooser.condition_ref.condition_index
    if condition.type == "passengers" or condition.type == "cargo_percent" or condition.type == "fluid_percent" then
      field.chooser = {
        kind = "comparator",
        condition_ref = chooser.condition_ref,
        options = SCHEDULE_COMPARATORS,
        selected = 4,
      }
    elseif condition.type == "arrived_at_station" then
      return begin_station_chooser_for_arrival(state, field)
    else
      field.chooser = nil
    end
    return true
  end

  if chooser.kind == "comparator" then
    if field.pending_condition then
      field.pending_condition.comparator = option
      insert_chain_condition(field, field.pending_condition)
      return true
    end
    if chooser.condition_ref then
      local condition = field.groups[chooser.condition_ref.group_index].conditions[chooser.condition_ref.condition_index]
      if not condition then
        return false
      end
      condition.comparator = tostring(option or ">=")
      field.selected_group_index = chooser.condition_ref.group_index
      field.selected_condition_index = chooser.condition_ref.condition_index
      field.chooser = nil
      return true
    end
    return false
  end

  if chooser.kind == "scope" then
    local condition = field.groups[chooser.condition_ref.group_index].conditions[chooser.condition_ref.condition_index]
    if not condition then
      return false
    end
    if chooser.stage == "station" then
      local station_id = chooser.options[chooser.selected]
      if not station_id then
        return false
      end
      local current = scope_from_editor_text(condition.scope)
      local selected_detectors = {}
      local all_selected = false
      if current.station_id == station_id and type(current.detector_ids) == "table" then
        for _, d in ipairs(current.detector_ids) do
          selected_detectors[d] = true
        end
      elseif current.station_id == station_id and current.all_detectors == true then
        all_selected = true
      end
      local station = state.book and state.book.STATIONS and state.book.STATIONS[station_id]
      local detector_options = {}
      for _, detector_id in ipairs(station and station.detector_ids or {}) do
        detector_options[#detector_options + 1] = detector_id
      end
      table.sort(detector_options)
      chooser.station_id = station_id
      chooser.selected_detectors = selected_detectors
      chooser.all_selected = all_selected
      chooser.options = merge_all_detectors_and_done(detector_options)
      chooser.stage = "detectors"
      chooser.selected = 1
      return true
    end

    if chooser.stage == "detectors" then
      if chooser.selected == #chooser.options then
        local text
        if chooser.all_selected then
          text = ("station:%s:all"):format(chooser.station_id)
        else
          local ids = {}
          for id in pairs(chooser.selected_detectors or {}) do
            ids[#ids + 1] = id
          end
          table.sort(ids)
          text = ("station:%s:detectors:%s"):format(chooser.station_id, table.concat(ids, ","))
        end
        condition.scope = text
        field.selected_group_index = chooser.condition_ref.group_index
        field.selected_condition_index = chooser.condition_ref.condition_index
        field.chooser = nil
        return true
      end

      if chooser.selected == 1 then
        chooser.all_selected = not chooser.all_selected
        if chooser.all_selected then
          chooser.selected_detectors = {}
        end
        return true
      end

      local detector_id = chooser.options[chooser.selected]
      if detector_id == "(all detectors)" or detector_id == "(done)" then
        return true
      end
      if chooser.selected_detectors[detector_id] then
        chooser.selected_detectors[detector_id] = nil
      else
        chooser.selected_detectors[detector_id] = true
      end
      chooser.all_selected = false
      return true
    end

    return false
  end

  if chooser.kind == "station_chooser" then
    local condition = field.groups[chooser.condition_ref.group_index].conditions[chooser.condition_ref.condition_index]
    if not condition then
      return false
    end
    condition.station = tostring(chooser.options[chooser.selected] or "")
    field.selected_group_index = chooser.condition_ref.group_index
    field.selected_condition_index = chooser.condition_ref.condition_index
    field.chooser = nil
    return true
  end

  return false
end

local function render_chain_tokens(buffer, targets, x, y, width, field, line_index, is_active)
  local lines = chain_token_lines(field, width)
  local line = lines[line_index]
  if not line then
    return
  end

  local cursor_x = x
  local prefix = is_active and ">" or " "
  render_text(buffer, cursor_x, y, prefix, 1)
  cursor_x = cursor_x + 2

  for token_index, token in ipairs(line.tokens or {}) do
    if token_index > 1 then
      cursor_x = cursor_x + 1
    end
    render_text(buffer, cursor_x, y, token.label, #token.label)
    local target = {
      x = cursor_x,
      y = y,
      width = #token.label,
      height = 1,
      modal_chain_token = token,
      modal_chain_line = line_index,
    }
    if token.kind == "condition" then
      target.id = "modal:chain:condition"
      target.modal_chain_field = field
      target.group_index = token.group_index
      target.condition_index = token.condition_index
    elseif token.kind == "plus" then
      target.id = "modal:chain:plus"
      target.modal_chain_field = field
      target.modal_chain_position = token.position
    end
    if is_valid_target(target) then
      targets[#targets + 1] = target
    end
    cursor_x = cursor_x + #token.label
  end
end

local function chain_detail_visible_value(row, available, show_cursor)
  local condition = selected_chain_condition(row.field)
  if not condition then
    return ""
  end

  if row.detail == "type" then
    return ("Condition Type: [%s]"):format(tostring(condition.type or "time_passed"))
  end
  if row.detail == "seconds" then
    local pseudo = {
      label = "Seconds",
      value = tostring(condition.seconds or ""),
      cursor = condition.seconds_cursor or (#tostring(condition.seconds or "") + 1),
      scroll_x = condition.seconds_scroll_x or 0,
    }
    local visible = modal_field_visible_value(pseudo, available, show_cursor)
    set_chain_detail_scroll(condition, "seconds", pseudo.scroll_x)
    return visible
  end
  if row.detail == "comparator" then
    return ("Comparator: [%s]"):format(tostring(condition.comparator or ">="))
  end
  if row.detail == "value" then
    local pseudo = {
      label = "Value",
      value = tostring(condition.value or ""),
      cursor = condition.value_cursor or (#tostring(condition.value or "") + 1),
      scroll_x = condition.value_scroll_x or 0,
    }
    local visible = modal_field_visible_value(pseudo, available, show_cursor)
    set_chain_detail_scroll(condition, "value", pseudo.scroll_x)
    return visible
  end
  if row.detail == "scope" then
    return ("Scope: [%s]"):format(tostring(condition.scope or "station_any_detector"))
  end
  if row.detail == "station" then
    return ("Station: [%s]"):format(tostring(condition.station or "?"))
  end
  return ""
end

local function render_modal(buffer, targets, layout, modal)
  if not modal then
    return
  end

  local width = math.max(math.min(layout.width - 6, 64), 30)
  modal.chain_wrap_width = math.max(width - 8, 12)
  local rows = build_modal_rows(modal)
  local height = math.max(math.min(#rows + 7, math.max(layout.height - 2, 10)), 10)
  local x = math.max(math.floor((layout.width - width) / 2) + 1, 2)
  local y = math.max(math.floor((layout.height - height) / 2) + 1, 2)
  local body_height = height - 5
  modal.layout_height = height

  term_ui.render_box(buffer, term_ui.box(x, y, width, height, modal.title or "Dialog"))
  ensure_modal_row_visible(modal, body_height)
  for visible_index = 1, body_height do
    local row_index = (modal.scroll_y or 0) + visible_index
    local row = rows[row_index]
    if row then
      local row_y = y + visible_index
      local prefix = row_index == modal.active_row and ">" or " "
      local is_active = row_index == modal.active_row
      if row.kind == "section" then
        render_text(buffer, x + 2, row_y, ("-- %s --"):format(tostring(row.label or "")), width - 4)
      elseif row.kind == "note_line" then
        render_text(buffer, x + 2, row_y, prefix .. tostring(row.text or ""), width - 4)
      elseif row.kind == "text" then
        render_text(buffer, x + 2, row_y, prefix .. modal_field_visible_value(row.field, width - 4, is_active), width - 4)
      elseif row.kind == "choice" then
        render_text(buffer, x + 2, row_y, prefix .. choice_visible_value(row.field), width - 4)
      elseif row.kind == "repeat_item" then
        render_text(buffer, x + 2, row_y, prefix .. repeatable_item_visible_value(row.field, row.item, width - 6, row.item_index, is_active), width - 6)
        if #row.field.items > (row.field.min_items or 1) then
          local remove_x = x + width - 6
          render_text(buffer, remove_x, row_y, "[x]", 3)
          local remove_target = {
            id = ("modal:repeat:remove:%d:%d"):format(row.field_index, row.item_index),
            x = remove_x,
            y = row_y,
            width = 3,
            height = 1,
          }
          if is_valid_target(remove_target) then
            targets[#targets + 1] = remove_target
          end
        end
      elseif row.kind == "group_item_field" then
        local first_in_item = row.subfield_index == 1
        render_text(buffer, x + 2, row_y, prefix .. group_item_field_visible_value(row.field, row.item_index, row.subfield, width - 6, is_active, first_in_item), width - 6)
        if first_in_item and #row.field.items > (row.field.min_items or 0) then
          local remove_x = x + width - 6
          render_text(buffer, remove_x, row_y, "[x]", 3)
          local remove_target = {
            id = ("modal:group:remove:%d:%d"):format(row.field_index, row.item_index),
            x = remove_x,
            y = row_y,
            width = 3,
            height = 1,
          }
          if is_valid_target(remove_target) then
            targets[#targets + 1] = remove_target
          end
        end
      elseif row.kind == "repeat_add" then
        local show_label = #(row.field.items or {}) == 0
        render_text(buffer, x + 2, row_y, prefix .. repeatable_add_visible_value(row.field, show_label), width - 4)
        local add_target = {
          id = ("modal:repeat:add:%d"):format(row.field_index),
          x = x + 1,
          y = row_y,
          width = width - 2,
          height = 1,
        }
        if is_valid_target(add_target) then
          targets[#targets + 1] = add_target
        end
      elseif row.kind == "group_add" then
        local show_label = #(row.field.items or {}) == 0
        render_text(buffer, x + 2, row_y, prefix .. repeatable_add_visible_value(row.field, show_label), width - 4)
        local add_target = {
          id = ("modal:group:add:%d"):format(row.field_index),
          x = x + 1,
          y = row_y,
          width = width - 2,
          height = 1,
        }
        if is_valid_target(add_target) then
          targets[#targets + 1] = add_target
        end
      elseif row.kind == "redstone_rule_add" then
        render_text(buffer, x + 2, row_y, prefix .. "[+ Rule]", width - 4)
        local add_target = {
          id = ("modal:redstone_rule:add:%d"):format(row.field_index),
          x = x + 1,
          y = row_y,
          width = width - 2,
          height = 1,
        }
        if is_valid_target(add_target) then
          targets[#targets + 1] = add_target
        end
      elseif row.kind == "redstone_rule_summary" then
        local output = trim(row.rule.output.value)
        render_text(buffer, x + 2, row_y, prefix .. ("Rule [%d] Output: [%s]"):format(row.rule_index, output ~= "" and output or ""), width - 8)
        local rule_target = {
          id = ("modal:redstone_rule:select:%d:%d"):format(row.field_index, row.rule_index),
          x = x + 1,
          y = row_y,
          width = width - 2,
          height = 1,
        }
        local remove_target = {
          id = ("modal:redstone_rule:remove:%d:%d"):format(row.field_index, row.rule_index),
          x = x + width - 6,
          y = row_y,
          width = 3,
          height = 1,
        }
        if is_valid_target(rule_target) then
          targets[#targets + 1] = rule_target
        end
        if is_valid_target(remove_target) then
          render_text(buffer, x + width - 6, row_y, "[x]", 3)
          targets[#targets + 1] = remove_target
        end
      elseif row.kind == "redstone_rule_summary_line" then
        render_text(buffer, x + 4, row_y, prefix .. tostring(row.text or ""), width - 6)
        local rule_target = {
          id = ("modal:redstone_rule:select:%d:%d"):format(row.field_index, row.rule_index),
          x = x + 1,
          y = row_y,
          width = width - 2,
          height = 1,
        }
        if is_valid_target(rule_target) then
          targets[#targets + 1] = rule_target
        end
      elseif row.kind == "redstone_rule_output" then
        local text = ("Output: [%s]"):format(tostring(row.rule.output.value or ""))
        if #(row.rule.output.options or {}) == 0 then
          text = "Output: [No destination-station Redstone I/Os available.]"
        end
        render_text(buffer, x + 2, row_y, prefix .. text, width - 4)
      elseif row.kind == "chain_tokens" then
        render_chain_tokens(buffer, targets, x + 1, row_y, width - 3, row.field, row.line_index, is_active)
      elseif row.kind == "chain_condition_detail" then
        render_text(buffer, x + 2, row_y, prefix .. chain_detail_visible_value(row, width - 6, is_active), width - 6)
      elseif row.kind == "chain_chooser" then
        local marker
        if row.disabled then
          marker = " - "
        elseif row.checked ~= nil then
          marker = row.checked and "[x]" or "[ ]"
        else
          marker = ((row.option_index or 0) == (row.chooser.selected or 0) and "[x]" or "[ ]")
        end
        render_text(buffer, x + 2, row_y, prefix .. marker .. " " .. tostring(row.option or ""), width - 4)
        if not row.disabled then
          local chooser_target = {
            id = ("modal:chain:chooser:%d:%d"):format(row.field_index, row.option_index or 0),
            x = x + 1,
            y = row_y,
            width = width - 2,
            height = 1,
            modal_chain_field = row.field,
          }
          if is_valid_target(chooser_target) then
            targets[#targets + 1] = chooser_target
          end
        end
      elseif row.kind == "choice_chooser" then
        local marker = ((row.option_index or 0) == (row.chooser.selected or 0)) and "[x]" or "[ ]"
        render_text(buffer, x + 2, row_y, prefix .. marker .. " " .. tostring(row.option or ""), width - 4)
        local chooser_target = {
          id = ("modal:choice:chooser:%d"):format(row.option_index or 0),
          x = x + 1,
          y = row_y,
          width = width - 2,
          height = 1,
        }
        if is_valid_target(chooser_target) then
          targets[#targets + 1] = chooser_target
        end
      end

      local row_target = {
        id = ("modal:row:%d"):format(row_index),
        x = x + 1,
        y = row_y,
        width = width - 2,
        height = 1,
        modal_row_index = row_index,
      }
      if is_valid_target(row_target) then
        targets[#targets + 1] = row_target
      end
    end
  end

  local confirm = term_ui.button("modal:confirm", "Confirm", x + 2, y + height - 2, 12)
  local cancel = term_ui.button("modal:cancel", "Cancel", x + 16, y + height - 2, 10)
  add_targets(targets, term_ui.render_buttons(buffer, {confirm, cancel}))
end

local function open_modal(state, spec)
  local fields = {}
  for _, field in ipairs(spec.fields or {}) do
    fields[#fields + 1] = field
  end
  state.modal = {
    title = spec.title,
    fields = fields,
    active_row = 1,
    scroll_y = 0,
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
  local values = collect_modal_values(state.modal)
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
          make_text_field({key = "id", label = "Detector ID"}),
          make_text_field({key = "label", label = "Label"}),
          make_text_field({key = "address", label = "Address"}),
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
          make_text_field({key = "label", label = "Label", value = detector.label or id}),
          make_text_field({key = "address", label = "Address", value = detector.address or ""}),
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
          make_text_field({key = "id", label = "Station ID"}),
          make_text_field({key = "name", label = "Name"}),
          make_text_field({key = "x", label = "X", value = "0"}),
          make_text_field({key = "y", label = "Y", value = "64"}),
          make_text_field({key = "z", label = "Z", value = "0"}),
          make_repeatable_text_field({key = "detector_ids", label = "Detector IDs", values = {""}, min_items = 1}),
          make_repeatable_group_field({
            key = "redstone_outputs",
            label = "Redstone I/Os",
            min_items = 0,
            item_fields = {
              {key = "id", label = "ID", default = ""},
              {key = "address", label = "Address", default = ""},
              {key = "side", label = "Side", default = "north", options = REDSTONE_SIDE_OPTIONS},
              {key = "strength", label = "Strength", default = "15"},
              {key = "pulse_ticks", label = "Pulse", default = "20"},
              {key = "active_high", label = "Active High", default = "true", options = BOOLEAN_OPTIONS},
            },
            items = {},
          }),
        },
        on_submit = function(current_state, values)
          if values.id == "" then
            return false, "Station ID required"
          end
          local outputs_ok, outputs_error = validate_redstone_output_rows(values.redstone_outputs)
          if not outputs_ok then
            return false, outputs_error
          end
          current_state.book.STATIONS[values.id] = {
            display_name = values.name ~= "" and values.name or values.id,
            x = tonumber(values.x) or 0,
            y = tonumber(values.y) or 64,
            z = tonumber(values.z) or 0,
            detector_ids = collect_detector_ids(values),
            redstone_outputs = collect_redstone_outputs(values),
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
          make_text_field({key = "name", label = "Name", value = station.display_name or id}),
          make_text_field({key = "x", label = "X", value = tostring(station.x or 0)}),
          make_text_field({key = "y", label = "Y", value = tostring(station.y or 64)}),
          make_text_field({key = "z", label = "Z", value = tostring(station.z or 0)}),
          make_repeatable_text_field({key = "detector_ids", label = "Detector IDs", values = station.detector_ids or {""}, min_items = 1}),
          make_repeatable_group_field({
            key = "redstone_outputs",
            label = "Redstone I/Os",
            min_items = 0,
            item_fields = {
              {key = "id", label = "ID", default = ""},
              {key = "address", label = "Address", default = ""},
              {key = "side", label = "Side", default = "north", options = REDSTONE_SIDE_OPTIONS},
              {key = "strength", label = "Strength", default = "15"},
              {key = "pulse_ticks", label = "Pulse", default = "20"},
              {key = "active_high", label = "Active High", default = "true", options = BOOLEAN_OPTIONS},
            },
            items = redstone_output_rows_from_station(station),
          }),
        },
        on_submit = function(current_state, values)
          local outputs_ok, outputs_error = validate_redstone_output_rows(values.redstone_outputs)
          if not outputs_ok then
            return false, outputs_error
          end
          station.display_name = values.name ~= "" and values.name or id
          station.x = tonumber(values.x) or station.x or 0
          station.y = tonumber(values.y) or station.y or 64
          station.z = tonumber(values.z) or station.z or 0
          station.detector_ids = collect_detector_ids(values)
          station.redstone_outputs = collect_redstone_outputs(values)
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
          make_text_field({key = "id", label = "Route ID"}),
          make_text_field({key = "from", label = "From Station"}),
          make_text_field({key = "to", label = "To Station"}),
          make_repeatable_text_field({key = "waypoints", label = "Via", values = {""}, min_items = 0}),
          make_text_field({key = "cruise_kmh", label = "Cruise km/h", value = "40"}),
          make_text_field({key = "stop_buffer_m", label = "Stop buffer", value = "2"}),
          make_text_field({key = "profile", label = "Profile", value = "conservative"}),
        },
        on_submit = function(current_state, values)
          if values.id == "" then
            return false, "Route ID required"
          end
          current_state.book.ROUTES[values.id] = {
            from = trim(values.from),
            to = trim(values.to),
            via = collect_waypoints(values),
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
      open_modal(state, {
        title = "Edit Route",
        fields = {
          make_text_field({key = "from", label = "From Station", value = tostring(route.from or "")}),
          make_text_field({key = "to", label = "To Station", value = tostring(route.to or "")}),
          make_repeatable_text_field({key = "waypoints", label = "Via", values = route_via_rows(route), min_items = 0}),
          make_text_field({key = "cruise_kmh", label = "Cruise km/h", value = tostring(route.cruise_kmh or 40)}),
          make_text_field({key = "stop_buffer_m", label = "Stop buffer", value = tostring(route.stop_buffer_m or 2)}),
          make_text_field({key = "profile", label = "Profile", value = route.profile or "conservative"}),
        },
        on_submit = function(current_state, values)
          route.from = trim(values.from) ~= "" and trim(values.from) or nil
          route.to = trim(values.to) ~= "" and trim(values.to) or nil
          route.via = collect_waypoints(values)
          route.waypoints = nil
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
          make_text_field({key = "id", label = "Schedule ID"}),
          make_section_field("Schedule Settings"),
          make_repeatable_text_field({key = "entries", label = "Entries station | route", values = {""}, min_items = 1}),
          make_choice_field({key = "cyclic", label = "Cyclic", value = "false", options = BOOLEAN_OPTIONS}),
          make_section_field("Wait Conditions"),
          make_condition_chain_field(nil),
          make_section_field("Redstone Rules"),
          make_redstone_rules_field(nil, state.book),
        },
        on_submit = function(current_state, values)
          if values.id == "" then
            return false, "Schedule ID required"
          end
          current_state.book.SCHEDULES[values.id] = {
            cyclic = values.cyclic == "true",
            entries = {},
          }
          for _, ref in ipairs(collect_schedule_entry_refs(values)) do
            current_state.book.SCHEDULES[values.id].entries[#current_state.book.SCHEDULES[values.id].entries + 1] = {
              station = ref.station,
              route = ref.route,
                wait = {
                  groups = values.wait_chain.groups,
                },
                redstone = {
                  rules = values.redstone_rules or {},
                },
            }
          end
          current_state.dirty = true
          return true, "Schedule added"
        end,
      })
      return true
    end

    local id = current_schedule_id(state)
    local schedule = id and state.book.SCHEDULES[id]
    if action == "edit" and schedule then
      local first_entry = schedule.entries and schedule.entries[1] or nil
      local legacy_refs = legacy_redstone_refs(first_entry)
      local edit_fields = {
        make_section_field("Schedule Settings"),
        make_repeatable_text_field({key = "entries", label = "Entries station | route", values = schedule_entry_rows(schedule), min_items = 1}),
        make_choice_field({key = "cyclic", label = "Cyclic", value = tostring(schedule.cyclic == true), options = BOOLEAN_OPTIONS}),
      }
      if #legacy_refs > 0 then
        edit_fields[#edit_fields + 1] = make_note_field("Legacy Redstone Warning", {
          "Legacy per-condition redstone detected.",
          "Editor writes only entry.redstone.rules on save.",
          table.concat(legacy_refs, "; "),
        })
      end
      edit_fields[#edit_fields + 1] = make_section_field("Wait Conditions")
      edit_fields[#edit_fields + 1] = make_condition_chain_field(schedule)
      edit_fields[#edit_fields + 1] = make_section_field("Redstone Rules")
      edit_fields[#edit_fields + 1] = make_redstone_rules_field(schedule, state.book)
      open_modal(state, {
        title = "Edit Schedule",
        fields = edit_fields,
        on_submit = function(current_state, values)
          schedule.cyclic = values.cyclic == "true"
          local refs = collect_schedule_entry_refs(values)
          local next_entries = {}
          for index, ref in ipairs(refs) do
            local previous = schedule.entries and schedule.entries[index] or {}
            next_entries[#next_entries + 1] = {
              station = ref.station,
              route = ref.route,
              wait = {
                groups = index == 1 and values.wait_chain.groups or (previous.wait and previous.wait.groups) or values.wait_chain.groups,
              },
              redstone = {
                rules = index == 1 and (values.redstone_rules or {}) or (previous.redstone and previous.redstone.rules) or {},
              },
            }
          end
          schedule.entries = next_entries
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

local function render_primary_split(buffer, targets, list_rect, detail_rect, title, items, selected_index, area, detail_lines, detail_scroll)
  term_ui.render_box(buffer, term_ui.box(list_rect.x, list_rect.y, list_rect.width, list_rect.height, title))
  add_targets(targets, term_ui.render_list(buffer, list_rect.x + 2, list_rect.y + 2, list_rect.width - 4, items, selected_index, math.max(list_rect.height - 4, 1)), {area = area})
  term_ui.render_box(buffer, term_ui.box(detail_rect.x, detail_rect.y, detail_rect.width, detail_rect.height, title .. " Details"))
  local detail_height = math.max(detail_rect.height - 3, 0)
  render_wrapped_lines(buffer, detail_rect.x + 2, detail_rect.y + 2, detail_rect.width - 4, detail_height, detail_lines, detail_scroll or 0)
end

local function build_screen(state, width, height)
  width = math.max(width or 100, 1)
  height = math.max(height or 32, 1)
  local layout = layout_for(width, height)
  local buffer = {}
  local targets = {}
  local modal_targets = {}

  if layout.tier == "minimum" then
    render_minimum_screen(buffer, layout)
    if state.modal then
      render_modal(buffer, modal_targets, layout, state.modal)
    end
    return {
      buffer = buffer,
      targets = targets,
      modal_targets = modal_targets,
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
      render_primary_split(buffer, targets, layout.left, layout.right, "Known Detectors", items, selected_index, "detectors", detail_lines, state.panel_scrolls.detector_detail)
    else
      render_primary_split(buffer, targets, layout.primary_list, layout.primary_detail, "Detectors", items, selected_index, "detectors", detail_lines, state.panel_scrolls.detector_detail)
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
      if #(station.detector_ids or {}) == 0 then
        detail_lines[#detail_lines + 1] = "  (none)"
      end
      detail_lines[#detail_lines + 1] = "Redstone outputs:"
      local output_names = sorted_keys(station.redstone_outputs or {})
      if #output_names == 0 then
        detail_lines[#detail_lines + 1] = "  (none)"
      else
        for _, output_name in ipairs(output_names) do
          local output = station.redstone_outputs[output_name] or {}
          detail_lines[#detail_lines + 1] = ("  %s @ %s -> %s strength=%s pulse_ticks=%s active_high=%s"):format(
            output_name,
            tostring(output.address or "<primary>"),
            tostring(output.side or "?"),
            tostring(output.strength ~= nil and output.strength or 15),
            tostring(output.pulse_ticks ~= nil and output.pulse_ticks or 20),
            tostring(output.active_high ~= false)
          )
        end
      end
    end
    if layout.tier == "comfort" then
      render_primary_split(buffer, targets, layout.left, layout.right, "Stations", items, selected_index, "stations", detail_lines, state.panel_scrolls.station_detail)
    else
      render_primary_split(buffer, targets, layout.primary_list, layout.primary_detail, "Stations", items, selected_index, "stations", detail_lines, state.panel_scrolls.station_detail)
    end
  elseif state.active_tab == 3 then
    local items = route_items(state.book)
    local selected, selected_index = selected_from(items, state.selections.routes)
    local detail_lines = {}
    if selected then
      local route = state.book.ROUTES[selected.id]
      detail_lines = {
        ("Route: %s"):format(selected.id),
        ("From: %s"):format(route.from or "<legacy>"),
        ("To: %s"):format(route.to or route_destination_station_id(state.book, selected.id) or "<unknown>"),
        ("Profile: %s"):format(route.profile or "conservative"),
      }
      local via = route.via or route.waypoints or {}
      for index, waypoint in ipairs(via) do
        local waypoint_text = type(waypoint) == "string" and waypoint or ("%s,%s,%s"):format(waypoint.x, waypoint.y, waypoint.z)
        detail_lines[#detail_lines + 1] = ("Via [%d] %s"):format(index, waypoint_text)
      end
    end
    if layout.tier == "comfort" then
      render_primary_split(buffer, targets, layout.left, layout.right, "Routes", items, selected_index, "routes", detail_lines, state.panel_scrolls.route_detail)
    else
      render_primary_split(buffer, targets, layout.primary_list, layout.primary_detail, "Routes", items, selected_index, "routes", detail_lines, state.panel_scrolls.route_detail)
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
      local entry_lines = {}
      for index, entry in ipairs(schedule.entries or {}) do
        entry_lines[#entry_lines + 1] = ("[%d] station=%s route=%s"):format(index, entry.station or "-", entry.route or "<auto>")
      end
      render_wrapped_lines(buffer, layout.schedule_entries.x + 2, layout.schedule_entries.y + 2, layout.schedule_entries.width - 4, math.max(layout.schedule_entries.height - 3, 0), entry_lines, state.panel_scrolls.schedule_entries)
      local first_entry = schedule.entries and schedule.entries[1]
      if first_entry then
        local wait_lines = {}
        for group_index, group in ipairs(first_entry.wait and first_entry.wait.groups or {}) do
          wait_lines[#wait_lines + 1] = ("Group %s"):format(group_label(group_index))
          for condition_index, condition in ipairs(group or {}) do
            if condition.type == "time_passed" or condition.type == "inactivity" then
              wait_lines[#wait_lines + 1] = ("  [%d] %s %ss"):format(
                condition_index,
                tostring(condition.type or "?"),
                tostring(condition.seconds or 0)
              )
            else
              wait_lines[#wait_lines + 1] = ("  [%d] %s %s %s %s"):format(
                condition_index,
                tostring(condition.type or "?"),
                tostring(condition.comparator or ">="),
                tostring(condition.value or 0),
                scope_to_editor_text(condition.scope)
              )
            end
          end
        end
        for rule_index, rule in ipairs(first_entry.redstone and first_entry.redstone.rules or {}) do
          wait_lines[#wait_lines + 1] = ("Rule %s -> %s"):format(group_label(rule_index), tostring(rule.output or "?"))
          for group_index, group in ipairs(rule.groups or {}) do
            wait_lines[#wait_lines + 1] = ("  Group %s"):format(group_label(group_index))
            for condition_index, condition in ipairs(group or {}) do
              if condition.type == "time_passed" or condition.type == "inactivity" then
                wait_lines[#wait_lines + 1] = ("    [%d] %s %ss"):format(condition_index, tostring(condition.type or "?"), tostring(condition.seconds or 0))
              else
                wait_lines[#wait_lines + 1] = ("    [%d] %s %s %s %s"):format(
                  condition_index,
                  tostring(condition.type or "?"),
                  tostring(condition.comparator or ">="),
                  tostring(condition.value or 0),
                  scope_to_editor_text(condition.scope)
                )
              end
            end
          end
        end
        render_wrapped_lines(buffer, layout.schedule_wait.x + 2, layout.schedule_wait.y + 2, layout.schedule_wait.width - 4, math.max(layout.schedule_wait.height - 3, 0), wait_lines, state.panel_scrolls.schedule_wait)
      end
    end
  else
    term_ui.render_box(buffer, term_ui.box(layout.save.x, layout.save.y, layout.save.width, layout.save.height, "Save / Validate"))
    local validation = station_dispatch.validate_route_book(state.book)
    local runtime_info = inspect_redstone_runtime(state.book)
    local save_lines = {
      ("Dirty: %s"):format(state.dirty and "[*]" or "[ ]"),
      ("Validation: %s"):format(validation.ok and "OK" or "Errors"),
    }
    for index, message in ipairs(validation.errors or {}) do
      save_lines[#save_lines + 1] = "ERROR: " .. tostring(message)
    end
    save_lines[#save_lines + 1] = ""
    save_lines[#save_lines + 1] = "Run schedule: station_dispatch run <schedule>"
    save_lines[#save_lines + 1] = "Run route:    train_controller route <route>"
    save_lines[#save_lines + 1] = "Schedules run on the active ir_remote_control train."
    save_lines[#save_lines + 1] = "Schedule redstone binds by I/O ID to the destination station."
    save_lines[#save_lines + 1] = "Station I/O address selects which redstone module is used."
    save_lines[#save_lines + 1] = ""
    save_lines[#save_lines + 1] = ("Redstone runtime: %s"):format(runtime_info.required and "required" or "not required")
    save_lines[#save_lines + 1] = ("Primary component.redstone: %s"):format(runtime_info.component_present and "available" or "missing")
    if runtime_info.required and not runtime_info.component_present then
      save_lines[#save_lines + 1] = "station_dispatch run <schedule> will fail until a redstone component is installed."
    end
    save_lines[#save_lines + 1] = "Conditions in a group are AND."
    save_lines[#save_lines + 1] = "Groups are OR."
    save_lines[#save_lines + 1] = "Click [+] to add a condition, then choose AND or OR before the next one."
    save_lines[#save_lines + 1] = "Comparator-based conditions open a comparator chooser before returning."
    save_lines[#save_lines + 1] = "Wait controls departure. Redstone rules are separate."
    save_lines[#save_lines + 1] = "Redstone rule outputs come from every entry station's I/Os."
    for index = 1, math.min(#runtime_info.condition_refs, 3) do
      local item = runtime_info.condition_refs[index]
      save_lines[#save_lines + 1] = ("uses redstone: %s entry %d -> %s (%s)"):format(
        item.schedule,
        item.entry,
        item.output,
        item.mode
      )
    end
    if #runtime_info.condition_refs > 3 then
      save_lines[#save_lines + 1] = ("... and %d more redstone-linked conditions"):format(#runtime_info.condition_refs - 3)
    end
    render_wrapped_lines(buffer, layout.save.x + 2, layout.save.y + 2, layout.save.width - 4, math.max(layout.save.height - 3, 0), save_lines, state.panel_scrolls.save)
  end

  add_targets(targets, term_ui.render_buttons(buffer, make_action_buttons(layout)))
  render_text(buffer, 3, layout.status_y, state.message or "", math.max(width - 4, 1))

  if state.modal then
    render_modal(buffer, modal_targets, layout, state.modal)
  end

  return {
    buffer = buffer,
    targets = targets,
    modal_targets = modal_targets,
    layout = layout,
  }
end

local function handle_click(state, x, y, screen)
  if type(x) ~= "number" or type(y) ~= "number" or type(screen) ~= "table" then
    return false
  end

  local active_targets = state.modal and screen.modal_targets or screen.targets
  if type(active_targets) ~= "table" then
    return false
  end

  local fallback_row_target = nil
  for index = #active_targets, 1, -1 do
    local target = active_targets[index]
    if term_ui.hit(target, x, y) then
      if state.modal then
        if type(target.id) == "string" and target.id:match("^modal:row:") then
          fallback_row_target = target
          goto continue
        end
        if target.id == "modal:chain:plus" and target.modal_chain_field then
          local field = target.modal_chain_field
          field.chooser = {
            kind = "operator",
            anchor = {
              position = target.modal_chain_position,
            },
            options = {"AND", "OR"},
            selected = 1,
          }
          return true
        end
        if target.id == "modal:chain:condition" and target.modal_chain_field then
          local field = target.modal_chain_field
          field.selected_group_index = tonumber(target.group_index)
          field.selected_condition_index = tonumber(target.condition_index)
          field.chooser = nil
          return true
        end
        if target.id and target.id:match("^modal:chain:chooser:") then
          local option_index = tonumber(target.id:match("^modal:chain:chooser:%d+:(%d+)$"))
          local field = target.modal_chain_field
          if field and option_index then
            local chooser_row = {
              field = field,
              chooser = field.chooser,
              option_index = option_index,
            }
            return choose_chain_option(state, chooser_row)
          end
        end
        if target.id and target.id:match("^modal:choice:chooser:") then
          local option_index = tonumber(target.id:match("^modal:choice:chooser:(%d+)$"))
          local chooser = state.modal.choice_chooser
          if chooser and option_index and chooser.options[option_index] ~= nil then
            chooser.selected = option_index
            chooser.field.value = tostring(chooser.options[option_index])
            state.modal.choice_chooser = nil
            return true
          end
        end
        if target.id and target.id:match("^modal:redstone_rule:add:") then
          local field_index = tonumber(target.id:match("^modal:redstone_rule:add:(%d+)$"))
          local field = state.modal.fields[field_index]
          if field then
            field.rules[#field.rules + 1] = make_redstone_rule(nil, field.book)
            field.selected_rule_index = #field.rules
            return true
          end
        end
        if target.id and target.id:match("^modal:redstone_rule:select:") then
          local field_index, rule_index = target.id:match("^modal:redstone_rule:select:(%d+):(%d+)$")
          local field = state.modal.fields[tonumber(field_index or 0)]
          if field and rule_index then
            field.selected_rule_index = tonumber(rule_index)
            return true
          end
        end
        if target.id and target.id:match("^modal:redstone_rule:remove:") then
          local field_index, rule_index = target.id:match("^modal:redstone_rule:remove:(%d+):(%d+)$")
          local field = state.modal.fields[tonumber(field_index or 0)]
          local index_to_remove = tonumber(rule_index)
          if field and index_to_remove and field.rules[index_to_remove] then
            table.remove(field.rules, index_to_remove)
            if #field.rules == 0 then
              field.selected_rule_index = nil
            else
              field.selected_rule_index = clamp(field.selected_rule_index or 1, 1, #field.rules)
            end
            return true
          end
        end
        if target.id and target.id:match("^modal:group:add:") then
          local field_index = tonumber(target.id:match("modal:group:add:(%d+)"))
          insert_repeatable_item(state.modal, field_index, #state.modal.fields[field_index].items)
          return true
        end
        if target.id and target.id:match("^modal:group:remove:") then
          local field_index, item_index = target.id:match("modal:group:remove:(%d+):(%d+)")
          if field_index and item_index then
            remove_repeatable_item(state.modal, tonumber(field_index), tonumber(item_index))
            return true
          end
        end
        if target.id and target.id:match("^modal:repeat:add:") then
          local field_index = tonumber(target.id:match("modal:repeat:add:(%d+)"))
          insert_repeatable_item(state.modal, field_index, #state.modal.fields[field_index].items)
          return true
        end
        if target.id and target.id:match("^modal:repeat:remove:") then
          local field_index, item_index = target.id:match("modal:repeat:remove:(%d+):(%d+)")
          if field_index and item_index then
            remove_repeatable_item(state.modal, tonumber(field_index), tonumber(item_index))
            return true
          end
        end
        if target.id == "modal:confirm" then
          submit_modal(state)
          return true
        end
        if target.id == "modal:cancel" then
          close_modal(state, "Canceled")
          return true
        end
        if target.modal_row_index then
          state.modal.active_row = target.modal_row_index
          local clicked_row = build_modal_rows(state.modal)[target.modal_row_index]
          if clicked_row and clicked_row.kind == "choice" then
            return open_choice_chooser(state.modal, clicked_row.field)
          end
          if clicked_row and clicked_row.kind == "group_item_field" and clicked_row.subfield.kind == "choice" then
            return open_choice_chooser(state.modal, clicked_row.subfield)
          end
          if clicked_row and clicked_row.kind == "redstone_rule_output" then
            refresh_rule_output_options(state.modal, clicked_row.rule)
            return open_choice_chooser(state.modal, clicked_row.rule.output)
          end
          if clicked_row and clicked_row.kind == "chain_condition_detail" then
            if clicked_row.detail == "type" then
              return begin_existing_condition_type_chooser(clicked_row.field)
            end
            if clicked_row.detail == "comparator" then
              return begin_existing_comparator_chooser(clicked_row.field)
            end
            if clicked_row.detail == "scope" then
              return begin_scope_chooser(state, clicked_row.field)
            end
            if clicked_row.detail == "station" then
              return begin_station_chooser_for_arrival(state, clicked_row.field)
            end
          end
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
    ::continue::
  end

  if state.modal and fallback_row_target and fallback_row_target.modal_row_index then
    state.modal.active_row = fallback_row_target.modal_row_index
    local clicked_row = build_modal_rows(state.modal)[fallback_row_target.modal_row_index]
    if clicked_row and clicked_row.kind == "choice" then
      return open_choice_chooser(state.modal, clicked_row.field)
    end
    if clicked_row and clicked_row.kind == "group_item_field" and clicked_row.subfield.kind == "choice" then
      return open_choice_chooser(state.modal, clicked_row.subfield)
    end
    if clicked_row and clicked_row.kind == "redstone_rule_output" then
      refresh_rule_output_options(state.modal, clicked_row.rule)
      return open_choice_chooser(state.modal, clicked_row.rule.output)
    end
    if clicked_row and clicked_row.kind == "chain_condition_detail" then
      if clicked_row.detail == "type" then
        return begin_existing_condition_type_chooser(clicked_row.field)
      end
      if clicked_row.detail == "comparator" then
        return begin_existing_comparator_chooser(clicked_row.field)
      end
      if clicked_row.detail == "scope" then
        return begin_scope_chooser(state, clicked_row.field)
      end
      if clicked_row.detail == "station" then
        return begin_station_chooser_for_arrival(state, clicked_row.field)
      end
    end
    return true
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

local function handle_scroll(state, direction, x, y, screen)
  if state.modal then
    local rows = build_modal_rows(state.modal)
    if #rows == 0 then
      return false
    end
    local body_height = math.max(math.min((state.modal.layout_height or 10) - 5, #rows), 1)
    local max_scroll = math.max(#rows - body_height, 0)
    state.modal.scroll_y = clamp((state.modal.scroll_y or 0) + direction, 0, max_scroll)
    return true
  end
  local layout = screen and screen.layout or nil
  if layout and x and y then
    if state.active_tab == 5 and term_ui.hit(layout.save, x, y) then
      state.panel_scrolls.save = math.max((state.panel_scrolls.save or 0) + direction, 0)
      return true
    end
    if state.active_tab == 4 then
      if term_ui.hit(layout.schedule_entries, x, y) then
        state.panel_scrolls.schedule_entries = math.max((state.panel_scrolls.schedule_entries or 0) + direction, 0)
        return true
      end
      if term_ui.hit(layout.schedule_wait, x, y) then
        state.panel_scrolls.schedule_wait = math.max((state.panel_scrolls.schedule_wait or 0) + direction, 0)
        return true
      end
    elseif state.active_tab == 1 then
      local detail_rect = layout.tier == "comfort" and layout.right or layout.primary_detail
      if detail_rect and term_ui.hit(detail_rect, x, y) then
        state.panel_scrolls.detector_detail = math.max((state.panel_scrolls.detector_detail or 0) + direction, 0)
        return true
      end
    elseif state.active_tab == 2 then
      local detail_rect = layout.tier == "comfort" and layout.right or layout.primary_detail
      if detail_rect and term_ui.hit(detail_rect, x, y) then
        state.panel_scrolls.station_detail = math.max((state.panel_scrolls.station_detail or 0) + direction, 0)
        return true
      end
    elseif state.active_tab == 3 then
      local detail_rect = layout.tier == "comfort" and layout.right or layout.primary_detail
      if detail_rect and term_ui.hit(detail_rect, x, y) then
        state.panel_scrolls.route_detail = math.max((state.panel_scrolls.route_detail or 0) + direction, 0)
        return true
      end
    end
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

local function current_chain_text_cell(state)
  local row = select(1, current_modal_row(state))
  if not row or row.kind ~= "chain_condition_detail" then
    return nil
  end
  if row.detail ~= "seconds" and row.detail ~= "value" then
    return nil
  end
  local condition = selected_chain_condition(row.field)
  if not condition then
    return nil
  end
  return {
    kind = "chain_detail",
    condition = condition,
    detail = row.detail,
  }
end

local function chain_text_value(cell)
  return tostring(cell.condition[cell.detail] or "")
end

local function chain_text_cursor(cell)
  return cell.condition[cell.detail .. "_cursor"] or (#chain_text_value(cell) + 1)
end

local function set_chain_text_cursor(cell, cursor)
  set_chain_detail_cursor(cell.condition, cell.detail, cursor)
end

local function insert_into_chain_text(cell, text)
  text = tostring(text or "")
  local value = chain_text_value(cell)
  local cursor = clamp(chain_text_cursor(cell), 1, #value + 1)
  cell.condition[cell.detail] = value:sub(1, cursor - 1) .. text .. value:sub(cursor)
  set_chain_text_cursor(cell, cursor + #text)
end

local function delete_left_chain_text(cell)
  local value = chain_text_value(cell)
  local cursor = clamp(chain_text_cursor(cell), 1, #value + 1)
  if cursor <= 1 then
    return
  end
  cell.condition[cell.detail] = value:sub(1, cursor - 2) .. value:sub(cursor)
  set_chain_text_cursor(cell, cursor - 1)
end

local function delete_right_chain_text(cell)
  local value = chain_text_value(cell)
  local cursor = clamp(chain_text_cursor(cell), 1, #value + 1)
  if cursor > #value then
    return
  end
  cell.condition[cell.detail] = value:sub(1, cursor - 1) .. value:sub(cursor + 1)
end

local function handle_clipboard(state, text)
  local chain_cell = current_chain_text_cell(state)
  if chain_cell then
    insert_into_chain_text(chain_cell, normalize_clipboard_text(text))
    return true
  end
  local field = current_modal_text_cell(state)
  if not field then
    return false
  end
  insert_into_field(field, normalize_clipboard_text(text))
  return true
end

local function handle_key_down(state, char_code, key_code)
  if not state.modal then
    return false
  end

  local row = select(1, current_modal_row(state))
  local chain_cell = current_chain_text_cell(state)
  local field = current_modal_text_cell(state)
  if not row and key_code ~= KEY.esc then
    return false
  end

  if chain_cell and control_down() and key_code == KEY.c then
    state.editor_clipboard = chain_text_value(chain_cell)
    state.message = "Field copied"
    return true
  end
  if chain_cell and control_down() and key_code == KEY.v then
    insert_into_chain_text(chain_cell, normalize_clipboard_text(state.editor_clipboard))
    return true
  end
  if field and control_down() and key_code == KEY.c then
    state.editor_clipboard = field.value
    state.message = "Field copied"
    return true
  end
  if field and control_down() and key_code == KEY.v then
    insert_into_field(field, normalize_clipboard_text(state.editor_clipboard))
    return true
  end

  if key_code == KEY.esc then
    close_modal(state, "Canceled")
    return true
  end
  if key_code == KEY.up then
    return move_modal_row(state, -1)
  end
  if key_code == KEY.down then
    return move_modal_row(state, 1)
  end
  if key_code == KEY.tab then
    local next_row = next_editable_modal_row(state.modal, (state.modal.active_row or 1) + 1)
    state.modal.active_row = next_row or next_editable_modal_row(state.modal, 1) or state.modal.active_row
    return true
  end
  if key_code == KEY.enter then
    if row and row.kind == "chain_chooser" and not row.disabled then
      return choose_chain_option(state, row)
    end
    if row and row.kind == "choice_chooser" then
      local chooser = row.chooser
      chooser.field.value = tostring(chooser.options[row.option_index])
      state.modal.choice_chooser = nil
      return true
    end
    if row and row.kind == "choice" then
      return open_choice_chooser(state.modal, row.field)
    end
    if row and row.kind == "group_item_field" and row.subfield.kind == "choice" then
      return open_choice_chooser(state.modal, row.subfield)
    end
    if row and row.kind == "redstone_rule_output" then
      refresh_rule_output_options(state.modal, row.rule)
      return open_choice_chooser(state.modal, row.rule.output)
    end
    if row and row.kind == "chain_tokens" then
      return true
    end
    if row and row.kind == "chain_condition_detail" then
      if row.detail == "type" then
        return begin_existing_condition_type_chooser(row.field)
      end
      if row.detail == "comparator" then
        return begin_existing_comparator_chooser(row.field)
      end
      if row.detail == "scope" then
        return begin_scope_chooser(state, row.field)
      end
    end
    if row and row.kind == "redstone_rule_add" then
      row.field.rules[#row.field.rules + 1] = make_redstone_rule(nil, row.field.book)
      row.field.selected_rule_index = #row.field.rules
      return true
    end
    if row and (row.kind == "repeat_add" or row.kind == "group_add") then
      insert_repeatable_item(state.modal, row.field_index, #(row.field.items or {}))
      return true
    end
    local next_row = next_editable_modal_row(state.modal, (state.modal.active_row or 1) + 1)
    if next_row then
      state.modal.active_row = next_row
      return true
    end
    submit_modal(state)
    return true
  end
  if key_code == KEY.space then
    if row and row.kind == "chain_chooser" and not row.disabled then
      return choose_chain_option(state, row)
    end
    if row and row.kind == "choice_chooser" then
      local chooser = row.chooser
      chooser.field.value = tostring(chooser.options[row.option_index])
      state.modal.choice_chooser = nil
      return true
    end
    return false
  end
  if key_code == KEY.left then
    if row and row.kind == "chain_chooser" and not row.disabled then
      row.chooser.selected = clamp((row.chooser.selected or 1) - 1, 1, #(row.chooser.options or {}))
      local target_row = find_modal_row_index(state.modal, function(candidate)
        return candidate.kind == "chain_chooser"
          and candidate.field_index == row.field_index
          and candidate.option_index == row.chooser.selected
      end)
      state.modal.active_row = target_row or state.modal.active_row
      return true
    end
    if row and row.kind == "choice_chooser" then
      row.chooser.selected = clamp((row.chooser.selected or 1) - 1, 1, #(row.chooser.options or {}))
      local target_row = find_modal_row_index(state.modal, function(candidate)
        return candidate.kind == "choice_chooser"
          and candidate.option_index == row.chooser.selected
      end)
      state.modal.active_row = target_row or state.modal.active_row
      return true
    end
    if row and row.kind == "choice" then
      return false
    end
    if row and row.kind == "group_item_field" and row.subfield.kind == "choice" then
      return false
    end
    if row and row.kind == "chain_condition_detail" and (row.detail == "type" or row.detail == "comparator" or row.detail == "scope") then
      return true
    end
    if chain_cell then
      set_chain_text_cursor(chain_cell, clamp(chain_text_cursor(chain_cell) - 1, 1, #chain_text_value(chain_cell) + 1))
      return true
    end
    if not field then
      return false
    end
    field.cursor = clamp((field.cursor or 1) - 1, 1, #field.value + 1)
    return true
  end
  if key_code == KEY.right then
    if row and row.kind == "chain_chooser" and not row.disabled then
      row.chooser.selected = clamp((row.chooser.selected or 1) + 1, 1, #(row.chooser.options or {}))
      local target_row = find_modal_row_index(state.modal, function(candidate)
        return candidate.kind == "chain_chooser"
          and candidate.field_index == row.field_index
          and candidate.option_index == row.chooser.selected
      end)
      state.modal.active_row = target_row or state.modal.active_row
      return true
    end
    if row and row.kind == "choice_chooser" then
      row.chooser.selected = clamp((row.chooser.selected or 1) + 1, 1, #(row.chooser.options or {}))
      local target_row = find_modal_row_index(state.modal, function(candidate)
        return candidate.kind == "choice_chooser"
          and candidate.option_index == row.chooser.selected
      end)
      state.modal.active_row = target_row or state.modal.active_row
      return true
    end
    if row and row.kind == "choice" then
      return false
    end
    if row and row.kind == "group_item_field" and row.subfield.kind == "choice" then
      return false
    end
    if row and row.kind == "chain_condition_detail" and (row.detail == "type" or row.detail == "comparator" or row.detail == "scope") then
      return true
    end
    if chain_cell then
      set_chain_text_cursor(chain_cell, clamp(chain_text_cursor(chain_cell) + 1, 1, #chain_text_value(chain_cell) + 1))
      return true
    end
    if not field then
      return false
    end
    field.cursor = clamp((field.cursor or 1) + 1, 1, #field.value + 1)
    return true
  end
  if key_code == KEY.home then
    if chain_cell then
      set_chain_text_cursor(chain_cell, 1)
      return true
    end
    if not field then
      return false
    end
    field.cursor = 1
    return true
  end
  if key_code == KEY["end"] then
    if chain_cell then
      set_chain_text_cursor(chain_cell, #chain_text_value(chain_cell) + 1)
      return true
    end
    if not field then
      return false
    end
    field.cursor = #field.value + 1
    return true
  end
  if key_code == KEY.backspace then
    if chain_cell then
      delete_left_chain_text(chain_cell)
      return true
    end
    if not field then
      return false
    end
    if row and row.kind == "repeat_item" and trim(field.value) == "" and #row.field.items > (row.field.min_items or 1) then
      return remove_repeatable_item(state.modal, row.field_index, row.item_index)
    end
    delete_left(field)
    return true
  end
  if key_code == KEY.delete then
    if chain_cell then
      delete_right_chain_text(chain_cell)
      return true
    end
    if not field then
      return false
    end
    if row and row.kind == "repeat_item" and trim(field.value) == "" and #row.field.items > (row.field.min_items or 1) then
      return remove_repeatable_item(state.modal, row.field_index, row.item_index)
    end
    delete_right(field)
    return true
  end

  local char = char_from_event(char_code)
  if chain_cell and char and char >= " " then
    insert_into_chain_text(chain_cell, char)
    return true
  end
  if field and char and char >= " " then
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
      if local_x and local_y and handle_scroll(state, direction, local_x, local_y, screen) then
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
  make_text_field = make_text_field,
  make_repeatable_text_field = make_repeatable_text_field,
  make_repeatable_group_field = make_repeatable_group_field,
  make_chain_condition = make_chain_condition,
  make_condition_chain_field = make_condition_chain_field,
  make_redstone_rules_field = make_redstone_rules_field,
  split_legacy_waypoint_string = split_legacy_waypoint_string,
  waypoint_rows_from_route = waypoint_rows_from_route,
  scope_to_editor_text = scope_to_editor_text,
  scope_from_editor_text = scope_from_editor_text,
  chain_tokens_from_groups = chain_tokens_from_groups,
  build_modal_rows = build_modal_rows,
  find_modal_row_index = find_modal_row_index,
  ensure_modal_row_visible = ensure_modal_row_visible,
  collect_modal_values = collect_modal_values,
  collect_detector_ids = collect_detector_ids,
  collect_waypoints = collect_waypoints,
  route_via_rows = route_via_rows,
  schedule_entry_rows = schedule_entry_rows,
  collect_schedule_entry_refs = collect_schedule_entry_refs,
  route_destination_station_id = route_destination_station_id,
  available_redstone_ids_for_route_destination = available_redstone_ids_for_route_destination,
  modal_destination_station_id = modal_destination_station_id,
  available_redstone_ids_for_station = available_redstone_ids_for_station,
  available_redstone_ids_for_schedule = available_redstone_ids_for_schedule,
  schedule_entry_station_ids = schedule_entry_station_ids,
  runtime_condition_from_editor = runtime_condition_from_editor,
  runtime_groups_from_chain = runtime_groups_from_chain,
  runtime_redstone_rules_from_chain = runtime_redstone_rules_from_editor,
  runtime_redstone_rules_from_editor = runtime_redstone_rules_from_editor,
  redstone_output_rows_from_station = redstone_output_rows_from_station,
  collect_redstone_outputs = collect_redstone_outputs,
  validate_redstone_output_rows = validate_redstone_output_rows,
  build_group_item_fields = build_group_item_fields,
  group_field_by_key = group_field_by_key,
  inspect_redstone_runtime = inspect_redstone_runtime,
  group_label = group_label,
  handle_key_down = handle_key_down,
  handle_scroll = handle_scroll,
  wrap_text = wrap_text,
  render_wrapped_lines = render_wrapped_lines,
  inline_view = inline_view,
}

if mode == "__module__" then
  return exports
end

local ok, err = run({...})
if ok == nil then
  io.stderr:write(tostring(err) .. "\n")
  os.exit(1)
end
