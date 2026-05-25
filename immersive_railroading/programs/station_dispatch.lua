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
  return "station_dispatch.lua"
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
    join_paths(base, "?/init.lua"),
    join_paths(base, "lib/?.lua"),
    join_paths(base, "lib/?/init.lua"),
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

local component = rawget(_G, "component") or safe_require("component")
local computer = rawget(_G, "computer") or safe_require("computer")
local event = safe_require("event")

local route_book_store = fresh_require("lib.route_book_store")
local augment_registry = fresh_require("lib.augment_registry")
local station_schedule = fresh_require("lib.station_schedule")
local redstone_io = fresh_require("lib.redstone_io")

local controller_chunk = assert(loadfile(join_paths(SCRIPT_DIR, "train_controller.lua")))
local train_controller = controller_chunk("__module__")

local function normalize_runtime_error(err)
  if type(err) == "table" then
    return err.reason or err.code or tostring(err)
  end
  return tostring(err)
end

local function route_book_path()
  return join_paths(SCRIPT_DIR, "route_book.lua")
end

local function uptime()
  if computer and type(computer.uptime) == "function" then
    return computer.uptime()
  end
  return os.clock()
end

local function sleep_for(seconds)
  if event and type(event.pull) == "function" then
    local ok, signal, a, b, c = pcall(event.pull, seconds)
    if not ok then
      return nil, signal
    end
    return signal, a, b, c
  end
  local deadline = uptime() + seconds
  while uptime() < deadline do
  end
  return true
end

local function component_available(name)
  if not component then
    return false
  end
  if type(component.isAvailable) == "function" then
    local ok, value = pcall(component.isAvailable, name)
    return ok and value == true
  end
  local ok, value = pcall(function()
    return component[name]
  end)
  return ok and value ~= nil
end

local function get_primary_component(name)
  if not component_available(name) then
    return nil
  end
  if type(component.getPrimary) == "function" then
    local ok, proxy = pcall(component.getPrimary, name)
    if ok and proxy ~= nil then
      return proxy
    end
  end
  local ok, proxy = pcall(function()
    return component[name]
  end)
  if ok and proxy ~= nil then
    return proxy
  end
  return nil
end

local function make_logger(path)
  if not path then
    return nil
  end
  local handle, open_error = io.open(path, "a")
  if not handle then
    return nil, open_error
  end
  handle:close()
  return {path = path}
end

local function emit_line(logger, line)
  io.write(line .. "\n")
  if logger and logger.path then
    local handle = io.open(logger.path, "a")
    if handle then
      handle:write(line .. "\n")
      handle:close()
    end
  end
end

