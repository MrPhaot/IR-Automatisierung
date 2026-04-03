local DEFAULTS = {
  cruise_kmh = 40,
  stop_buffer_m = 2,
  profile = "conservative",
  arrival_distance_m = 1.5,
  arrival_longitudinal_m = 1.5,
  arrival_lateral_m = 1.5,
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
  approach_stop_distance_m = 18,
  approach_stop_throttle_limit = 0.08,
  approach_stop_margin_m = 1.5,
  approach_stop_brake_cap_mps2 = 1.0,
  approach_stop_hold_speed_mps = 2.0,
  approach_stop_min_brake = 0.2,
  overshoot_recovery_distance_m = 18,
  stop_first_settle_time_s = 0.75,
  near_target_arrival_distance_m = 3.75,
  near_target_arrival_longitudinal_m = 2.5,
  near_target_arrival_lateral_m = 3.0,
  near_target_correction_distance_m = 8.0,
  near_target_correction_longitudinal_m = 5.0,
  near_target_correction_lateral_m = 6.0,
  near_target_correction_speed_mps = 0.8,
  near_target_correction_throttle_limit = 0.05,
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
  reverse_brake_min = 0.4,
  reverse_brake_speed_scale_mps = 2.5,
  axis_capture_speed_mps = 0.75,
  axis_capture_alignment_min = 0.75,
  axis_lock_speed_mps = 0.5,
}

