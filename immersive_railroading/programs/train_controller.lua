local DEFAULTS = {
  cruise_kmh = 40,
  stop_buffer_m = 2,
  arrival_distance_m = 1.5,
  arrival_speed_mps = 0.35,
  settle_time_s = 2.0,
  loop_dt_s = 0.2,
  report_interval_s = 1.0,
  fallback_mass_kg = 425000,
  fallback_power_w = 1800000,
  fallback_traction_n = 180000,
  fallback_brake_mps2 = 0.9,
  fallback_max_speed_kmh = 65,
  min_drive_accel_mps2 = 0.15,
  min_brake_mps2 = 0.2,
  min_reference_speed_mps = 4.0,
  brake_learning_memory_s = 12.0,
  brake_learning_min_cmd = 0.2,
  brake_learning_curve_exponent = 1.2,
  brake_learning_floor = 0.05,
  brake_learning_min_speed_mps = 1.0,
  throttle_deadband = 0.03,
  brake_deadband = 0.03,
  hold_brake = 0.35,
  hold_independent_brake = 1.0,
  speed_filter_memory_s = 0.8,
  enter_brake_margin_mps = 0.35,
  exit_brake_margin_mps = 0.9,
  approach_distance_m = 120,
  approach_throttle_limit = 0.4,
  cruise_throttle_limit = 0.75,
  brake_release_hold_s = 0.8,
  overspeed_full_brake_margin_mps = 2.0,
  min_brake_command = 0.08,
  min_axis_speed_mps = 0.35,
  reverser_switch_speed_mps = 0.4,
  log_default_path = "train_controller.log",
  terminal_stop_margin_m = 0.75,
  move_away_brake_speed_mps = 0.15,
  restart_from_stop_speed_mps = 0.25,
  launch_throttle_limit = 0.22,
}

local INFO_PATHS = {
  mass_kg = {
    {"mass_kg"},
    {"massKg"},
    {"mass"},
    {"weight_kg"},
    {"weightKg"},
    {"weight"},
    {"physics", "mass_kg"},
    {"physics", "mass"},
    {"train", "mass_kg"},
    {"train", "mass"},
    {"consist", "mass_kg"},
    {"consist", "mass"},
  },
  power_w = {
    {"power_w"},
    {"powerW"},
    {"power_kw"},
    {"powerKw"},
    {"power"},
    {"horsepower_w"},
    {"specs", "power_w"},
    {"specs", "power_kw"},
    {"engine", "power_w"},
    {"engine", "power_kw"},
  },
  traction_n = {
    {"traction_n"},
    {"tractionN"},
    {"tractive_effort_n"},
    {"tractiveEffortN"},
    {"tractive_effort_kn"},
    {"tractiveEffortKn"},
    {"tractive_effort"},
    {"specs", "traction_n"},
    {"specs", "tractive_effort_n"},
    {"engine", "tractive_effort_n"},
  },
  max_speed_kmh = {
    {"max_speed_kmh"},
    {"maxSpeedKmh"},
    {"max_speed"},
    {"speed_limit_kmh"},
    {"top_speed_kmh"},
    {"specs", "max_speed_kmh"},
  },
}

local function safe_require(name)
  local ok, library = pcall(require, name)
  if ok then
    return library
  end
  return nil
end

local component = rawget(_G, "component") or safe_require("component")
local computer = rawget(_G, "computer") or safe_require("computer")
local event = safe_require("event")

local function clamp(value, low, high)
  if value < low then
    return low
  end
  if value > high then
    return high
  end
  return value
end

local function round(value, digits)
  local factor = 10 ^ (digits or 0)
  return math.floor(value * factor + 0.5) / factor
end

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
  return "train_controller.lua"
end

local function script_directory()
  local directory = split_path(script_source_path())
  return directory or "."
end

local function is_absolute_path(path)
  return type(path) == "string" and path:sub(1, 1) == "/"
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

local function resolve_log_path(path)
  if not path or path == "" then
    return nil
  end
  if is_absolute_path(path) then
    return path
  end
  return join_paths(script_directory(), path)
end

local function ensure_parent_directory(path)
  local fs = safe_require("filesystem")
  if not fs then
    return
  end

  local directory = split_path(path)
  if directory ~= "." and not fs.exists(directory) then
    fs.makeDirectory(directory)
  end
end

local function make_logger(path)
  if not path then
    return nil
  end

  path = resolve_log_path(path)
  ensure_parent_directory(path)
  local handle, open_error = io.open(path, "a")
  if not handle then
    return nil, open_error
  end
  handle:write("")
  handle:flush()
  handle:close()

  return {
    path = path,
  }
