local M = {}

local VALID_COMPARATORS = {
  ["<"] = true,
  ["<="] = true,
  [">"] = true,
  [">="] = true,
  ["=="] = true,
}

local DETECTOR_TYPES = {
  passengers = true,
  fluid_percent = true,
  cargo_percent = true,
}

local function compare(left, comparator, right)
  if comparator == "<" then
    return left < right
  end
  if comparator == "<=" then
    return left <= right
  end
  if comparator == ">" then
    return left > right
  end
  if comparator == ">=" then
    return left >= right
  end
  if comparator == "==" then
    return left == right
  end
  return false
end

local function metric_from_info(condition, info)
  info = info or {}
  if condition.type == "passengers" then
    return tonumber(info.passengers) or 0
  end
  if condition.type == "cargo_percent" then
    return tonumber(info.cargo_percent) or 0
  end
  if condition.type == "fluid_percent" then
    local amount = tonumber(info.fluid_amount) or 0
    local max_value = tonumber(info.fluid_max) or 0
    if max_value <= 0 then
      return 0
    end
    return amount / max_value * 100
  end
  return nil
end

local function inactivity_threshold(condition_type)
  if condition_type == "cargo_percent" or condition_type == "fluid_percent" then
    return 0.5
  end
  if condition_type == "passengers" then
    return 1
  end
  return nil
end

function M.resolve_station(route_book, station_id)
  local station = route_book.STATIONS[station_id]
  if not station then
    return nil, ("unknown station %s"):format(tostring(station_id))
  end
  return station
end