local function emit_event(logger, event_name, payload)
  local parts = {event_name}
  local keys = {}
  for key in pairs(payload or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  for _, key in ipairs(keys) do
    parts[#parts + 1] = ("%s=%s"):format(key, tostring(payload[key]))
  end
  emit_line(logger, table.concat(parts, " "))
end

local function load_route_book()
  return route_book_store.load(route_book_path())
end

local function validate_route_book(route_book, schedule_name)
  local errors = {}
  local warnings = {}

  local registry_result = augment_registry.validate(route_book)
  for _, message in ipairs(registry_result.errors) do
    errors[#errors + 1] = message
  end
  for _, message in ipairs(registry_result.warnings) do
    warnings[#warnings + 1] = message
  end

  for station_id, station in pairs(route_book.STATIONS or {}) do
    if type(station.x) ~= "number" or type(station.y) ~= "number" or type(station.z) ~= "number" then
      errors[#errors + 1] = ("station %s must define numeric x/y/z"):format(station_id)
    end
    local outputs = redstone_io.validate_outputs(station.redstone_outputs or {})
    for _, message in ipairs(outputs.errors) do
      errors[#errors + 1] = ("station %s: %s"):format(station_id, message)
    end
  end

  for route_id, route in pairs(route_book.ROUTES or {}) do
    if route.from ~= nil and not route_book.STATIONS[route.from] then
      errors[#errors + 1] = ("route %s references unknown from station %s"):format(route_id, tostring(route.from))
    end
    if route.to ~= nil and not route_book.STATIONS[route.to] then
      errors[#errors + 1] = ("route %s references unknown to station %s"):format(route_id, tostring(route.to))
    end
    if route.via ~= nil and type(route.via) ~= "table" then
      errors[#errors + 1] = ("route %s via must be a list"):format(route_id)
    end
  end

  local schedule_result = station_schedule.validate(route_book, schedule_name)
  for _, message in ipairs(schedule_result.errors) do
    errors[#errors + 1] = message
  end
  for _, message in ipairs(schedule_result.warnings) do
    warnings[#warnings + 1] = message
  end

  return {
    ok = #errors == 0,
    errors = errors,
    warnings = warnings,
  }
end

local function get_remote()
  local remote = get_primary_component("ir_remote_control")
  if not remote then
    return nil, "component.ir_remote_control is not available"
  end
  return remote
end

local function get_redstone_component(address)
  if not component then
    return nil, "component API unavailable"
  end

  if type(address) == "string" and address ~= "" then
    if type(component.proxy) ~= "function" then
      return nil, ("component.proxy is unavailable for redstone address %s"):format(address)
    end
    local ok, proxy = pcall(component.proxy, address)
    if not ok or proxy == nil then
      return nil, ("redstone component address %s is unavailable"):format(address)
    end
    return proxy
  end

  local primary = get_primary_component("redstone")
  if not primary then
    return nil, "component.redstone is required for configured station outputs"
  end
  return primary
end

local function make_redstone_proxy_resolver(route_book)
  local cache = {}
  local required = false

  for _, station in pairs(route_book.STATIONS or {}) do
    if next(station.redstone_outputs or {}) ~= nil then
      required = true
      break
    end
  end

  if not required then
    return function()
      return nil
    end
  end

  return function(config)
    local address = config and config.address or nil
    local cache_key = address ~= nil and address ~= "" and address or "__primary__"
    if cache[cache_key] ~= nil then
      return cache[cache_key]
    end

    local proxy, err = get_redstone_component(address)
    if not proxy then
      return nil, err
    end
    cache[cache_key] = proxy
    return proxy
  end
end

local function make_detector_reader(route_book)
  local proxies = {}
  local registry = route_book.AUGMENTS.DETECTORS or {}
  return function(detector_ids)
    local results = {}
    for _, detector_id in ipairs(detector_ids or {}) do
      local detector = registry[detector_id]
      if detector and detector.address and component and type(component.proxy) == "function" then
        proxies[detector_id] = proxies[detector_id] or component.proxy(detector.address)
        local proxy = proxies[detector_id]
        local ok, info_or_error = pcall(proxy.info)
        results[detector_id] = {
          address = detector.address,
          ok = ok,
          info = ok and info_or_error or {},
          error = ok and nil or normalize_runtime_error(info_or_error),
        }
      end
    end
    return results
  end
end

local function drain_pulses(io_controller, outputs)
  while next(io_controller.pulses) do
    sleep_for(0.05)
    io_controller:tick(outputs)
  end
end

local function print_validation(result)
  for _, message in ipairs(result.errors) do
    io.stderr:write("ERROR: " .. message .. "\n")
  end
  for _, message in ipairs(result.warnings) do
    io.write("WARN: " .. message .. "\n")
  end
end

local function resolve_route_for_entry(route_book, current_station_id, entry)
  if type(entry.route) == "string" then
    return entry.route
  end

  if not current_station_id then
    return nil, "first schedule entry must define route when current station is unknown"
  end
  if type(entry.station) ~= "string" then
    return nil, "schedule entry without route must define station"
  end

  local matches = {}
  for route_id, route in pairs(route_book.ROUTES or {}) do
    if route.from == current_station_id and route.to == entry.station then
      matches[#matches + 1] = route_id
    end
  end
  table.sort(matches)

  if #matches == 0 then
    return nil, ("no route from %s to %s"):format(current_station_id, entry.station)
  end
  if #matches > 1 then
    return nil, ("multiple routes from %s to %s: %s"):format(current_station_id, entry.station, table.concat(matches, ", "))
  end
  return matches[1]
end

local function build_schedule_guardrail_candidates(route_book, schedule, current_station_id)
  local candidates = {}
  local fallback_axis = nil
  for entry_index, entry in ipairs(schedule.entries or {}) do
    local route_id = select(1, resolve_route_for_entry(route_book, current_station_id, entry))
    if route_id then
      local ok, route_plan_or_error = pcall(train_controller.build_named_route_plan, route_id, {
        profile_name = nil,
        profile_explicit = false,
        via_points = {},
      }, route_book)
      if ok and route_plan_or_error then
        local route_plan = route_plan_or_error
        if not fallback_axis and #route_plan.legs >= 2 then
          fallback_axis = train_controller.horizontal_axis({
            x = route_plan.legs[2].target.x - route_plan.legs[1].target.x,
            y = route_plan.legs[2].target.y - route_plan.legs[1].target.y,
            z = route_plan.legs[2].target.z - route_plan.legs[1].target.z,
          })
        end
        for _, leg in ipairs(route_plan.legs) do
          candidates[#candidates + 1] = {
            point = leg.target,
            entry_index = entry_index,
            route_id = route_id,
            leg_index = leg.index,
          }
        end
      end
    end
  end
  return candidates, fallback_axis
end

local function pick_schedule_start(route_book, schedule, remote, logger, current_station_id)
  local candidates, fallback_axis = build_schedule_guardrail_candidates(route_book, schedule, current_station_id)
  local heading, heading_reason = train_controller.sample_heading(remote, fallback_axis, logger)
  if not heading then
    return nil, "missing_heading:" .. tostring(heading_reason)
  end
  local position_ok, x_or_error, y, z = pcall(function()
    local x, y, z = remote.getPos()
    return x, y, z
  end)
  if not position_ok then
    return nil, "failed to read train position for schedule start: " .. tostring(x_or_error)
  end
  local position = {x = x_or_error, y = y, z = z}
  local candidate, reason = train_controller.choose_forward_guardrail(candidates, position, heading)
  if not candidate then
    return nil, reason
  end
  return {
    entry_index = candidate.entry_index,
    route_id = candidate.route_id,
    leg_index = candidate.leg_index,
    reason = reason,
    heading_reason = heading_reason,
  }
end

local function validate(schedule_name)
  local route_book, load_error = load_route_book()
  if not route_book then
    return nil, load_error
  end
  local result = validate_route_book(route_book, schedule_name)
  print_validation(result)
  return result.ok, result
end

local function inspect(schedule_name)
  local route_book, load_error = load_route_book()
  if not route_book then
    return nil, load_error
  end
  local result = validate_route_book(route_book, schedule_name)
  print_validation(result)

  local schedules = route_book.SCHEDULES or {}
  if schedule_name then
    schedules = {[schedule_name] = schedules[schedule_name]}
  end

  for name, schedule in pairs(schedules) do
    io.write(("schedule %s cyclic=%s entries=%d\n"):format(name, tostring(schedule and schedule.cyclic == true), schedule and #(schedule.entries or {}) or 0))
    for index, entry in ipairs(schedule and schedule.entries or {}) do
      local station_id = select(1, station_schedule.resolve_entry_station_id(route_book, entry))
      io.write(("  [%d] route=%s station=%s groups=%d\n"):format(
        index,
        tostring(entry.route),
        tostring(station_id),
        #(entry.wait and entry.wait.groups or {})
      ))
    end
  end

  return result.ok, result
end

local function detectors()
  local route_book, load_error = load_route_book()
  if not route_book then
    return nil, load_error
  end
  local runtime = augment_registry.inspect_runtime(component, route_book)
  for _, item in ipairs(runtime) do
    io.write(("%s\t%s\tstation=%s\taddress=%s\n"):format(
      tostring(item.detector_id or "<unbound>"),
      tostring(item.label or "<unknown>"),
      tostring(item.station_id or "-"),
      tostring(item.address)
    ))
  end
  return true
end

local function run(schedule_name, options)
  options = options or {}
  local route_book, load_error = load_route_book()
  if not route_book then
    return nil, load_error
  end

  local validation = validate_route_book(route_book, schedule_name)
  if not validation.ok then
    print_validation(validation)
    return nil, "route book validation failed"
  end

  local schedule = route_book.SCHEDULES[schedule_name]
  if not schedule then
    return nil, ("unknown schedule %s"):format(tostring(schedule_name))
  end

  local remote, remote_error = get_remote()
  if not remote then
    return nil, remote_error
  end

  local logger, logger_error = make_logger(options.log_path)
  if options.log_path and not logger then
    return nil, logger_error
  end

  local resolve_redstone_proxy = make_redstone_proxy_resolver(route_book)

  local detector_reader = make_detector_reader(route_book)
  local io_controller = redstone_io.make_controller(
    resolve_redstone_proxy,
    function(event_name, payload)
      emit_event(logger, event_name, payload)
    end,
    uptime,
    component
  )

  local current_station_id = options.current_station_id
  local start_entry_index = 1
  local start_route_id = nil
  local start_leg_index = nil
  if not options.disable_start_picker then
    local picked, pick_error = pick_schedule_start(route_book, schedule, remote, logger, current_station_id)
    if not picked then
      return nil, "schedule start picker failed: " .. tostring(pick_error)
    end
    start_entry_index = picked.entry_index or 1
    start_route_id = picked.route_id
    start_leg_index = picked.leg_index
    emit_event(logger, "schedule_start_guardrail", {
      schedule = schedule_name,
      entry = start_entry_index,
      route = start_route_id,
      leg = start_leg_index,
      reason = picked.reason,
      heading = picked.heading_reason,
    })
  end

  local cycle = 0
  repeat
    cycle = cycle + 1
    emit_event(logger, "schedule_start", {schedule = schedule_name, cycle = cycle})

    local first_index = cycle == 1 and start_entry_index or 1
    for index = first_index, #(schedule.entries or {}) do
      local entry = schedule.entries[index]
      local route_id, route_error = resolve_route_for_entry(route_book, current_station_id, entry)
      if not route_id then
        return nil, route_error
      end
      local station_id, station_error = station_schedule.resolve_entry_station_id(route_book, entry)
      if not station_id then
        return nil, station_error
      end
      emit_event(logger, "schedule_entry_start", {
        schedule = schedule_name,
        entry = index,
        route = route_id,
        station = station_id,
      })

      local route_plan = train_controller.build_named_route_plan(route_id, {
        profile_name = nil,
        profile_explicit = false,
        via_points = {},
      }, route_book)
      if cycle == 1 and index == start_entry_index and route_id == start_route_id and start_leg_index then
        route_plan.initial_leg_index = start_leg_index
      end
      local ok, route_error = train_controller.execute_route_plan(remote, route_plan, logger)
      if not ok then
        io_controller:shutdown((route_book.STATIONS[station_id] or {}).redstone_outputs or {})
        return nil, route_error
      end

      emit_event(logger, "schedule_entry_arrived", {
        schedule = schedule_name,
        entry = index,
        route = route_id,
        station = station_id,
      })

      local station = route_book.STATIONS[station_id]
      local session = station_schedule.create_wait_session(route_book, station_id, entry, detector_reader)
      local wait_complete = false
      while not wait_complete do
        local signal, net_address, augment_type, stock_uuid = sleep_for(0.2)
        if signal == "ir_train_overhead" then
          emit_event(logger, "detector_overhead_seen", {
            net_address = net_address,
            augment_type = augment_type,
            stock_uuid = stock_uuid,
          })
        end

        local tick = station_schedule.tick_wait_session(session, uptime())
        io_controller:update(station.redstone_outputs or {}, tick.pending_outputs)
        io_controller:tick(station.redstone_outputs or {})
        emit_event(logger, "schedule_wait_tick", {
          schedule = schedule_name,
          entry = index,
          station = station_id,
          complete = tostring(tick.complete),
          pending_outputs = next(tick.pending_outputs) and "yes" or "no",
        })

        if tick.complete then
          for output_name in pairs(tick.departure_pulses) do
            io_controller:pulse(output_name, station.redstone_outputs[output_name])
          end
          drain_pulses(io_controller, station.redstone_outputs or {})
          io_controller:shutdown(station.redstone_outputs or {})
          emit_event(logger, "schedule_wait_complete", {
            schedule = schedule_name,
            entry = index,
            station = station_id,
          })
          current_station_id = station_id
          wait_complete = true
        end
      end
    end

    if schedule.cyclic then
      emit_event(logger, "schedule_cycle_restart", {schedule = schedule_name, cycle = cycle})
    end
  until not schedule.cyclic

  emit_event(logger, "schedule_complete", {schedule = schedule_name, cycles = cycle})
  return true
end

local function parse_cli(argv)
  local args = {}
  local log_path
  for _, argument in ipairs(argv or {}) do
    local value = tostring(argument)
    local explicit = value:match("^%-%-log=(.+)$")
    if explicit then
      log_path = explicit
    elseif value == "--log" then
      log_path = "station_dispatch.log"
    else
      args[#args + 1] = value
    end
  end
  return args, {log_path = log_path}
end

local function main(argv)
  local args, options = parse_cli(argv or {})
  local command = args[1]
  if command == "run" then
    if not args[2] then
      return nil, "run requires <schedule>"
    end
    return run(args[2], options)
  end
  if command == "validate" then
    return validate(args[2])
  end
  if command == "inspect" then
    if not args[2] then
      return nil, "inspect requires <schedule>"
    end
    return inspect(args[2])
  end
  if command == "detectors" then
    return detectors()
  end

  io.write("usage:\n")
  io.write("  station_dispatch run <schedule> [--log[=path]]\n")
  io.write("  station_dispatch validate [schedule]\n")
  io.write("  station_dispatch inspect <schedule>\n")
  io.write("  station_dispatch detectors\n")
  return true
end

local exports = {
  run = run,
  validate = validate,
  inspect = inspect,
  detectors = detectors,
  validate_route_book = validate_route_book,
  resolve_route_for_entry = resolve_route_for_entry,
  build_schedule_guardrail_candidates = build_schedule_guardrail_candidates,
  pick_schedule_start = pick_schedule_start,
  _component_available = component_available,
  _get_primary_component = get_primary_component,
  _get_redstone_component = get_redstone_component,
  _make_redstone_proxy_resolver = make_redstone_proxy_resolver,
  _get_remote = get_remote,
  main = main,
}

if mode == "__module__" then
  return exports
end

local ok, err = main({...})
if ok == nil then
  io.stderr:write(tostring(err) .. "\n")
  os.exit(1)
end