end

local function close_logger(logger)
  if not logger then
    return
  end
end

local function emit_line(logger, line)
  io.write(line .. "\n")
  if logger and logger.path then
    local ok, write_error = pcall(function()
      local handle, open_error = io.open(logger.path, "a")
      if not handle then
        error(open_error)
      end
      handle:write(line .. "\n")
      handle:flush()
      handle:close()
    end)
    if not ok then
      io.stderr:write("log write failed: " .. tostring(write_error) .. "\n")
    end
  end
end

local function uptime()
  if computer and type(computer.uptime) == "function" then
    return computer.uptime()
  end
  return os.clock()
end

local function sleep_for(seconds)
  if type(os.sleep) == "function" then
    os.sleep(seconds)
    return
  end
  if event and type(event.pull) == "function" then
    event.pull(seconds)
    return
  end

  local deadline = uptime() + seconds
  while uptime() < deadline do
  end
end

local function component_available(name)
  if not component then
    return false
  end
  if type(component.isAvailable) == "function" then
    return component.isAvailable(name)
  end
  return component[name] ~= nil
end

local function get_remote()
  if not component_available("ir_remote_control") then
    return nil, "component.ir_remote_control is not available"
  end
  return component.ir_remote_control
end

local function get_nested(source, path)
  local cursor = source
  for _, key in ipairs(path) do
    if type(cursor) ~= "table" then
      return nil
    end
    cursor = cursor[key]
  end
  return cursor
end

local function as_number(value)
  if type(value) == "number" then
    return value
  end
  if type(value) == "string" then
    return tonumber(value)
  end
  return nil
end

local function pick_number(source, paths, unit_scale)
  if type(source) ~= "table" then
    return nil
  end

  for _, path in ipairs(paths) do
    local value = as_number(get_nested(source, path))
    if value then
      return value * (unit_scale or 1)
    end
  end

  return nil
end

local function vector_from_pos(position)
  if type(position) ~= "table" then
    return nil
  end

  local x = as_number(position.x or position[1])
  local y = as_number(position.y or position[2])
  local z = as_number(position.z or position[3])
  if not x or not y or not z then
    return nil
  end

  return {x = x, y = y, z = z}
end

local function vector_sub(a, b)
  return {
    x = a.x - b.x,
    y = a.y - b.y,
    z = a.z - b.z,
  }
end

local function vector_scale(vector, scalar)
  return {
    x = vector.x * scalar,
    y = vector.y * scalar,
    z = vector.z * scalar,
  }
end

local function vector_dot(a, b)
  return a.x * b.x + a.y * b.y + a.z * b.z
end

local function vector_length(vector)
  return math.sqrt(vector_dot(vector, vector))
end

local function normalize(vector)
  local length = vector_length(vector)
  if length <= 0 then
    return nil
  end
  return vector_scale(vector, 1 / length)
end

local function vector_reject(vector, axis)
  return vector_sub(vector, vector_scale(axis, vector_dot(vector, axis)))
end

local function ema(previous, sample, memory_s, dt_s)
  if previous == nil then
    return sample
  end
  local alpha = clamp(dt_s / math.max(memory_s, dt_s), 0, 1)
  return previous + (sample - previous) * alpha
end

local function read_info(remote)
  local ok, value = pcall(remote.info)
  if ok then
    return value
  end
  return nil, value
end

local function read_consist(remote)
  local ok, value = pcall(remote.consist)
  if ok then
    return value
  end
  return nil, value
end

local function read_position(remote)
  local ok, x, y, z = pcall(remote.getPos)
  if not ok then
    return nil, x
  end

  if type(x) == "table" then
    return vector_from_pos(x)
  end

  return vector_from_pos({x = x, y = y, z = z})
end