local function route_terminal_station_id(route)
  if type(route) ~= "table" then
    return nil
  end
  if type(route.to) == "string" then
    return route.to
  end
  local last_waypoint = route.waypoints and route.waypoints[#route.waypoints]
  if type(last_waypoint) == "string" then
    return last_waypoint
  end
  return nil
end

function M.resolve_entry_station_id(route_book, entry)
  if type(entry.station) == "string" then
    return entry.station
  end

  local route = route_book.ROUTES[entry.route]
  if type(route) ~= "table" then
    return nil, ("schedule entry references unknown route %s"):format(tostring(entry.route))
  end
  local station_id = route_terminal_station_id(route)
  if not station_id then
    return nil, ("route %s must end at a station id or entry.station must be set"):format(entry.route)
  end
  return station_id
end

function M.validate_condition(route_book, station_id, condition, allowed_outputs, entry_station_ids)
  local errors = {}
  if type(condition) ~= "table" then
    errors[#errors + 1] = "condition must be a table"
    return errors
  end

  if condition.type == "time_passed" or condition.type == "inactivity" then
    if type(condition.seconds) ~= "number" or condition.seconds < 0 then
      errors[#errors + 1] = ("%s requires seconds >= 0"):format(condition.type)
    end
  elseif condition.type == "arrived_at_station" then
    if type(condition.station) ~= "string" or condition.station == "" then
      errors[#errors + 1] = "arrived_at_station requires a non-empty station"
    elseif entry_station_ids and not entry_station_ids[condition.station] then
      errors[#errors + 1] = ("arrived_at_station station %s is not in schedule entries"):format(condition.station)
    end
  elseif DETECTOR_TYPES[condition.type] then
    if not VALID_COMPARATORS[condition.comparator] then
      errors[#errors + 1] = ("%s requires a valid comparator"):format(condition.type)
    end
    if type(condition.value) ~= "number" then
      errors[#errors + 1] = ("%s requires numeric value"):format(condition.type)
    end
    local scope = condition.scope
    local scope_ok = false
    if scope == "station_any_detector" or scope == "station_all_detectors" then
      scope_ok = true
    elseif type(scope) == "table" then
      if scope.all_detectors == true then
        scope_ok = true
      elseif type(scope.detector_ids) == "table" then
        scope_ok = true
        for _, d in ipairs(scope.detector_ids) do
          if type(d) ~= "string" then
            scope_ok = false
            break
          end
        end
      elseif type(scope.detector_id) == "string" then
        scope_ok = true
      end
    end
    if not scope_ok then
      errors[#errors + 1] = ("%s requires station_any_detector, station_all_detectors, "
        .. "{station_id, all_detectors=true}, {station_id, detector_ids={...}}, or {detector_id=...} scope"):format(condition.type)
    end
  else
    errors[#errors + 1] = ("unsupported wait condition type %s"):format(tostring(condition.type))
  end

  if condition.redstone ~= nil then
    if type(condition.redstone) ~= "table" then
      errors[#errors + 1] = "redstone must be a table when present"
    else
      if type(condition.redstone.output) ~= "string" then
        errors[#errors + 1] = "redstone.output must be a string"
      else
        local known = false
        if allowed_outputs then
          known = allowed_outputs[condition.redstone.output] == true
        else
          local station = route_book.STATIONS[station_id]
          known = (station and station.redstone_outputs and station.redstone_outputs[condition.redstone.output]) ~= nil
        end
        if not known then
          errors[#errors + 1] = ("station %s does not define redstone output %s"):format(
            tostring(station_id),
            condition.redstone.output
          )
        end
      end
      if condition.redstone.mode ~= "while_pending" and condition.redstone.mode ~= "on_departure_pulse" then
        errors[#errors + 1] = "redstone.mode must be while_pending or on_departure_pulse"
      end
    end
  end

  return errors
end

function M.validate(route_book, schedule_name)
  local errors = {}
  local warnings = {}
  local schedules = route_book.SCHEDULES or {}

  local names = {}
  if schedule_name then
    names[1] = schedule_name
  else
    for name in pairs(schedules) do
      names[#names + 1] = name
    end
    table.sort(names)
  end

  for _, name in ipairs(names) do
    local schedule = schedules[name]
    if type(schedule) ~= "table" then
      errors[#errors + 1] = ("schedule %s must be a table"):format(name)
    else
      if type(schedule.entries) ~= "table" or #schedule.entries == 0 then
        warnings[#warnings + 1] = ("schedule %s has no entries"):format(name)
      end
      local allowed_outputs = {}
      local entry_station_ids = {}
      for _, entry in ipairs(schedule.entries or {}) do
        local sid = M.resolve_entry_station_id(route_book, entry)
        local station = sid and route_book.STATIONS[sid]
        if station then
          for output_name in pairs(station.redstone_outputs or {}) do
            allowed_outputs[output_name] = true
          end
          entry_station_ids[sid] = true
        end
      end
      for index, entry in ipairs(schedule.entries or {}) do
        if type(entry.station) == "string" and not route_book.STATIONS[entry.station] then
          errors[#errors + 1] = ("schedule %s entry %d references unknown station %s"):format(name, index, entry.station)
        end
        if entry.route ~= nil and type(entry.route) ~= "string" then
          errors[#errors + 1] = ("schedule %s entry %d route must be a string when present"):format(name, index)
        elseif entry.route == nil and type(entry.station) ~= "string" then
          errors[#errors + 1] = ("schedule %s entry %d requires station when route is omitted"):format(name, index)
        else
          if type(entry.route) == "string" and type(entry.station) == "string" then
            local route = route_book.ROUTES and route_book.ROUTES[entry.route]
            if type(route) ~= "table" then
              errors[#errors + 1] = ("schedule %s entry %d references unknown route %s"):format(name, index, entry.route)
            else
              local route_station = route_terminal_station_id(route)
              if route_station and route_station ~= entry.station then
                errors[#errors + 1] = ("schedule %s entry %d station %s does not match route %s destination %s"):format(
                  name,
                  index,
                  entry.station,
                  entry.route,
                  route_station
                )
              end
            end
          end
          local station_id, station_error = M.resolve_entry_station_id(route_book, entry)
          if not station_id then
            errors[#errors + 1] = ("schedule %s entry %d: %s"):format(name, index, station_error)
          else
            local wait = entry.wait or {groups = {{{type = "time_passed", seconds = 0}}}}
            if type(wait.groups) ~= "table" or #wait.groups == 0 then
              errors[#errors + 1] = ("schedule %s entry %d requires wait.groups"):format(name, index)
            else
              for group_index, group in ipairs(wait.groups) do
                if type(group) ~= "table" or #group == 0 then
                  errors[#errors + 1] = ("schedule %s entry %d wait group %d must contain conditions"):format(name, index, group_index)
                else
                  for condition_index, condition in ipairs(group) do
                    for _, message in ipairs(M.validate_condition(route_book, station_id, condition, allowed_outputs, entry_station_ids)) do
                      errors[#errors + 1] = ("schedule %s entry %d group %d condition %d: %s"):format(
                        name,
                        index,
                        group_index,
                        condition_index,
                        message
                      )
                    end
                  end
                end
              end
            end

            local redstone = entry.redstone
            if redstone ~= nil then
              if type(redstone) ~= "table" or type(redstone.rules) ~= "table" then
                errors[#errors + 1] = ("schedule %s entry %d redstone.rules must be a table"):format(name, index)
              else
                for rule_index, rule in ipairs(redstone.rules) do
                  if type(rule.output) ~= "string" then
                    errors[#errors + 1] = ("schedule %s entry %d redstone rule %d requires output"):format(name, index, rule_index)
                  else
                    local station = route_book.STATIONS[station_id]
                    local outputs = station and station.redstone_outputs or {}
                    local known = outputs[rule.output] ~= nil
                      or (allowed_outputs and allowed_outputs[rule.output] == true)
                    if not known then
                      errors[#errors + 1] = ("schedule %s entry %d redstone rule %d references unknown station output %s"):format(
                        name,
                        index,
                        rule_index,
                        tostring(rule.output)
                      )
                    end
                  end
                  local rule_signal = tostring(rule.signal or "")
                  if rule_signal ~= "" and rule_signal ~= "pulse" and rule_signal ~= "constant" then
                    errors[#errors + 1] = ("schedule %s entry %d redstone rule %d signal must be pulse or constant"):format(name, index, rule_index)
                  end
                  if rule.pulse_ticks ~= nil then
                    if type(rule.pulse_ticks) ~= "number" or rule.pulse_ticks < 1 then
                      errors[#errors + 1] = ("schedule %s entry %d redstone rule %d pulse_ticks must be a number >= 1"):format(name, index, rule_index)
                    end
                  end
                  if type(rule.groups) ~= "table" or #rule.groups == 0 then
                    errors[#errors + 1] = ("schedule %s entry %d redstone rule %d requires groups"):format(name, index, rule_index)
                  else
                    for group_index, group in ipairs(rule.groups) do
                      if type(group) ~= "table" or #group == 0 then
                        errors[#errors + 1] = ("schedule %s entry %d redstone rule %d group %d must contain conditions"):format(
                          name,
                          index,
                          rule_index,
                          group_index
                        )
                      else
                        for condition_index, condition in ipairs(group) do
                          local plain_condition = {}
                          for key, value in pairs(condition) do
                            plain_condition[key] = value
                          end
                          plain_condition.redstone = nil
                           for _, message in ipairs(M.validate_condition(route_book, station_id, plain_condition, allowed_outputs, entry_station_ids)) do
                            errors[#errors + 1] = ("schedule %s entry %d redstone rule %d group %d condition %d: %s"):format(
                              name,
                              index,
                              rule_index,
                              group_index,
                              condition_index,
                              message
                            )
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  return {
    ok = #errors == 0,
    errors = errors,
    warnings = warnings,
  }
end

local function resolve_detector_ids(route_book, station, condition)
  local scope = condition.scope
  if type(scope) == "table" and type(scope.station_id) == "string" then
    local st = route_book and route_book.STATIONS and route_book.STATIONS[scope.station_id]
    if scope.all_detectors then
      return st and st.detector_ids or {}
    end
    if type(scope.detector_ids) == "table" then
      return scope.detector_ids
    end
  end
  if type(scope) == "table" and type(scope.detector_id) == "string" then
    return {scope.detector_id}
  end
  if station then
    return station.detector_ids or {}
  end
  return {}
end

function M.create_wait_session(route_book, station_id, wait, detector_reader)
  local entry = wait
  if type(wait) ~= "table" or wait.route == nil then
    entry = {
      wait = wait,
      redstone = {rules = {}},
    }
  end
  local station = assert(M.resolve_station(route_book, station_id))
  return {
    route_book = route_book,
    station_id = station_id,
    station = station,
    entry = entry,
    wait = entry.wait or {groups = {{{type = "time_passed", seconds = 0}}}},
    detector_reader = detector_reader or function() return {} end,
    started_at = nil,
    last_activity_at = nil,
    last_metrics = {},
    completed = false,
    _rule_complete = {},
  }
end

local function evaluate_condition(session, condition, detector_snapshots, now)
  local complete = false
  if condition.type == "time_passed" then
    complete = (now - session.started_at) >= condition.seconds
  elseif condition.type == "inactivity" then
    complete = (now - session.last_activity_at) >= condition.seconds
  elseif condition.type == "arrived_at_station" then
    complete = session.station_id == tostring(condition.station or "")
  else
    local detector_ids = resolve_detector_ids(session.route_book, session.station, condition)
    local samples = {}
    for _, detector_id in ipairs(detector_ids) do
      local sample = detector_snapshots[detector_id]
      if sample then
        samples[#samples + 1] = sample.info or {}
        local metric = metric_from_info(condition, sample.info or {})
        local threshold = inactivity_threshold(condition.type)
        local last_key = detector_id .. ":" .. condition.type
        local previous_metric = session.last_metrics[last_key]
        if metric ~= nil and threshold and previous_metric ~= nil and math.abs(metric - previous_metric) >= threshold then
          session.last_activity_at = now
        end
        if metric ~= nil then
          session.last_metrics[last_key] = metric
        end
      end
    end

    if #samples > 0 then
      local and_mode = (condition.scope == "station_all_detectors")
        or (type(condition.scope) == "table" and condition.scope.all_detectors == true)
      if and_mode then
        complete = true
        for _, info in ipairs(samples) do
          if not compare(metric_from_info(condition, info) or 0, condition.comparator, condition.value) then
            complete = false
            break
          end
        end
      else
        for _, info in ipairs(samples) do
          if compare(metric_from_info(condition, info) or 0, condition.comparator, condition.value) then
            complete = true
            break
          end
        end
      end
    end
  end
  return complete
end

function M.evaluate_rule_groups(groups, station, detector_snapshots, session, now)
  local any_group_complete = false
  for _, group in ipairs(groups or {}) do
    local group_complete = true
    for _, condition in ipairs(group or {}) do
      if not evaluate_condition(session, condition, detector_snapshots, now) then
        group_complete = false
      end
    end
    if group_complete then
      any_group_complete = true
    end
  end
  return any_group_complete
end

function M.tick_wait_session(session, now)
  session.started_at = session.started_at or now
  session.last_activity_at = session.last_activity_at or now

  local detector_snapshots = session.detector_reader(session.station.detector_ids or {})
  local pending_outputs = {}
  local departure_pulses = {}
  local arrival_pulses = {}
  local groups_complete = false

  for group_index, group in ipairs(session.wait.groups or {}) do
    local group_complete = true
    for condition_index, condition in ipairs(group) do
      local complete = evaluate_condition(session, condition, detector_snapshots, now)

      if condition.redstone and condition.redstone.mode == "while_pending" and not complete then
        pending_outputs[condition.redstone.output] = true
      end
      if not complete then
        group_complete = false
      end
      group[condition_index]._last_complete = complete
    end

    if group_complete then
      groups_complete = true
    end
  end

  if not groups_complete then
    for rule_index, rule in ipairs(session.entry and session.entry.redstone and session.entry.redstone.rules or {}) do
      if type(rule.output) == "string" and rule.output ~= "" then
        local rule_complete = M.evaluate_rule_groups(rule.groups, session.station, detector_snapshots, session, now)
        local rule_signal = tostring(rule.signal or "constant")
        if rule_signal == "constant" and rule_complete then
          pending_outputs[rule.output] = true
        end
        if rule_signal == "pulse" and rule_complete and not session._rule_complete[rule_index] then
          local cfg = (session.station.redstone_outputs or {})[rule.output]
          if cfg then
            local pulse_cfg = {}
            for k, v in pairs(cfg) do pulse_cfg[k] = v end
            pulse_cfg.pulse_ticks = rule.pulse_ticks or cfg.pulse_ticks or 20
            arrival_pulses[#arrival_pulses + 1] = {name = rule.output, config = pulse_cfg}
          end
        end
        session._rule_complete[rule_index] = rule_complete
      end
    end
  end

  if groups_complete and not session.completed then
    for _, group in ipairs(session.wait.groups or {}) do
      for _, condition in ipairs(group) do
        if condition.redstone and condition.redstone.mode == "on_departure_pulse" then
          departure_pulses[condition.redstone.output] = true
        end
      end
    end
  end
  session.completed = groups_complete

  return {
    complete = groups_complete,
    pending_outputs = pending_outputs,
    departure_pulses = departure_pulses,
    arrival_pulses = arrival_pulses,
    detector_snapshots = detector_snapshots,
    started_at = session.started_at,
    last_activity_at = session.last_activity_at,
  }
end

M.compare = compare
M.metric_from_info = metric_from_info
M.evaluate_rule_groups = M.evaluate_rule_groups
M.route_terminal_station_id = route_terminal_station_id

return M