local PROFILES = {
  conservative = {
    name = "conservative",
    stop_cap_brake_scale = 0.6,
    required_stop_margin_m = 5.0,
    no_reverse_distance_m = 42.0,
    force_brake_distance_m = 24.0,
    forward_crawl_speed_mps = 0.6,
    forward_crawl_throttle_limit = 0.04,
    forward_crawl_release_speed_mps = 0.2,
    approach_stop_target_speed_scale = 0.55,
    approach_stop_throttle_scale = 0.45,
    launch_throttle_scale = 0.75,
    brake_exit_margin_mps = 0.2,
    end_phase_integral_decay = 0.35,
  },
  fast = {
    name = "fast",
    stop_cap_brake_scale = 1.0,
    required_stop_margin_m = 1.5,
    no_reverse_distance_m = 22.0,
    force_brake_distance_m = 10.0,
    approach_stop_target_speed_scale = 0.9,
    approach_stop_throttle_scale = 1.0,
    launch_throttle_scale = 1.0,
    brake_exit_margin_mps = 0.9,
    end_phase_integral_decay = 0.85,
  },
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
    {"total_traction_N"},
    {"total_traction_n"},
    {"traction_n"},
    {"tractionN"},
    {"traction"},
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

local HORSEPOWER_PATHS = {
  {"horsepower"},
  {"engine", "horsepower"},
  {"specs", "horsepower"},
}

local HORSEPOWER_TO_W = 745.7

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

local function get_profile(name)
  local profile = PROFILES[name or DEFAULTS.profile]
  if not profile then
    error(("invalid profile: %s (expected conservative or fast)"):format(tostring(name)))
  end
  return profile
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

local function abs_dot(a, b)
  return math.abs(vector_dot(a, b))
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
  -- Prefer consist-level totals when they are present so the controller scales
  -- to the whole train instead of only the currently linked locomotive.
  local mass_kg = pick_number(consist, INFO_PATHS.mass_kg)
    or pick_number(info, INFO_PATHS.mass_kg)
    or DEFAULTS.fallback_mass_kg

  local power_w = pick_number(info, INFO_PATHS.power_w)
    or pick_number(consist, INFO_PATHS.power_w)
  if power_w and power_w < 10000 then
    power_w = power_w * 1000
  end
  if not power_w then
    local horsepower = pick_number(info, HORSEPOWER_PATHS)
      or pick_number(consist, HORSEPOWER_PATHS)
    if horsepower then
      power_w = horsepower * HORSEPOWER_TO_W
    end
  end
  power_w = power_w or DEFAULTS.fallback_power_w

  local traction_n = pick_number(consist, INFO_PATHS.traction_n)
    or pick_number(info, INFO_PATHS.traction_n)
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

local function stop_speed_cap(distance_to_target_m, stop_buffer_m, brake_model, cruise_mps, profile)
  profile = profile or get_profile()
  local usable_distance = math.max(distance_to_target_m - stop_buffer_m, 0)
  local effective_brake_mps2 = math.max(
    math.max(brake_model.full_service_mps2, DEFAULTS.min_brake_mps2) * profile.stop_cap_brake_scale,
    DEFAULTS.min_brake_mps2
  )
  local stop_cap = math.sqrt(2 * effective_brake_mps2 * usable_distance)
  return math.min(cruise_mps, stop_cap)
end

local function conservative_stop_brake_mps2(brake_model)
  return math.max(
    DEFAULTS.min_brake_mps2,
    math.min(brake_model.full_service_mps2, DEFAULTS.approach_stop_brake_cap_mps2)
  )
end

local function required_stop_distance_m(speed_mps, stop_buffer_m, brake_model)
  if speed_mps <= 0 then
    return stop_buffer_m
  end
  local brake_mps2 = conservative_stop_brake_mps2(brake_model)
  return stop_buffer_m + (speed_mps * speed_mps) / (2 * brake_mps2)
end

local function weight_approach_factor(characteristics)
  local weight_ratio = clamp(characteristics.mass_kg / math.max(DEFAULTS.fallback_mass_kg, 1), 0.3, 2.5)
  return clamp(1.15 / math.sqrt(weight_ratio), 0.5, 1.1)
end

local function should_suppress_reverse_recovery(raw_desired_reverser, active_reverser, distance_to_target_m, speed_toward_target_mps, lateral_error_m)
  return raw_desired_reverser ~= active_reverser
    and distance_to_target_m <= DEFAULTS.overshoot_recovery_distance_m
    and math.abs(speed_toward_target_mps) > DEFAULTS.arrival_speed_mps
    and lateral_error_m <= math.max(DEFAULTS.arrival_lateral_m * 4, distance_to_target_m * 0.9)
end

local function is_strict_arrival(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
  return distance_to_target_m <= DEFAULTS.arrival_distance_m
    and longitudinal_distance_m <= DEFAULTS.arrival_longitudinal_m
    and lateral_error_m <= DEFAULTS.arrival_lateral_m
    and math.abs(speed_toward_target_mps) <= DEFAULTS.arrival_speed_mps
end

local function is_near_target_arrival(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
  return distance_to_target_m <= DEFAULTS.near_target_arrival_distance_m
    and longitudinal_distance_m <= DEFAULTS.near_target_arrival_longitudinal_m
    and lateral_error_m <= DEFAULTS.near_target_arrival_lateral_m
    and math.abs(speed_toward_target_mps) <= DEFAULTS.arrival_speed_mps
end

local function is_near_target_correction_candidate(distance_to_target_m, longitudinal_distance_m, lateral_error_m)
  return distance_to_target_m <= DEFAULTS.near_target_correction_distance_m
    and longitudinal_distance_m <= DEFAULTS.near_target_correction_longitudinal_m
    and lateral_error_m <= DEFAULTS.near_target_correction_lateral_m
end

local function should_use_final_forward_crawl(profile, longitudinal_error_m, speed_toward_target_mps, stop_context)
  return profile.name == "conservative"
    and stop_context
    and stop_context.in_no_reverse_approach
    and not stop_context.must_stop_now
    and longitudinal_error_m > DEFAULTS.arrival_longitudinal_m
    and math.abs(speed_toward_target_mps) <= profile.forward_crawl_release_speed_mps
end

local function select_motion_mode(state, speed_toward_target_mps, target_speed_mps, distance_to_target_m, stop_context, profile)
  profile = profile or get_profile()
  local overspeed = speed_toward_target_mps - target_speed_mps
  local must_hold_brake = state.brake_release_until and uptime() < state.brake_release_until

  if state.final_forward_crawl then
    return "drive"
  end

  if state.near_target_correction_active then
    if math.abs(speed_toward_target_mps) <= DEFAULTS.reverser_switch_speed_mps then
      return "drive"
    end
    if speed_toward_target_mps <= -DEFAULTS.move_away_brake_speed_mps then
      return "brake"
    end
  end

  if must_hold_brake then
    return "brake"
  end

  if stop_context and stop_context.must_stop_now then
    return "brake"
  end

  if stop_context and stop_context.in_no_reverse_approach and not state.near_target_correction_active then
    return "brake"
  end

  if distance_to_target_m <= DEFAULTS.arrival_distance_m * 4 and not state.near_target_correction_active then
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

  if state.mode == "brake" and not state.near_target_correction_active and overspeed >= -profile.brake_exit_margin_mps then
    return "brake"
  end

  if target_speed_mps <= DEFAULTS.arrival_speed_mps * 2 then
    return "coast"
  end

  return "drive"
end

local function compute_brake_command(overspeed, minimum)
  local brake = clamp(overspeed / math.max(DEFAULTS.enter_brake_margin_mps, 0.05), 0, 1)
  if overspeed >= DEFAULTS.overspeed_full_brake_margin_mps then
    brake = 1
  end
  if brake > 0 and brake < minimum then
    brake = minimum
  end
  return brake
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

local function control_loop(remote, target, requested_cruise_kmh, stop_buffer_m, profile_name, logger)
  local info, info_error = read_info(remote)
  if not info then
    return nil, "failed to read train info: " .. tostring(info_error)
  end

  local profile = get_profile(profile_name)
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
    phase = "cruise",
    reason = "speed_tracking",
    brake_release_until = nil,
    motion_axis = nil,
    axis_frozen = false,
    active_reverser = 1,
    stop_first_active = false,
    stopped_after_overshoot = false,
    halted_near_target_since = nil,
    near_target_correction_active = false,
    near_target_resolution = "idle",
    final_forward_crawl = false,
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

    local to_target = vector_sub(target, position)
    local distance_to_target_m = vector_length(to_target)
    local terminal_stop_zone_m = math.max(stop_buffer_m, DEFAULTS.arrival_distance_m + DEFAULTS.terminal_stop_margin_m)

    local target_axis = normalize(to_target) or state.motion_axis or {x = 1, y = 0, z = 0}
    if not state.axis_frozen then
      -- Before we trust measured motion, keep the frame anchored to the target
      -- itself so startup jitter cannot redefine "forward" sideways.
      state.motion_axis = target_axis
    end
    if not state.axis_frozen
      and filtered_speed_mps >= DEFAULTS.axis_capture_speed_mps
      and state.phase ~= "reverse_brake"
      and distance_to_target_m > terminal_stop_zone_m then
      local velocity_axis = normalize(filtered_velocity)
      local capture_alignment = velocity_axis and abs_dot(velocity_axis, target_axis) or 0
      -- Freezing the first reliable movement axis avoids the near-stop frame
      -- rotating ninety degrees and falsely collapsing the target projection.
      if velocity_axis and capture_alignment >= DEFAULTS.axis_capture_alignment_min then
        state.motion_axis = velocity_axis
        state.axis_frozen = true
      end
    end

    local axis = state.motion_axis
    local longitudinal_error_m = vector_dot(to_target, axis)
    local lateral_error_m = vector_length(vector_reject(to_target, axis))
    local longitudinal_distance_m = math.abs(longitudinal_error_m)
    local raw_desired_reverser = longitudinal_error_m >= 0 and 1 or -1
    local desired_reverser = raw_desired_reverser
    if distance_to_target_m <= terminal_stop_zone_m then
      desired_reverser = state.active_reverser
    end
    local axis_speed_mps = vector_dot(filtered_velocity, axis)
    local speed_toward_target_mps = axis_speed_mps * desired_reverser

    local pid = derive_pid(characteristics, brake_model)
    local target_speed_mps = stop_speed_cap(
      distance_to_target_m,
      stop_buffer_m,
      brake_model,
      characteristics.cruise_mps,
      profile
    )
    if distance_to_target_m <= terminal_stop_zone_m and lateral_error_m <= DEFAULTS.arrival_lateral_m then
      target_speed_mps = 0
    end
    local required_stop_m = required_stop_distance_m(math.max(speed_toward_target_mps, 0), stop_buffer_m, brake_model)
    local stop_context = {
      required_stop_m = required_stop_m,
      in_approach_stop = distance_to_target_m <= math.max(
        DEFAULTS.approach_stop_distance_m,
        required_stop_m + DEFAULTS.approach_stop_margin_m
      ),
      in_no_reverse_approach = distance_to_target_m <= math.max(
        profile.no_reverse_distance_m,
        required_stop_m + profile.required_stop_margin_m
      ),
      must_stop_now = speed_toward_target_mps > DEFAULTS.arrival_speed_mps
        and required_stop_m + profile.required_stop_margin_m >= distance_to_target_m,
    }
    if stop_context.in_no_reverse_approach then
      target_speed_mps = math.min(target_speed_mps, characteristics.cruise_mps * profile.approach_stop_target_speed_scale)
    end
    if should_use_final_forward_crawl(profile, longitudinal_error_m, speed_toward_target_mps, stop_context) then
      state.final_forward_crawl = true
      state.brake_release_until = nil
      target_speed_mps = math.min(target_speed_mps, profile.forward_crawl_speed_mps)
    elseif state.final_forward_crawl and longitudinal_error_m <= DEFAULTS.arrival_longitudinal_m then
      state.final_forward_crawl = false
    end
    local suppress_reverse_recovery = should_suppress_reverse_recovery(
      raw_desired_reverser,
      state.active_reverser,
      distance_to_target_m,
      speed_toward_target_mps,
      lateral_error_m
    )
    if suppress_reverse_recovery then
      state.stop_first_active = true
      state.near_target_correction_active = false
      state.stopped_after_overshoot = false
      state.near_target_resolution = "stop_first"
      state.final_forward_crawl = false
    end
    if suppress_reverse_recovery then
      desired_reverser = state.active_reverser
      speed_toward_target_mps = axis_speed_mps * desired_reverser
      target_speed_mps = math.min(target_speed_mps, DEFAULTS.arrival_speed_mps)
      required_stop_m = required_stop_distance_m(math.max(speed_toward_target_mps, 0), stop_buffer_m, brake_model)
      stop_context.required_stop_m = required_stop_m
      stop_context.in_approach_stop = true
      stop_context.in_no_reverse_approach = true
      stop_context.must_stop_now = speed_toward_target_mps > DEFAULTS.arrival_speed_mps
    end
    if state.stop_first_active then
      state.final_forward_crawl = false
      desired_reverser = state.active_reverser
      speed_toward_target_mps = axis_speed_mps * desired_reverser
      target_speed_mps = math.min(target_speed_mps, DEFAULTS.arrival_speed_mps)
      stop_context.in_approach_stop = true
      stop_context.in_no_reverse_approach = true
      stop_context.must_stop_now = speed_toward_target_mps > DEFAULTS.arrival_speed_mps

      if math.abs(speed_toward_target_mps) <= DEFAULTS.arrival_speed_mps then
        state.halted_near_target_since = state.halted_near_target_since or now
        if now - state.halted_near_target_since >= DEFAULTS.stop_first_settle_time_s then
          state.stopped_after_overshoot = true
        end
      else
        state.halted_near_target_since = nil
      end
    else
      state.halted_near_target_since = nil
    end

    local near_target_hold = state.stop_first_active
      and state.stopped_after_overshoot
      and is_near_target_arrival(
        distance_to_target_m,
        longitudinal_distance_m,
        lateral_error_m,
        speed_toward_target_mps
      )

    if state.stop_first_active and state.stopped_after_overshoot and not near_target_hold then
      local can_correct = is_near_target_correction_candidate(
        distance_to_target_m,
        longitudinal_distance_m,
        lateral_error_m
      )
      state.stop_first_active = false
      state.stopped_after_overshoot = false
      state.halted_near_target_since = nil
      state.near_target_correction_active = can_correct
      state.near_target_resolution = can_correct and "correct" or "limit"
      state.brake_release_until = nil
    end

    if state.near_target_correction_active then
      target_speed_mps = math.min(target_speed_mps, DEFAULTS.near_target_correction_speed_mps)
      if raw_desired_reverser == state.active_reverser
        and distance_to_target_m > DEFAULTS.overshoot_recovery_distance_m then
        state.near_target_correction_active = false
        state.near_target_resolution = "idle"
      end
    end
    local speed_error = target_speed_mps - speed_toward_target_mps
    local overspeed = speed_toward_target_mps - target_speed_mps
    local switching_reverser = desired_reverser ~= state.active_reverser

    if near_target_hold then
      state.near_target_resolution = "arrive"
    elseif not state.stop_first_active and not state.near_target_correction_active and state.near_target_resolution ~= "limit" then
      state.near_target_resolution = "idle"
    end

    local hold = is_strict_arrival(
      distance_to_target_m,
      longitudinal_distance_m,
      lateral_error_m,
      speed_toward_target_mps
    ) or near_target_hold
    local control

    if hold then
      settled_since = settled_since or now
      state.mode = "hold"
      state.phase = "hold"
      state.reason = near_target_hold and "near_target_arrival" or "arrival_window"
      state.active_reverser = desired_reverser
      state.stop_first_active = false
      state.stopped_after_overshoot = false
      state.halted_near_target_since = nil
      state.near_target_correction_active = false
      state.near_target_resolution = near_target_hold and "arrive" or "idle"
      state.final_forward_crawl = false
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
      local throttle = 0
      local brake = 0

      if state.near_target_resolution == "limit" then
        state.final_forward_crawl = false
        state.mode = "hold"
        state.phase = "hold"
        state.reason = "near_target_limit"
        control = {
          throttle = 0,
          reverser = 0,
          brake = DEFAULTS.hold_brake,
          independent_brake = DEFAULTS.hold_independent_brake,
        }
        apply_controls(remote, control)
        emit_line(logger, ("near-target correction exceeds V1 envelope: distance=%.2fm longitudinal=%.2fm lateral=%.2fm stop_buffer=%.2fm"):format(
          distance_to_target_m,
          longitudinal_error_m,
          lateral_error_m,
          stop_buffer_m
        ))
        return nil, "near-target correction exceeds V1 envelope"
      end

      if switching_reverser and math.abs(axis_speed_mps) > DEFAULTS.reverser_switch_speed_mps then
        state.mode = "brake"
        state.phase = "reverse_brake"
        state.reason = "reverser_mismatch"
        integral = 0
        brake = math.max(
          DEFAULTS.reverse_brake_min,
          clamp(math.abs(axis_speed_mps) / DEFAULTS.reverse_brake_speed_scale_mps, 0, 1)
        )
        state.brake_release_until = nil
      else
        if switching_reverser and math.abs(axis_speed_mps) <= DEFAULTS.reverser_switch_speed_mps then
          state.active_reverser = desired_reverser
          state.phase = "reverse_launch"
          state.reason = "reverser_aligned"
        else
          state.phase = "tracking"
          state.reason = "speed_tracking"
        end

        state.mode = select_motion_mode(
          state,
          speed_toward_target_mps,
          target_speed_mps,
          distance_to_target_m,
          stop_context,
          profile
        )

        if state.mode == "drive" then
          state.reason = state.phase == "reverse_launch" and "restart_after_reverse" or "speed_tracking"
          if stop_context.in_approach_stop or stop_context.in_no_reverse_approach then
            integral = integral * profile.end_phase_integral_decay
          end
          integral = clamp(integral + speed_error * dt_s, -target_speed_mps * 2, target_speed_mps * 2)
          local derivative = (speed_error - previous_error) / dt_s
          local effort = pid.kp * speed_error + pid.ki * integral + pid.kd * derivative
          local weight_factor = weight_approach_factor(characteristics)
          local throttle_limit = distance_to_target_m <= DEFAULTS.approach_distance_m
            and DEFAULTS.approach_throttle_limit * weight_factor
            or DEFAULTS.cruise_throttle_limit

          if math.abs(speed_toward_target_mps) <= DEFAULTS.restart_from_stop_speed_mps then
            throttle_limit = math.min(
              throttle_limit,
              DEFAULTS.launch_throttle_limit * weight_factor * profile.launch_throttle_scale
            )
          end

          if stop_context.in_approach_stop then
            throttle_limit = math.min(
              throttle_limit,
              DEFAULTS.approach_stop_throttle_limit * weight_factor * profile.approach_stop_throttle_scale
            )
          end

          if stop_context.in_no_reverse_approach then
            throttle_limit = math.min(
              throttle_limit,
              DEFAULTS.approach_stop_throttle_limit * weight_factor * profile.approach_stop_throttle_scale
            )
            state.reason = "no_reverse_approach"
          end

          if state.final_forward_crawl then
            target_speed_mps = math.min(target_speed_mps, profile.forward_crawl_speed_mps)
            throttle_limit = math.min(throttle_limit, profile.forward_crawl_throttle_limit)
            state.reason = "final_forward_crawl"
          end

          if stop_context.must_stop_now then
            throttle_limit = 0
          end

          if state.near_target_correction_active then
            throttle_limit = math.min(throttle_limit, DEFAULTS.near_target_correction_throttle_limit)
            state.reason = "near_target_correction"
          end

          throttle = clamp(effort, 0, throttle_limit)
          if throttle < DEFAULTS.throttle_deadband then
            throttle = 0
          end
          if state.phase == "reverse_launch" and math.abs(axis_speed_mps) >= DEFAULTS.axis_lock_speed_mps then
            state.phase = "tracking"
          end
        elseif state.mode == "brake" then
          -- Resetting the drive integrator while braking avoids the controller
          -- immediately snapping back to throttle after one slow sample.
          integral = 0
          if state.stop_first_active then
            state.reason = "terminal_brake"
            brake = math.max(
              DEFAULTS.approach_stop_min_brake,
              compute_brake_command(
                math.max(overspeed, DEFAULTS.enter_brake_margin_mps),
                DEFAULTS.approach_stop_min_brake
              )
            )
          elseif suppress_reverse_recovery then
            state.reason = "terminal_brake"
            brake = math.max(DEFAULTS.min_brake_command, compute_brake_command(
              math.max(overspeed, DEFAULTS.enter_brake_margin_mps),
              DEFAULTS.min_brake_command
            ))
          elseif stop_context.in_approach_stop and speed_toward_target_mps > DEFAULTS.arrival_speed_mps then
            state.reason = "approach_stop"
            brake = math.max(
              DEFAULTS.approach_stop_min_brake,
              compute_brake_command(
                math.max(overspeed, DEFAULTS.enter_brake_margin_mps),
                DEFAULTS.min_brake_command
              )
            )
          elseif stop_context.in_no_reverse_approach then
            if should_use_final_forward_crawl(profile, longitudinal_error_m, speed_toward_target_mps, stop_context) then
              state.final_forward_crawl = true
              state.reason = "final_forward_crawl"
              brake = 0
            else
              state.reason = "final_brake_hold"
              brake = math.max(
                DEFAULTS.approach_stop_min_brake,
                compute_brake_command(
                  math.max(overspeed, DEFAULTS.enter_brake_margin_mps),
                  DEFAULTS.approach_stop_min_brake
                )
              )
            end
          elseif switching_reverser then
            state.reason = "recovery_reverse"
            brake = math.max(
              DEFAULTS.min_brake_command,
              clamp(math.abs(speed_toward_target_mps) / DEFAULTS.reverse_brake_speed_scale_mps, 0, 1)
            )
          elseif stop_context.must_stop_now then
            state.reason = "approach_stop"
            brake = math.max(
              DEFAULTS.min_brake_command,
              compute_brake_command(
                math.max(overspeed, DEFAULTS.enter_brake_margin_mps),
                DEFAULTS.min_brake_command
              )
            )
          elseif speed_toward_target_mps <= -DEFAULTS.move_away_brake_speed_mps then
            state.reason = "moving_away_from_target"
            brake = math.max(
              DEFAULTS.min_brake_command,
              clamp(math.abs(speed_toward_target_mps) / DEFAULTS.reverse_brake_speed_scale_mps, 0, 1)
            )
          else
            state.reason = "overspeed"
            brake = compute_brake_command(overspeed, DEFAULTS.min_brake_command)
          end
          if brake < DEFAULTS.brake_deadband then
            brake = 0
            state.brake_release_until = now + DEFAULTS.brake_release_hold_s
          else
            state.brake_release_until = nil
          end
        else
          state.reason = "low_target_speed"
          integral = 0
          throttle = 0
          brake = 0
        end
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
        "mode=%s phase=%s reason=%s profile=%s final_profile_mode=%s distance=%.2fm longitudinal=%.2fm lateral=%.2fm axis=(%.3f,%.3f,%.3f) axis_frozen=%s required_stop=%.2fm approach_stop=%s no_reverse_approach=%s final_forward_crawl=%s stop_first=%s near_target_correction=%s near_target_resolution=%s speed_toward_target=%.2fm/s axis_speed=%.2fm/s cap=%.2fm/s overspeed=%.2fm/s desired_reverser=%d switching_reverser=%s reverser=%d throttle=%.2f brake=%.2f brake_model=%.3f\n"
      ):format(
        state.mode,
        state.phase,
        state.reason,
        profile.name,
        stop_context.in_no_reverse_approach and "no_reverse_approach" or "normal",
        distance_to_target_m,
        longitudinal_error_m,
        lateral_error_m,
        axis.x,
        axis.y,
        axis.z,
        tostring(state.axis_frozen),
        required_stop_m,
        tostring(stop_context.in_approach_stop),
        tostring(stop_context.in_no_reverse_approach),
        tostring(state.final_forward_crawl),
        tostring(state.stop_first_active),
        tostring(state.near_target_correction_active),
        state.near_target_resolution,
        speed_toward_target_mps,
        axis_speed_mps,
        target_speed_mps,
        overspeed,
        desired_reverser,
        tostring(switching_reverser),
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
  local profile_name = DEFAULTS.profile
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
    elseif value == "--profile" then
      local next_value = argv[index + 1]
      if next_value and next_value ~= "" and next_value:sub(1, 2) ~= "--" then
        profile_name = next_value
        index = index + 2
      else
        error("missing value for --profile (expected conservative or fast)")
      end
    elseif value:match("^%-%-profile=") then
      profile_name = value:match("^%-%-profile=(.+)$")
      index = index + 1
    else
      positional[#positional + 1] = value
      index = index + 1
    end
  end

  get_profile(profile_name)

  return {
    argv = positional,
    log_path = log_path,
    profile_name = profile_name,
  }
end

local function parse_number(label, value)
  local number = tonumber(value)
  if not number then
    error(("invalid %s: %s"):format(label, tostring(value)))
  end
  return number
end

local function parse_goto_parameters(argv, profile_name)
  local cruise_kmh = argv[5] and parse_number("cruise_kmh", argv[5]) or DEFAULTS.cruise_kmh
  local stop_buffer_m = argv[6] and parse_number("stop_buffer_m", argv[6]) or DEFAULTS.stop_buffer_m
  return cruise_kmh, stop_buffer_m, get_profile(profile_name).name
end

local function usage()
  io.write("usage:\n")
  io.write("  trainctl inspect [--log[=path]]\n")
  io.write("  trainctl goto <x> <y> <z> [cruise_kmh] [stop_buffer_m] [--profile=conservative|fast] [--log[=path]]\n")
  io.write("  lua train_controller.lua -- inspect [--log[=path]]\n")
  io.write("  lua train_controller.lua -- goto <x> <y> <z> [cruise_kmh] [stop_buffer_m] [--profile=conservative|fast] [--log[=path]]\n")
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
    local cruise_kmh, stop_buffer_m, profile_name = parse_goto_parameters(argv, cli.profile_name)
    if logger then
      emit_line(logger, ("logging to %s"):format(logger.path))
      emit_line(logger, ("goto x=%s y=%s z=%s cruise_kmh=%s stop_buffer_m=%s profile=%s"):format(
        target.x,
        target.y,
        target.z,
        cruise_kmh,
        stop_buffer_m,
        profile_name
      ))
    end
    local ok, err = control_loop(remote, target, cruise_kmh, stop_buffer_m, profile_name, logger)
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