local function extract_characteristics(info, consist, requested_cruise_kmh)
  local mass_kg = pick_number(info, INFO_PATHS.mass_kg)
    or pick_number(consist, INFO_PATHS.mass_kg)
    or DEFAULTS.fallback_mass_kg

  local power_w = pick_number(info, INFO_PATHS.power_w)
    or pick_number(consist, INFO_PATHS.power_w)
    or DEFAULTS.fallback_power_w
  if power_w and power_w < 10000 then
    power_w = power_w * 1000
  end

  local traction_n = pick_number(info, INFO_PATHS.traction_n)
    or pick_number(consist, INFO_PATHS.traction_n)
    or DEFAULTS.fallback_traction_n
  if traction_n and traction_n < 5000 then
    traction_n = traction_n * 1000
  end

  local max_speed_kmh = pick_number(info, INFO_PATHS.max_speed_kmh)
    or pick_number(consist, INFO_PATHS.max_speed_kmh)
    or DEFAULTS.fallback_max_speed_kmh

  local cruise_kmh = clamp(
    requested_cruise_kmh or DEFAULTS.cruise_kmh,
    1,
    math.max(max_speed_kmh, 1)
  )

  return {
    mass_kg = mass_kg,
    power_w = power_w,
    traction_n = traction_n,
    max_speed_kmh = max_speed_kmh,
    cruise_kmh = cruise_kmh,
    cruise_mps = cruise_kmh / 3.6,
  }
end

local function derive_pid(characteristics, brake_model)
  local v_ref_mps = math.max(characteristics.cruise_mps, DEFAULTS.min_reference_speed_mps)
  local drive_from_traction = characteristics.traction_n / math.max(characteristics.mass_kg, 1)
  local drive_from_power = characteristics.power_w / math.max(v_ref_mps, 1) / math.max(characteristics.mass_kg, 1)
  local a_drive = math.max(
    math.min(drive_from_traction, drive_from_power),
    DEFAULTS.min_drive_accel_mps2
  )
  local a_brake = math.max(brake_model.full_service_mps2, DEFAULTS.min_brake_mps2)

  local t_drive = v_ref_mps / a_drive
  local t_brake = v_ref_mps / a_brake

  return {
    kp = 1 / v_ref_mps,
    ki = (1 / v_ref_mps) / t_brake,
    kd = (1 / v_ref_mps) * math.min(t_drive, t_brake),
    a_drive_mps2 = a_drive,
    a_brake_mps2 = a_brake,
    t_drive_s = t_drive,
    t_brake_s = t_brake,
  }
end

local function stop_speed_cap(remaining_m, stop_buffer_m, brake_model, cruise_mps)
  local usable_distance = math.max(remaining_m - stop_buffer_m, 0)
  local stop_cap = math.sqrt(2 * math.max(brake_model.full_service_mps2, DEFAULTS.min_brake_mps2) * usable_distance)
  return math.min(cruise_mps, stop_cap)
end

local function select_motion_mode(state, speed_toward_target_mps, target_speed_mps, remaining_m)
  local overspeed = speed_toward_target_mps - target_speed_mps
  local must_hold_brake = state.brake_release_until and uptime() < state.brake_release_until

  if must_hold_brake then
    return "brake"
  end

  if remaining_m <= DEFAULTS.arrival_distance_m * 4 then
    return "brake"
  end

  -- If the train is moving away from the target along the chosen track axis,
  -- adding throttle only makes the oscillation worse. Force a stop first.
  if speed_toward_target_mps <= -DEFAULTS.move_away_brake_speed_mps then
    return "brake"
  end

  if overspeed >= DEFAULTS.enter_brake_margin_mps then
    return "brake"
  end

  if state.mode == "brake" and overspeed >= -DEFAULTS.exit_brake_margin_mps then
    return "brake"
  end

  if target_speed_mps <= DEFAULTS.arrival_speed_mps * 2 then
    return "coast"
  end

  return "drive"
end

local function print_table(title, value, indent, visited, logger)
  indent = indent or ""
  visited = visited or {}

  if title then
    emit_line(logger, title)
  end

  if type(value) ~= "table" then
    emit_line(logger, indent .. tostring(value))
    return
  end

  if visited[value] then
    emit_line(logger, indent .. "<cycle>")
    return
  end
  visited[value] = true

  local keys = {}
  for key in pairs(value) do
    keys[#keys + 1] = key
  end
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end)

  for _, key in ipairs(keys) do
    local item = value[key]
    if type(item) == "table" then
      emit_line(logger, ("%s%s:"):format(indent, tostring(key)))
      print_table(nil, item, indent .. "  ", visited, logger)
    else
      emit_line(logger, ("%s%s = %s"):format(indent, tostring(key), tostring(item)))
    end
  end
end

local function apply_controls(remote, control)
  remote.setThrottle(control.throttle)
  remote.setReverser(control.reverser)
  remote.setBrake(control.brake)
  remote.setIndependentBrake(control.independent_brake)
end

local function ensure_ignition(remote)
  if type(remote.getIgnition) ~= "function" or type(remote.setIgnition) ~= "function" then
    return
  end

  local ok, ignition = pcall(remote.getIgnition)
  if ok and ignition == false then
    pcall(remote.setIgnition, true)
  end
end

local function inspect(remote, requested_cruise_kmh, logger)
  local info, info_error = read_info(remote)
  local consist = read_consist(remote)
  local position, position_error = read_position(remote)
  local characteristics = extract_characteristics(info, consist, requested_cruise_kmh)
  local brake_model = {full_service_mps2 = DEFAULTS.fallback_brake_mps2}
  local pid = derive_pid(characteristics, brake_model)

  if not info then
    emit_line(logger, "info() unavailable: " .. tostring(info_error))
  end
  if not position then
    emit_line(logger, "getPos() unavailable: " .. tostring(position_error))
  end

  print_table("position", position or {}, nil, nil, logger)
  print_table("derived_characteristics", characteristics, nil, nil, logger)
  print_table("baseline_pid", {
    kp = round(pid.kp, 4),
    ki = round(pid.ki, 4),
    kd = round(pid.kd, 4),
    a_drive_mps2 = round(pid.a_drive_mps2, 3),
    a_brake_mps2 = round(pid.a_brake_mps2, 3),
  }, nil, nil, logger)

  if info then
    print_table("raw_info", info, nil, nil, logger)
  end
  if consist then
    print_table("raw_consist", consist, nil, nil, logger)
  end
end

local function control_loop(remote, target, requested_cruise_kmh, stop_buffer_m, logger)
  local info, info_error = read_info(remote)
  if not info then
    return nil, "failed to read train info: " .. tostring(info_error)
  end

  local consist = read_consist(remote)
  local characteristics = extract_characteristics(info, consist, requested_cruise_kmh)
  local brake_model = {full_service_mps2 = DEFAULTS.fallback_brake_mps2, samples = 0}

  local previous_time = nil
  local previous_position = nil
  local previous_speed_toward_target_mps = 0
  local filtered_velocity = {x = 0, y = 0, z = 0}
  local integral = 0
  local previous_error = 0
  local settled_since = nil
  local last_report = 0
  local last_control = {
    throttle = 0,
    reverser = 1,
    brake = 0,
    independent_brake = 0,
  }
  local state = {
    mode = "drive",
    brake_release_until = nil,
    motion_axis = nil,
    active_reverser = 1,
  }

  ensure_ignition(remote)

  while true do
    local now = uptime()
    local position, position_error = read_position(remote)
    if not position then
      apply_controls(remote, {
        throttle = 0,
        reverser = 0,
        brake = 1,
        independent_brake = 1,
      })
      return nil, "failed to read train position: " .. tostring(position_error)
    end

    local dt_s = DEFAULTS.loop_dt_s
    if previous_time then
      dt_s = math.max(now - previous_time, 0.001)
    end

    local velocity_vector = {x = 0, y = 0, z = 0}
    if previous_position then
      velocity_vector = vector_scale(vector_sub(position, previous_position), 1 / dt_s)
    end
    filtered_velocity.x = ema(filtered_velocity.x, velocity_vector.x, DEFAULTS.speed_filter_memory_s, dt_s)
    filtered_velocity.y = ema(filtered_velocity.y, velocity_vector.y, DEFAULTS.speed_filter_memory_s, dt_s)
    filtered_velocity.z = ema(filtered_velocity.z, velocity_vector.z, DEFAULTS.speed_filter_memory_s, dt_s)
    local filtered_speed_mps = vector_length(filtered_velocity)

    if filtered_speed_mps >= DEFAULTS.min_axis_speed_mps then
      state.motion_axis = normalize(filtered_velocity) or state.motion_axis
    end

    local to_target = vector_sub(target, position)
    local axis = state.motion_axis or normalize(to_target) or {x = 1, y = 0, z = 0}
    local longitudinal_m = vector_dot(to_target, axis)
    local lateral_m = vector_length(vector_reject(to_target, axis))
    local remaining_m = math.abs(longitudinal_m)
    local terminal_stop_zone_m = math.max(stop_buffer_m, DEFAULTS.arrival_distance_m + DEFAULTS.terminal_stop_margin_m)
    local desired_reverser = longitudinal_m >= 0 and 1 or -1
    if remaining_m <= terminal_stop_zone_m then
      desired_reverser = state.active_reverser
    end
    local speed_toward_target_mps = vector_dot(filtered_velocity, axis) * desired_reverser

    local pid = derive_pid(characteristics, brake_model)
    local target_speed_mps = stop_speed_cap(remaining_m, stop_buffer_m, brake_model, characteristics.cruise_mps)
    if remaining_m <= terminal_stop_zone_m then
      target_speed_mps = 0
    end
    local speed_error = target_speed_mps - speed_toward_target_mps

    local hold = remaining_m <= DEFAULTS.arrival_distance_m and math.abs(speed_toward_target_mps) <= DEFAULTS.arrival_speed_mps
    local control

    if hold then
      settled_since = settled_since or now
      state.mode = "hold"
      state.active_reverser = desired_reverser
      control = {
        throttle = 0,
        reverser = 0,
        brake = DEFAULTS.hold_brake,
        independent_brake = DEFAULTS.hold_independent_brake,
      }
      if now - settled_since >= DEFAULTS.settle_time_s then
        apply_controls(remote, control)
        emit_line(logger, ("arrived at target with learned brake %.3f m/s^2 after %d samples"):format(
          brake_model.full_service_mps2,
          brake_model.samples
        ))
        return true
      end
    else
      settled_since = nil
      local switching_reverser = desired_reverser ~= state.active_reverser
        and filtered_speed_mps > DEFAULTS.reverser_switch_speed_mps

      if not switching_reverser then
        state.active_reverser = desired_reverser
      end

      state.mode = switching_reverser
        and "brake"
        or select_motion_mode(state, speed_toward_target_mps, target_speed_mps, remaining_m)
      local throttle = 0
      local brake = 0

      if state.mode == "drive" then
        integral = clamp(integral + speed_error * dt_s, -target_speed_mps * 2, target_speed_mps * 2)
        local derivative = (speed_error - previous_error) / dt_s
        local effort = pid.kp * speed_error + pid.ki * integral + pid.kd * derivative
        local throttle_limit = remaining_m <= DEFAULTS.approach_distance_m
          and DEFAULTS.approach_throttle_limit
          or DEFAULTS.cruise_throttle_limit

        if math.abs(speed_toward_target_mps) <= DEFAULTS.restart_from_stop_speed_mps then
          throttle_limit = math.min(throttle_limit, DEFAULTS.launch_throttle_limit)
        end

        throttle = clamp(effort, 0, throttle_limit)
        if throttle < DEFAULTS.throttle_deadband then
          throttle = 0
        end
      elseif state.mode == "brake" then
        -- Resetting the drive integrator while braking avoids the controller
        -- immediately snapping back to throttle after one slow sample.
        integral = 0
        local overspeed = speed_toward_target_mps - target_speed_mps
        brake = clamp(overspeed / math.max(DEFAULTS.enter_brake_margin_mps, 0.05), 0, 1)
        if switching_reverser then
          brake = math.max(brake, 0.4)
        end
        if overspeed >= DEFAULTS.overspeed_full_brake_margin_mps then
          brake = 1
        end
        if brake > 0 and brake < DEFAULTS.min_brake_command then
          brake = DEFAULTS.min_brake_command
        end
        if brake < DEFAULTS.brake_deadband then
          brake = 0
          state.brake_release_until = now + DEFAULTS.brake_release_hold_s
        else
          state.brake_release_until = nil
        end
      else
        integral = 0
        throttle = 0
        brake = 0
      end

      control = {
        throttle = throttle,
        reverser = state.active_reverser,
        brake = brake,
        independent_brake = 0,
      }
    end

    -- Brake learning is tied to measured deceleration so the stopping model can improve
    -- without assuming a hidden API field that might not exist in this IR build.
    if previous_time and previous_speed_toward_target_mps > 0 then
      local observed_decel = math.max((previous_speed_toward_target_mps - speed_toward_target_mps) / dt_s, 0)
      if last_control.brake >= DEFAULTS.brake_learning_min_cmd
        and last_control.throttle <= DEFAULTS.throttle_deadband
        and math.abs(speed_toward_target_mps) >= DEFAULTS.brake_learning_min_speed_mps then
        local effective_command = math.max(
          last_control.brake ^ DEFAULTS.brake_learning_curve_exponent,
          DEFAULTS.brake_learning_floor
        )
        local estimate = observed_decel / effective_command
        brake_model.full_service_mps2 = ema(
          brake_model.full_service_mps2,
          estimate,
          DEFAULTS.brake_learning_memory_s,
          dt_s
        )
        brake_model.samples = brake_model.samples + 1
      end
    end

    apply_controls(remote, control)

    if now - last_report >= DEFAULTS.report_interval_s then
      last_report = now
      emit_line(logger, (
        "mode=%s longitudinal=%.2fm lateral=%.2fm speed=%.2fm/s cap=%.2fm/s reverser=%d throttle=%.2f brake=%.2f brake_model=%.3f\n"
      ):format(
        state.mode,
        remaining_m,
        lateral_m,
        speed_toward_target_mps,
        target_speed_mps,
        state.active_reverser,
        control.throttle,
        control.brake,
        brake_model.full_service_mps2
      ):gsub("\n$", ""))
    end

    previous_time = now
    previous_position = position
    previous_speed_toward_target_mps = speed_toward_target_mps
    previous_error = speed_error
    last_control = control

    sleep_for(DEFAULTS.loop_dt_s)
  end
end

local function parse_cli(argv)
  local positional = {}
  local log_path = nil
  local index = 1

  while index <= #argv do
    local value = argv[index]
    if value == "--log" then
      local next_value = argv[index + 1]
      if next_value and next_value ~= "" and next_value:sub(1, 2) ~= "--" then
        log_path = next_value
        index = index + 2
      else
        log_path = DEFAULTS.log_default_path
        index = index + 1
      end
    elseif value:match("^%-%-log=") then
      log_path = value:match("^%-%-log=(.+)$")
      index = index + 1
    else
      positional[#positional + 1] = value
      index = index + 1
    end
  end

  return {
    argv = positional,
    log_path = log_path,
  }
end

local function parse_number(label, value)
  local number = tonumber(value)
  if not number then
    error(("invalid %s: %s"):format(label, tostring(value)))
  end
  return number
end

local function parse_goto_parameters(argv)
  local cruise_kmh = argv[5] and parse_number("cruise_kmh", argv[5]) or DEFAULTS.cruise_kmh
  local stop_buffer_m = argv[6] and parse_number("stop_buffer_m", argv[6]) or DEFAULTS.stop_buffer_m
  return cruise_kmh, stop_buffer_m
end

local function usage()
  io.write("usage:\n")
  io.write("  trainctl inspect [--log[=path]]\n")
  io.write("  trainctl goto <x> <y> <z> [cruise_kmh] [stop_buffer_m] [--log[=path]]\n")
  io.write("  lua train_controller.lua -- inspect [--log[=path]]\n")
  io.write("  lua train_controller.lua -- goto <x> <y> <z> [cruise_kmh] [stop_buffer_m] [--log[=path]]\n")
end

local function main(argv)
  local cli = parse_cli(argv)
  argv = cli.argv

  if not argv[1] or argv[1] == "help" or argv[1] == "--help" then
    usage()
    return true
  end

  local logger, logger_error = make_logger(cli.log_path)
  if cli.log_path and not logger then
    return nil, "failed to open log file: " .. tostring(logger_error)
  end

  local remote, remote_error = get_remote()
  if not remote then
    close_logger(logger)
    return nil, remote_error
  end

  if argv[1] == "inspect" then
    if logger then
      emit_line(logger, "logging to " .. logger.path)
    end
    inspect(remote, nil, logger)
    close_logger(logger)
    return true
  end

  if argv[1] == "goto" then
    local target = {
      x = parse_number("x", argv[2]),
      y = parse_number("y", argv[3]),
      z = parse_number("z", argv[4]),
    }
    local cruise_kmh, stop_buffer_m = parse_goto_parameters(argv)
    if logger then
      emit_line(logger, ("logging to %s"):format(logger.path))
      emit_line(logger, ("goto x=%s y=%s z=%s cruise_kmh=%s stop_buffer_m=%s"):format(
        target.x,
        target.y,
        target.z,
        cruise_kmh,
        stop_buffer_m
      ))
    end
    local ok, err = control_loop(remote, target, cruise_kmh, stop_buffer_m, logger)
    close_logger(logger)
    return ok, err
  end

  close_logger(logger)
  return nil, "unknown command: " .. tostring(argv[1])
end

local function can_auto_run()
  if component then
    return true
  end
  return pcall(require, "component")
end

local exports = {
  main = main,
}

if ... ~= "__module__" and can_auto_run() then
  local argv = {...}
  local ok, result_or_error = pcall(function()
    local success, err = main(argv)
    if success == nil then
      error(err)
    end
    return success
  end)

  if not ok then
    io.stderr:write(tostring(result_or_error) .. "\n")
    usage()
    os.exit(1)
  end
end

return exports
