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
  abort_brake = 0.6,
  hold_independent_brake = 1.0,
  speed_filter_memory_s = 0.8,
  distance_progress_memory_s = 1.0,
  moving_away_memory_s = 1.2,
  moving_away_confidence_threshold = 0.55,
  startup_guard_duration_s = 8.0,
  startup_guard_distance_margin_m = 20.0,
  startup_guard_brake_speed_mps = 2.5,
  startup_guard_progress_floor_mps = -1.0,
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
  terminal_settle_time_s = 1.5,
  terminal_stall_timeout_s = 3.0,
  move_away_brake_speed_mps = 0.15,
  curve_guard_alignment = 0.95,
  curve_guard_progress_floor_mps = -0.1,
  restart_from_stop_speed_mps = 0.25,
  launch_throttle_limit = 0.22,
  reverse_brake_min = 0.4,
  reverse_brake_speed_scale_mps = 2.5,
  axis_capture_speed_mps = 0.75,
  axis_capture_alignment_min = 0.75,
  axis_lock_speed_mps = 0.5,
  route_leg_handoff_m = 6.0,
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
    terminal_recovery_speed_mps = 0.6,
    terminal_recovery_throttle_limit = 0.12,
    terminal_recovery_min_throttle = 0.06,
    terminal_recovery_max_longitudinal_m = 24.0,
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
    terminal_recovery_speed_mps = 0.5,
    terminal_recovery_throttle_limit = 0.08,
    terminal_recovery_min_throttle = 0.04,
    terminal_recovery_max_longitudinal_m = 6.0,
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

local function normalize_runtime_error(err)
  if type(err) == "table" then
    return err.reason or err.code or tostring(err)
  end
  return tostring(err)
end

local function is_interrupt_reason(reason)
  reason = tostring(reason or ""):lower()
  return reason:match("interrupted") ~= nil or reason:match("terminated") ~= nil or reason == "terminate"
end

local function sleep_for(seconds)
  if event and type(event.pull) == "function" then
    local ok, signal, a, b, c = pcall(event.pull, seconds)
    if not ok then
      local reason = normalize_runtime_error(signal)
      if is_interrupt_reason(reason) then
        return nil, reason
      end
      error(signal)
    end
    if is_interrupt_reason(signal) then
      return nil, normalize_runtime_error(signal)
    end
    return true, signal, a, b, c
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

local function blend_axes(base_axis, candidate_axis, candidate_weight)
  if not candidate_axis then
    return base_axis
  end
  if not base_axis then
    return candidate_axis
  end

  local aligned_candidate = candidate_axis
  if vector_dot(base_axis, candidate_axis) < 0 then
    aligned_candidate = vector_scale(candidate_axis, -1)
  end

  return normalize({
    x = base_axis.x * (1 - candidate_weight) + aligned_candidate.x * candidate_weight,
    y = base_axis.y * (1 - candidate_weight) + aligned_candidate.y * candidate_weight,
    z = base_axis.z * (1 - candidate_weight) + aligned_candidate.z * candidate_weight,
  }) or base_axis
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

  local power_w = pick_number(consist, INFO_PATHS.power_w)
    or pick_number(info, INFO_PATHS.power_w)
  if power_w and power_w < 10000 then
    power_w = power_w * 1000
  end
  if not power_w then
    local horsepower = pick_number(consist, HORSEPOWER_PATHS)
      or pick_number(info, HORSEPOWER_PATHS)
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

local should_force_moving_away_brake

local function terminal_recovery_block_reason(
  profile,
  state,
  longitudinal_error_m,
  lateral_error_m,
  speed_toward_target_mps,
  axis_speed_mps,
  stop_context,
  raw_desired_reverser
)
  if not stop_context or not stop_context.in_no_reverse_approach then
    return "outside_no_reverse_approach"
  end
  if stop_context.must_stop_now then
    return "must_stop_now"
  end
  if raw_desired_reverser < 0 then
    return "overshot_target"
  end
  if longitudinal_error_m <= DEFAULTS.arrival_longitudinal_m then
    return "inside_arrival_window"
  end
  if longitudinal_error_m > profile.terminal_recovery_max_longitudinal_m then
    return "beyond_recovery_window"
  end
  if lateral_error_m > DEFAULTS.near_target_correction_lateral_m then
    return "lateral_error_too_large"
  end
  if state.stop_first_active or state.near_target_correction_active then
    return "reverse_recovery_active"
  end
  if should_force_moving_away_brake(state, speed_toward_target_mps)
    or state.moving_away_confidence >= DEFAULTS.moving_away_confidence_threshold then
    return "moving_away_risk"
  end
  if math.abs(speed_toward_target_mps) > profile.terminal_recovery_speed_mps then
    return "speed_too_high"
  end
  if math.abs(axis_speed_mps) > math.max(profile.terminal_recovery_speed_mps, DEFAULTS.arrival_speed_mps * 2) then
    return "axis_speed_too_high"
  end
  return nil
end

local function is_terminal_limit_arrival(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps, axis_speed_mps, stop_context)
  return stop_context
    and stop_context.in_no_reverse_approach
    and not is_strict_arrival(
      distance_to_target_m,
      longitudinal_distance_m,
      lateral_error_m,
      speed_toward_target_mps
    )
    and distance_to_target_m <= DEFAULTS.near_target_arrival_distance_m
    and longitudinal_distance_m <= DEFAULTS.near_target_arrival_longitudinal_m
    and lateral_error_m <= DEFAULTS.near_target_arrival_lateral_m
    and math.abs(speed_toward_target_mps) <= DEFAULTS.arrival_speed_mps
    and math.abs(axis_speed_mps) <= DEFAULTS.arrival_speed_mps
end

local function should_fail_terminal_limit(
  distance_to_target_m,
  longitudinal_distance_m,
  lateral_error_m,
  speed_toward_target_mps,
  axis_speed_mps,
  stop_context,
  terminal_recovery_eligible
)
  return stop_context
    and stop_context.in_no_reverse_approach
    and not terminal_recovery_eligible
    and math.abs(speed_toward_target_mps) <= DEFAULTS.arrival_speed_mps
    and math.abs(axis_speed_mps) <= DEFAULTS.arrival_speed_mps
    and not is_terminal_limit_arrival(
      distance_to_target_m,
      longitudinal_distance_m,
      lateral_error_m,
      speed_toward_target_mps,
      axis_speed_mps,
      stop_context
    )
end

local function is_off_target_line_failure(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps, axis_speed_mps, stop_context)
  return stop_context
    and stop_context.in_no_reverse_approach
    and math.abs(speed_toward_target_mps) <= DEFAULTS.arrival_speed_mps
    and math.abs(axis_speed_mps) <= DEFAULTS.arrival_speed_mps
    and distance_to_target_m > DEFAULTS.near_target_arrival_distance_m
    and lateral_error_m > DEFAULTS.near_target_arrival_lateral_m
    and longitudinal_distance_m > DEFAULTS.near_target_arrival_longitudinal_m
end

should_force_moving_away_brake = function(state, speed_toward_target_mps)
  if speed_toward_target_mps > -DEFAULTS.move_away_brake_speed_mps then
    return false
  end
  if state.startup_guard_active then
    if speed_toward_target_mps <= -DEFAULTS.startup_guard_brake_speed_mps then
      return true
    end
    if state.moving_away_confidence < 0.95 or state.progress_speed_mps > DEFAULTS.startup_guard_progress_floor_mps then
      return false
    end
  end
  if state.curve_guard_active and state.moving_away_confidence < DEFAULTS.moving_away_confidence_threshold then
    return false
  end
  return true
end

local function select_motion_mode(state, speed_toward_target_mps, target_speed_mps, distance_to_target_m, stop_context, profile)
  profile = profile or get_profile()
  local overspeed = speed_toward_target_mps - target_speed_mps
  local must_hold_brake = state.brake_release_until and uptime() < state.brake_release_until
  local must_stop_now = stop_context and stop_context.must_stop_now

  if state.final_forward_crawl and not must_stop_now then
    return "drive"
  end

  if state.near_target_correction_active then
    if math.abs(speed_toward_target_mps) <= DEFAULTS.reverser_switch_speed_mps then
      return "drive"
    end
    if should_force_moving_away_brake(state, speed_toward_target_mps) then
      return "brake"
    end
  end

  if must_hold_brake then
    return "brake"
  end

  if must_stop_now then
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
  if should_force_moving_away_brake(state, speed_toward_target_mps) then
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

local function safe_stop_control(brake)
  return {
    throttle = 0,
    reverser = 0,
    brake = brake or DEFAULTS.hold_brake,
    independent_brake = DEFAULTS.hold_independent_brake,
  }
end

local function apply_safe_stop(remote, brake)
  local control = safe_stop_control(brake)
  local failures = {}
  local setters = {
    {"setBrake", control.brake},
    {"setIndependentBrake", control.independent_brake},
    {"setThrottle", control.throttle},
    {"setReverser", control.reverser},
  }

  for _, setter in ipairs(setters) do
    local method_name, value = setter[1], setter[2]
    local ok, err = pcall(remote[method_name], value)
    if not ok then
      failures[#failures + 1] = ("%s: %s"):format(method_name, normalize_runtime_error(err))
    end
  end

  if #failures > 0 then
    error("safe stop failed: " .. table.concat(failures, "; "))
  end
end

local function abort_run(remote, logger, reason, distance_to_target_m, longitudinal_error_m, lateral_error_m, speed_toward_target_mps, axis_speed_mps)
  local stop_ok, stop_error = pcall(apply_safe_stop, remote, DEFAULTS.abort_brake)
  if not stop_ok then
    local normalized_stop_error = normalize_runtime_error(stop_error)
    emit_line(logger, "abort safe stop failed: " .. tostring(normalized_stop_error))
    local retry_ok, retry_error = pcall(apply_safe_stop, remote, DEFAULTS.abort_brake)
    if not retry_ok then
      emit_line(logger, "abort safe stop retry failed: " .. tostring(normalize_runtime_error(retry_error)))
    end
  end
  emit_line(logger, ("aborted_by_user reason=%s distance=%.2fm longitudinal=%.2fm lateral=%.2fm speed_toward_target=%.2fm/s axis_speed=%.2fm/s"):format(
    tostring(reason),
    distance_to_target_m or 0,
    longitudinal_error_m or 0,
    lateral_error_m or 0,
    speed_toward_target_mps or 0,
    axis_speed_mps or 0
  ))
  return nil, "aborted by user"
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

local function make_runtime_context(remote, requested_cruise_kmh)
  local info, info_error = read_info(remote)
  if not info then
    return nil, "failed to read train info: " .. tostring(info_error)
  end

  local consist = read_consist(remote)
  return {
    characteristics = extract_characteristics(info, consist, requested_cruise_kmh),
    brake_model = {full_service_mps2 = DEFAULTS.fallback_brake_mps2, samples = 0},
    previous_time = nil,
    previous_position = nil,
    previous_distance_to_target_m = nil,
    previous_speed_toward_target_mps = 0,
    filtered_velocity = {x = 0, y = 0, z = 0},
    integral = 0,
    previous_error = 0,
    settled_since = nil,
    last_report = 0,
    last_control = {
      throttle = 0,
      reverser = 1,
      brake = 0,
      independent_brake = 0,
    },
    active_reverser = 1,
  }
end

local function begin_leg(runtime_context)
  runtime_context.previous_distance_to_target_m = nil
  runtime_context.previous_speed_toward_target_mps = 0
  runtime_context.integral = 0
  runtime_context.previous_error = 0
  runtime_context.settled_since = nil

  return {
    mode = "drive",
    phase = "cruise",
    reason = "speed_tracking",
    started_at = uptime(),
    brake_release_until = nil,
    motion_axis = nil,
    target_line_axis = nil,
    axis_source = "target",
    axis_alignment = 1,
    startup_guard_active = true,
    progress_speed_mps = 0,
    distance_delta_m = 0,
    moving_away_confidence = 0,
    curve_guard_active = false,
    active_reverser = runtime_context.active_reverser or 1,
    stop_first_active = false,
    stopped_after_overshoot = false,
    halted_near_target_since = nil,
    near_target_correction_active = false,
    near_target_resolution = "idle",
    final_forward_crawl = false,
    terminal_recovery_active = false,
    terminal_recovery_eligible = false,
    terminal_recovery_block_reason = "inactive",
    terminal_settle_since = nil,
    terminal_failure_since = nil,
    terminal_failure_pending = false,
    terminal_failure_elapsed_s = 0,
    initial_distance_to_target_m = nil,
  }
end

local function waypoint_plane_crossed(previous_position, position, leg)
  if not previous_position or not leg.next_target then
    return false
  end

  local next_leg_axis = normalize(vector_sub(leg.next_target, leg.target))
  if not next_leg_axis then
    return false
  end

  local previous_projection = vector_dot(vector_sub(previous_position, leg.target), next_leg_axis)
  local current_projection = vector_dot(vector_sub(position, leg.target), next_leg_axis)
  return previous_projection < 0 and current_projection >= 0
end

local function pass_through_handoff_reason(distance_to_target_m, previous_position, position, leg)
  if distance_to_target_m <= DEFAULTS.route_leg_handoff_m then
    return "within_handoff_distance"
  end
  if waypoint_plane_crossed(previous_position, position, leg) then
    return "crossed_waypoint_plane"
  end
  return nil
end

local function control_loop(remote, target, requested_cruise_kmh, stop_buffer_m, profile_name, logger)
  local info, info_error = read_info(remote)
  if not info then
    local normalized_info_error = normalize_runtime_error(info_error)
    if is_interrupt_reason(normalized_info_error) then
      return abort_run(remote, logger, normalized_info_error)
    end
    return nil, "failed to read train info: " .. tostring(normalized_info_error)
  end

  local profile = get_profile(profile_name)
  local consist = read_consist(remote)
  local characteristics = extract_characteristics(info, consist, requested_cruise_kmh)
  local brake_model = {full_service_mps2 = DEFAULTS.fallback_brake_mps2, samples = 0}

  local previous_time = nil
  local previous_position = nil
  local previous_distance_to_target_m = nil
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
    started_at = uptime(),
    brake_release_until = nil,
    motion_axis = nil,
    target_line_axis = nil,
    axis_source = "target",
    axis_alignment = 1,
    startup_guard_active = true,
    progress_speed_mps = 0,
    distance_delta_m = 0,
    moving_away_confidence = 0,
    curve_guard_active = false,
    active_reverser = 1,
    stop_first_active = false,
    stopped_after_overshoot = false,
    halted_near_target_since = nil,
    near_target_correction_active = false,
    near_target_resolution = "idle",
    final_forward_crawl = false,
    terminal_recovery_active = false,
    terminal_recovery_eligible = false,
    terminal_recovery_block_reason = "inactive",
    terminal_settle_since = nil,
    terminal_failure_since = nil,
    terminal_failure_pending = false,
    terminal_failure_elapsed_s = 0,
  }

  ensure_ignition(remote)

  while true do
    local now = uptime()
    local position, position_error = read_position(remote)
    if not position then
      local normalized_position_error = normalize_runtime_error(position_error)
      if is_interrupt_reason(normalized_position_error) then
        return abort_run(remote, logger, normalized_position_error)
      end
      local stop_ok, stop_error = pcall(apply_safe_stop, remote, 1)
      if not stop_ok then
        local normalized_stop_error = normalize_runtime_error(stop_error)
        if is_interrupt_reason(normalized_stop_error) then
          return abort_run(remote, logger, normalized_stop_error)
        end
        return nil, ("failed to read train position: %s (emergency stop also failed: %s)"):format(
          tostring(normalized_position_error),
          tostring(normalized_stop_error)
        )
      end
      return nil, "failed to read train position: " .. tostring(normalized_position_error)
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
    state.initial_distance_to_target_m = state.initial_distance_to_target_m or distance_to_target_m
    local raw_progress_speed_mps = 0
    if previous_distance_to_target_m then
      raw_progress_speed_mps = (previous_distance_to_target_m - distance_to_target_m) / dt_s
    end
    state.distance_delta_m = previous_distance_to_target_m and (distance_to_target_m - previous_distance_to_target_m) or 0
    state.progress_speed_mps = ema(
      state.progress_speed_mps,
      raw_progress_speed_mps,
      DEFAULTS.distance_progress_memory_s,
      dt_s
    ) or raw_progress_speed_mps
    local terminal_stop_zone_m = math.max(stop_buffer_m, DEFAULTS.arrival_distance_m + DEFAULTS.terminal_stop_margin_m)

    if not state.target_line_axis then
      state.target_line_axis = normalize(to_target) or {x = 1, y = 0, z = 0}
    end

    local fresh_target_axis = normalize(to_target)
    if fresh_target_axis and distance_to_target_m > terminal_stop_zone_m then
      -- The target line stays anchored to the route geometry so startup drift
      -- cannot permanently redefine where "forward to the point" lies.
      state.target_line_axis = blend_axes(state.target_line_axis, fresh_target_axis, 0.1)
    end

    local target_axis = state.target_line_axis
    local velocity_axis = filtered_speed_mps >= DEFAULTS.axis_capture_speed_mps and normalize(filtered_velocity) or nil
    local capture_alignment = velocity_axis and abs_dot(velocity_axis, target_axis) or 0
    state.axis_alignment = capture_alignment

    if velocity_axis and state.phase ~= "reverse_brake" and distance_to_target_m > terminal_stop_zone_m
      and capture_alignment >= DEFAULTS.axis_capture_alignment_min then
      state.motion_axis = blend_axes(target_axis, velocity_axis, 0.25)
      state.axis_source = "blended"
    else
      state.motion_axis = target_axis
      state.axis_source = "target"
    end

    local motion_axis = state.motion_axis
    local longitudinal_error_m = vector_dot(to_target, target_axis)
    local lateral_error_m = vector_length(vector_reject(to_target, target_axis))
    local longitudinal_distance_m = math.abs(longitudinal_error_m)
    local raw_desired_reverser = longitudinal_error_m >= 0 and 1 or -1
    local desired_reverser = raw_desired_reverser
    if distance_to_target_m <= terminal_stop_zone_m then
      desired_reverser = state.active_reverser
    end
    local axis_speed_mps = vector_dot(filtered_velocity, target_axis)
    local motion_axis_speed_mps = vector_dot(filtered_velocity, motion_axis)
    local speed_toward_target_mps = motion_axis_speed_mps * desired_reverser
    state.startup_guard_active = ((now - state.started_at) <= DEFAULTS.startup_guard_duration_s)
      and distance_to_target_m <= state.initial_distance_to_target_m + DEFAULTS.startup_guard_distance_margin_m
    state.curve_guard_active = state.axis_alignment < DEFAULTS.curve_guard_alignment
      and state.progress_speed_mps >= DEFAULTS.curve_guard_progress_floor_mps
    local moving_away_sample = (speed_toward_target_mps <= -DEFAULTS.move_away_brake_speed_mps and state.progress_speed_mps < 0) and 1 or 0
    state.moving_away_confidence = ema(
      state.moving_away_confidence,
      moving_away_sample,
      DEFAULTS.moving_away_memory_s,
      dt_s
    ) or moving_away_sample

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
    local terminal_recovery_block = terminal_recovery_block_reason(
      profile,
      state,
      longitudinal_error_m,
      lateral_error_m,
      speed_toward_target_mps,
      axis_speed_mps,
      stop_context,
      raw_desired_reverser
    ) or "eligible"
    local terminal_recovery_eligible = terminal_recovery_block == "eligible"
    if should_use_final_forward_crawl(profile, longitudinal_error_m, speed_toward_target_mps, stop_context)
      or terminal_recovery_eligible then
      state.final_forward_crawl = true
      state.brake_release_until = nil
      target_speed_mps = math.min(target_speed_mps, profile.terminal_recovery_speed_mps or profile.forward_crawl_speed_mps)
    elseif state.final_forward_crawl and longitudinal_error_m <= DEFAULTS.arrival_longitudinal_m then
      state.final_forward_crawl = false
    elseif state.final_forward_crawl then
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
      speed_toward_target_mps = motion_axis_speed_mps * desired_reverser
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
      speed_toward_target_mps = motion_axis_speed_mps * desired_reverser
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
    local terminal_limit_hold = is_terminal_limit_arrival(
      distance_to_target_m,
      longitudinal_distance_m,
      lateral_error_m,
      speed_toward_target_mps,
      axis_speed_mps,
      stop_context
    )
    if terminal_limit_hold then
      state.terminal_settle_since = state.terminal_settle_since or now
      if now - state.terminal_settle_since >= DEFAULTS.terminal_settle_time_s then
        hold = true
      end
    else
      state.terminal_settle_since = nil
    end
    local terminal_limit_failure = should_fail_terminal_limit(
      distance_to_target_m,
      longitudinal_distance_m,
      lateral_error_m,
      speed_toward_target_mps,
      axis_speed_mps,
      stop_context,
      terminal_recovery_eligible
    )
    if terminal_limit_failure then
      state.terminal_failure_since = state.terminal_failure_since or now
      if now - state.terminal_failure_since >= DEFAULTS.terminal_stall_timeout_s then
        local stop_ok, stop_error = pcall(apply_safe_stop, remote)
        if not stop_ok then
          local normalized_stop_error = normalize_runtime_error(stop_error)
          if is_interrupt_reason(normalized_stop_error) then
            return abort_run(
              remote,
              logger,
              normalized_stop_error,
              distance_to_target_m,
              longitudinal_error_m,
              lateral_error_m,
              speed_toward_target_mps,
              axis_speed_mps
            )
          end
          return nil, "failed to apply terminal safe stop: " .. tostring(normalized_stop_error)
        end
        local terminal_reason = is_off_target_line_failure(
          distance_to_target_m,
          longitudinal_distance_m,
          lateral_error_m,
          speed_toward_target_mps,
          axis_speed_mps,
          stop_context
        ) and "stalled_off_target_line" or "stalled_outside_v1_limit"
        emit_line(logger, ("terminal_limit_exit reason=%s distance=%.2fm longitudinal=%.2fm lateral=%.2fm speed_toward_target=%.2fm/s axis_speed=%.2fm/s"):format(
          terminal_reason,
          distance_to_target_m,
          longitudinal_error_m,
          lateral_error_m,
          speed_toward_target_mps,
          axis_speed_mps
        ))
        return nil, "stalled outside V1 terminal envelope"
      end
    else
      state.terminal_failure_since = nil
    end
    state.terminal_recovery_active = state.final_forward_crawl
    state.terminal_recovery_eligible = terminal_recovery_eligible
    state.terminal_recovery_block_reason = terminal_recovery_block
    state.terminal_failure_pending = state.terminal_failure_since ~= nil
    state.terminal_failure_elapsed_s = state.terminal_failure_since and (now - state.terminal_failure_since) or 0
    local control

    if hold then
      settled_since = settled_since or now
      state.mode = "hold"
      state.phase = "hold"
      state.reason = terminal_limit_hold and "arrived_within_v1_limit"
        or (near_target_hold and "near_target_arrival" or "arrival_window")
      state.active_reverser = desired_reverser
      state.stop_first_active = false
      state.stopped_after_overshoot = false
      state.halted_near_target_since = nil
      state.near_target_correction_active = false
      state.near_target_resolution = near_target_hold and "arrive" or "idle"
      state.final_forward_crawl = false
      state.terminal_failure_since = nil
      control = {
        throttle = 0,
        reverser = 0,
        brake = DEFAULTS.hold_brake,
        independent_brake = DEFAULTS.hold_independent_brake,
      }
      if now - settled_since >= DEFAULTS.settle_time_s then
        local hold_ok, hold_error = pcall(apply_safe_stop, remote, control.brake)
        if not hold_ok then
          local normalized_hold_error = normalize_runtime_error(hold_error)
          if is_interrupt_reason(normalized_hold_error) then
            return abort_run(
              remote,
              logger,
              normalized_hold_error,
              distance_to_target_m,
              longitudinal_error_m,
              lateral_error_m,
              speed_toward_target_mps,
              axis_speed_mps
            )
          end
          return nil, "failed to apply arrival hold controls: " .. tostring(normalized_hold_error)
        end
        local completion_reason = terminal_limit_hold and "arrived_within_v1_limit" or "arrived_at_target"
        emit_line(logger, ("%s learned_brake=%.3f m/s^2 samples=%d distance=%.2fm longitudinal=%.2fm lateral=%.2fm"):format(
          completion_reason,
          brake_model.full_service_mps2,
          brake_model.samples,
          distance_to_target_m,
          longitudinal_error_m,
          lateral_error_m
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
        local hold_ok, hold_error = pcall(apply_safe_stop, remote, control.brake)
        if not hold_ok then
          local normalized_hold_error = normalize_runtime_error(hold_error)
          if is_interrupt_reason(normalized_hold_error) then
            return abort_run(
              remote,
              logger,
              normalized_hold_error,
              distance_to_target_m,
              longitudinal_error_m,
              lateral_error_m,
              speed_toward_target_mps,
              axis_speed_mps
            )
          end
          return nil, "failed to apply near-target limit hold controls: " .. tostring(normalized_hold_error)
        end
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
            target_speed_mps = math.min(target_speed_mps, profile.terminal_recovery_speed_mps or profile.forward_crawl_speed_mps)
            throttle_limit = math.min(throttle_limit, profile.terminal_recovery_throttle_limit or profile.forward_crawl_throttle_limit)
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
          if state.final_forward_crawl
            and throttle_limit > 0
            and longitudinal_error_m > DEFAULTS.arrival_longitudinal_m
            and math.abs(speed_toward_target_mps) <= (profile.terminal_recovery_speed_mps or profile.forward_crawl_speed_mps) then
            throttle = math.max(
              throttle,
              math.min(
                profile.terminal_recovery_min_throttle or profile.forward_crawl_throttle_limit,
                throttle_limit
              )
            )
          end
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
            if should_use_final_forward_crawl(profile, longitudinal_error_m, speed_toward_target_mps, stop_context)
              or terminal_recovery_eligible then
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
          elseif should_force_moving_away_brake(state, speed_toward_target_mps) then
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

    local apply_ok, apply_error = pcall(apply_controls, remote, control)
    if not apply_ok then
      local reason = normalize_runtime_error(apply_error)
      if is_interrupt_reason(reason) then
        return abort_run(
          remote,
          logger,
          reason,
          distance_to_target_m,
          longitudinal_error_m,
          lateral_error_m,
          speed_toward_target_mps,
          axis_speed_mps
        )
      end
      error(apply_error)
    end

    if now - last_report >= DEFAULTS.report_interval_s then
      last_report = now
      emit_line(logger, (
        "mode=%s phase=%s reason=%s profile=%s final_profile_mode=%s distance=%.2fm longitudinal=%.2fm lateral=%.2fm target_axis=(%.3f,%.3f,%.3f) motion_axis=(%.3f,%.3f,%.3f) axis_source=%s alignment_to_target=%.3f distance_delta=%.2fm progress_speed=%.2fm/s moving_away_confidence=%.2f startup_guard_active=%s curve_guard_active=%s required_stop=%.2fm approach_stop=%s no_reverse_approach=%s final_forward_crawl=%s terminal_recovery_active=%s terminal_recovery_eligible=%s terminal_recovery_block_reason=%s terminal_failure_pending=%s terminal_failure_elapsed_s=%.2f stop_first=%s near_target_correction=%s near_target_resolution=%s speed_toward_target=%.2fm/s axis_speed=%.2fm/s motion_axis_speed=%.2fm/s cap=%.2fm/s overspeed=%.2fm/s desired_reverser=%d switching_reverser=%s reverser=%d throttle=%.2f brake=%.2f brake_model=%.3f\n"
      ):format(
        state.mode,
        state.phase,
        state.reason,
        profile.name,
        stop_context.in_no_reverse_approach and "no_reverse_approach" or "normal",
        distance_to_target_m,
        longitudinal_error_m,
        lateral_error_m,
        target_axis.x,
        target_axis.y,
        target_axis.z,
        motion_axis.x,
        motion_axis.y,
        motion_axis.z,
        state.axis_source,
        state.axis_alignment,
        state.distance_delta_m,
        state.progress_speed_mps,
        state.moving_away_confidence,
        tostring(state.startup_guard_active),
        tostring(state.curve_guard_active),
        required_stop_m,
        tostring(stop_context.in_approach_stop),
        tostring(stop_context.in_no_reverse_approach),
        tostring(state.final_forward_crawl),
        tostring(state.terminal_recovery_active),
        tostring(state.terminal_recovery_eligible),
        state.terminal_recovery_block_reason,
        tostring(state.terminal_failure_pending),
        state.terminal_failure_elapsed_s,
        tostring(state.stop_first_active),
        tostring(state.near_target_correction_active),
        state.near_target_resolution,
        speed_toward_target_mps,
        axis_speed_mps,
        motion_axis_speed_mps,
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
    previous_distance_to_target_m = distance_to_target_m
    previous_speed_toward_target_mps = speed_toward_target_mps
    previous_error = speed_error
    last_control = control

    local sleep_ok, sleep_reason = sleep_for(DEFAULTS.loop_dt_s)
    if not sleep_ok then
      return abort_run(
        remote,
        logger,
        sleep_reason,
        distance_to_target_m,
        longitudinal_error_m,
        lateral_error_m,
        speed_toward_target_mps,
        axis_speed_mps
      )
    end
  end
end

local function parse_cli(argv)
  local positional = {}
  local log_path = nil
  local profile_name = DEFAULTS.profile
  local profile_explicit = false
  local via_points = {}
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
      local inline_log_path = value:match("^%-%-log=(.*)$")
      if inline_log_path == nil or inline_log_path == "" then
        error("missing value for --log=path")
      end
      log_path = inline_log_path
      index = index + 1
    elseif value == "--profile" then
      local next_value = argv[index + 1]
      if next_value and next_value ~= "" and next_value:sub(1, 2) ~= "--" then
        profile_name = next_value
        profile_explicit = true
        index = index + 2
      else
        error("missing value for --profile (expected conservative or fast)")
      end
    elseif value:match("^%-%-profile=") then
      local inline_profile_name = value:match("^%-%-profile=(.*)$")
      if inline_profile_name == nil or inline_profile_name == "" then
        error("missing value for --profile (expected conservative or fast)")
      end
      profile_name = inline_profile_name
      profile_explicit = true
      index = index + 1
    elseif value == "--via" then
      local x = argv[index + 1]
      local y = argv[index + 2]
      local z = argv[index + 3]
      if not x or not y or not z or x:sub(1, 2) == "--" or y:sub(1, 2) == "--" or z:sub(1, 2) == "--" then
        error("missing value for --via <x> <y> <z>")
      end
      via_points[#via_points + 1] = {x = x, y = y, z = z}
      index = index + 4
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
    profile_explicit = profile_explicit,
    via_points = via_points,
  }
end

local function parse_number(label, value)
  local number = tonumber(value)
  if not number then
    error(("invalid %s: %s"):format(label, tostring(value)))
  end
  return number
end

local function copy_point(point)
  return {
    x = point.x,
    y = point.y,
    z = point.z,
  }
end

local function format_point(point)
  return ("(%.2f,%.2f,%.2f)"):format(point.x, point.y, point.z)
end

local function parse_cli_point(label, raw_point)
  return {
    x = parse_number(label .. ".x", raw_point.x),
    y = parse_number(label .. ".y", raw_point.y),
    z = parse_number(label .. ".z", raw_point.z),
  }
end

local function normalize_route_waypoint(route_name, waypoint_index, value, stations)
  local label = ("route %s waypoint %d"):format(route_name, waypoint_index)
  if type(value) == "string" then
    local station = stations[value]
    if not station then
      error(("%s references unknown station: %s"):format(label, value))
    end
    return parse_cli_point(label, station)
  end
  if type(value) ~= "table" then
    error(("%s must be a station id or {x=..., y=..., z=...} table"):format(label))
  end
  return parse_cli_point(label, value)
end

local function route_book_path()
  return join_paths(script_directory(), "route_book.lua")
end

local function load_route_book()
  local chunk, load_error = loadfile(route_book_path())
  if not chunk then
    return nil, load_error
  end

  local ok, route_book_or_error = pcall(chunk)
  if not ok then
    return nil, normalize_runtime_error(route_book_or_error)
  end
  if type(route_book_or_error) ~= "table" then
    return nil, "route_book.lua must return a table"
  end

  route_book_or_error.STATIONS = route_book_or_error.STATIONS or {}
  route_book_or_error.ROUTES = route_book_or_error.ROUTES or {}
  return route_book_or_error
end

local function build_route_plan(route_name, waypoints, cruise_kmh, stop_buffer_m, profile_name)
  if type(waypoints) ~= "table" or #waypoints == 0 then
    error(("route %s has no waypoints"):format(route_name))
  end

  local legs = {}
  for index, waypoint in ipairs(waypoints) do
    legs[index] = {
      index = index,
      count = #waypoints,
      mode = index < #waypoints and "pass_through" or "terminal",
      target = copy_point(waypoint),
      next_target = waypoints[index + 1] and copy_point(waypoints[index + 1]) or nil,
    }
  end

  return {
    name = route_name,
    cruise_kmh = cruise_kmh,
    stop_buffer_m = stop_buffer_m,
    profile_name = profile_name,
    legs = legs,
  }
end

local function build_goto_route_plan(argv, cli)
  if not argv[2] or not argv[3] or not argv[4] then
    error("goto requires <x> <y> <z>")
  end
  if argv[7] then
    error("goto accepts only <x> <y> <z> [cruise_kmh] [stop_buffer_m] plus flags")
  end

  local waypoints = {}
  for index, raw_point in ipairs(cli.via_points) do
    waypoints[#waypoints + 1] = parse_cli_point(("via %d"):format(index), raw_point)
  end
  waypoints[#waypoints + 1] = {
    x = parse_number("x", argv[2]),
    y = parse_number("y", argv[3]),
    z = parse_number("z", argv[4]),
  }

  local cruise_kmh = argv[5] and parse_number("cruise_kmh", argv[5]) or DEFAULTS.cruise_kmh
  local stop_buffer_m = argv[6] and parse_number("stop_buffer_m", argv[6]) or DEFAULTS.stop_buffer_m
  return build_route_plan("inline", waypoints, cruise_kmh, stop_buffer_m, get_profile(cli.profile_name).name)
end

local function build_named_route_plan(route_name, cli, route_book)
  if not route_book then
    local loaded_route_book, route_book_error = load_route_book()
    if not loaded_route_book then
      error("failed to load route book: " .. tostring(route_book_error))
    end
    route_book = loaded_route_book
  end

  local stations = route_book.STATIONS or {}
  local routes = route_book.ROUTES or {}
  local route = routes[route_name]
  if type(route) ~= "table" then
    error("unknown route: " .. tostring(route_name))
  end

  if type(route.waypoints) ~= "table" or #route.waypoints == 0 then
    error(("route %s must define at least one waypoint"):format(route_name))
  end

  local waypoints = {}
  for index, waypoint in ipairs(route.waypoints) do
    waypoints[#waypoints + 1] = normalize_route_waypoint(route_name, index, waypoint, stations)
  end

  local cruise_kmh = route.cruise_kmh and parse_number(("route %s cruise_kmh"):format(route_name), route.cruise_kmh)
    or DEFAULTS.cruise_kmh
  local stop_buffer_m = route.stop_buffer_m and parse_number(("route %s stop_buffer_m"):format(route_name), route.stop_buffer_m)
    or DEFAULTS.stop_buffer_m
  local profile_name = cli.profile_explicit and cli.profile_name
    or route.profile
    or DEFAULTS.profile

  return build_route_plan(route_name, waypoints, cruise_kmh, stop_buffer_m, get_profile(profile_name).name)
end

local function run_route_leg(remote, route_plan, leg, runtime_context, leg_transition_reason, logger)
  local profile = get_profile(route_plan.profile_name)
  local characteristics = runtime_context.characteristics
  local brake_model = runtime_context.brake_model
  local state = begin_leg(runtime_context)
  local target = leg.target

  while true do
    local now = uptime()
    local position, position_error = read_position(remote)
    if not position then
      local normalized_position_error = normalize_runtime_error(position_error)
      if is_interrupt_reason(normalized_position_error) then
        return abort_run(remote, logger, normalized_position_error)
      end
      local stop_ok, stop_error = pcall(apply_safe_stop, remote, 1)
      if not stop_ok then
        local normalized_stop_error = normalize_runtime_error(stop_error)
        if is_interrupt_reason(normalized_stop_error) then
          return abort_run(remote, logger, normalized_stop_error)
        end
        return nil, ("failed to read train position: %s (emergency stop also failed: %s)"):format(
          tostring(normalized_position_error),
          tostring(normalized_stop_error)
        )
      end
      return nil, "failed to read train position: " .. tostring(normalized_position_error)
    end

    local dt_s = DEFAULTS.loop_dt_s
    if runtime_context.previous_time then
      dt_s = math.max(now - runtime_context.previous_time, 0.001)
    end

    local velocity_vector = {x = 0, y = 0, z = 0}
    if runtime_context.previous_position then
      velocity_vector = vector_scale(vector_sub(position, runtime_context.previous_position), 1 / dt_s)
    end
    runtime_context.filtered_velocity.x = ema(runtime_context.filtered_velocity.x, velocity_vector.x, DEFAULTS.speed_filter_memory_s, dt_s)
    runtime_context.filtered_velocity.y = ema(runtime_context.filtered_velocity.y, velocity_vector.y, DEFAULTS.speed_filter_memory_s, dt_s)
    runtime_context.filtered_velocity.z = ema(runtime_context.filtered_velocity.z, velocity_vector.z, DEFAULTS.speed_filter_memory_s, dt_s)
    local filtered_speed_mps = vector_length(runtime_context.filtered_velocity)

    local to_target = vector_sub(target, position)
    local distance_to_target_m = vector_length(to_target)
    state.initial_distance_to_target_m = state.initial_distance_to_target_m or distance_to_target_m
    local raw_progress_speed_mps = 0
    if runtime_context.previous_distance_to_target_m then
      raw_progress_speed_mps = (runtime_context.previous_distance_to_target_m - distance_to_target_m) / dt_s
    end
    state.distance_delta_m = runtime_context.previous_distance_to_target_m
      and (distance_to_target_m - runtime_context.previous_distance_to_target_m)
      or 0
    state.progress_speed_mps = ema(
      state.progress_speed_mps,
      raw_progress_speed_mps,
      DEFAULTS.distance_progress_memory_s,
      dt_s
    ) or raw_progress_speed_mps

    local terminal_stop_zone_m = math.max(
      route_plan.stop_buffer_m,
      DEFAULTS.arrival_distance_m + DEFAULTS.terminal_stop_margin_m
    )

    if not state.target_line_axis then
      state.target_line_axis = normalize(to_target) or {x = 1, y = 0, z = 0}
    end

    local fresh_target_axis = normalize(to_target)
    if fresh_target_axis and (leg.mode ~= "terminal" or distance_to_target_m > terminal_stop_zone_m) then
      -- Each leg keeps its own route frame so a completed waypoint can hand the controller
      -- a fresh direction reference before the old target vector becomes misleading.
      state.target_line_axis = blend_axes(state.target_line_axis, fresh_target_axis, 0.1)
    end

    local target_axis = state.target_line_axis
    local velocity_axis = filtered_speed_mps >= DEFAULTS.axis_capture_speed_mps and normalize(runtime_context.filtered_velocity) or nil
    local capture_alignment = velocity_axis and abs_dot(velocity_axis, target_axis) or 0
    state.axis_alignment = capture_alignment

    if velocity_axis and state.phase ~= "reverse_brake"
      and (leg.mode ~= "terminal" or distance_to_target_m > terminal_stop_zone_m)
      and capture_alignment >= DEFAULTS.axis_capture_alignment_min then
      state.motion_axis = blend_axes(target_axis, velocity_axis, 0.25)
      state.axis_source = "blended"
    else
      state.motion_axis = target_axis
      state.axis_source = "target"
    end

    local motion_axis = state.motion_axis
    local longitudinal_error_m = vector_dot(to_target, target_axis)
    local lateral_error_m = vector_length(vector_reject(to_target, target_axis))
    local longitudinal_distance_m = math.abs(longitudinal_error_m)
    local raw_desired_reverser = longitudinal_error_m >= 0 and 1 or -1
    local desired_reverser = raw_desired_reverser
    if leg.mode == "terminal" and distance_to_target_m <= terminal_stop_zone_m then
      desired_reverser = state.active_reverser
    end
    local axis_speed_mps = vector_dot(runtime_context.filtered_velocity, target_axis)
    local motion_axis_speed_mps = vector_dot(runtime_context.filtered_velocity, motion_axis)
    local speed_toward_target_mps = motion_axis_speed_mps * desired_reverser
    state.startup_guard_active = ((now - state.started_at) <= DEFAULTS.startup_guard_duration_s)
      and distance_to_target_m <= state.initial_distance_to_target_m + DEFAULTS.startup_guard_distance_margin_m
    state.curve_guard_active = state.axis_alignment < DEFAULTS.curve_guard_alignment
      and state.progress_speed_mps >= DEFAULTS.curve_guard_progress_floor_mps
    local moving_away_sample = (speed_toward_target_mps <= -DEFAULTS.move_away_brake_speed_mps and state.progress_speed_mps < 0) and 1 or 0
    state.moving_away_confidence = ema(
      state.moving_away_confidence,
      moving_away_sample,
      DEFAULTS.moving_away_memory_s,
      dt_s
    ) or moving_away_sample

    if leg.mode == "pass_through" then
      local handoff_reason = pass_through_handoff_reason(
        distance_to_target_m,
        runtime_context.previous_position,
        position,
        leg
      )
      if handoff_reason then
        runtime_context.previous_time = now
        runtime_context.previous_position = position
        runtime_context.active_reverser = state.active_reverser
        return "handoff", handoff_reason
      end
    end

    local pid = derive_pid(characteristics, brake_model)
    local target_speed_mps = leg.mode == "terminal"
      and stop_speed_cap(
        distance_to_target_m,
        route_plan.stop_buffer_m,
        brake_model,
        characteristics.cruise_mps,
        profile
      )
      or characteristics.cruise_mps

    if leg.mode == "terminal"
      and distance_to_target_m <= terminal_stop_zone_m
      and lateral_error_m <= DEFAULTS.arrival_lateral_m then
      target_speed_mps = 0
    end

    local required_stop_m = 0
    local stop_context = {
      required_stop_m = 0,
      in_approach_stop = false,
      in_no_reverse_approach = false,
      must_stop_now = false,
    }
    local suppress_reverse_recovery = false
    local near_target_hold = false
    local hold = false
    local terminal_limit_hold = false
    local terminal_recovery_eligible = false
    local terminal_recovery_block = leg.mode == "terminal" and "outside_no_reverse_approach" or "non_terminal_leg"

    if leg.mode == "terminal" then
      required_stop_m = required_stop_distance_m(
        math.max(speed_toward_target_mps, 0),
        route_plan.stop_buffer_m,
        brake_model
      )
      stop_context = {
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

      terminal_recovery_block = terminal_recovery_block_reason(
        profile,
        state,
        longitudinal_error_m,
        lateral_error_m,
        speed_toward_target_mps,
        axis_speed_mps,
        stop_context,
        raw_desired_reverser
      ) or "eligible"
      terminal_recovery_eligible = terminal_recovery_block == "eligible"

      if should_use_final_forward_crawl(profile, longitudinal_error_m, speed_toward_target_mps, stop_context)
        or terminal_recovery_eligible then
        state.final_forward_crawl = true
        state.brake_release_until = nil
        target_speed_mps = math.min(
          target_speed_mps,
          profile.terminal_recovery_speed_mps or profile.forward_crawl_speed_mps
        )
      elseif state.final_forward_crawl and longitudinal_error_m <= DEFAULTS.arrival_longitudinal_m then
        state.final_forward_crawl = false
      elseif state.final_forward_crawl then
        state.final_forward_crawl = false
      end

      suppress_reverse_recovery = should_suppress_reverse_recovery(
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
        speed_toward_target_mps = motion_axis_speed_mps * desired_reverser
        target_speed_mps = math.min(target_speed_mps, DEFAULTS.arrival_speed_mps)
        required_stop_m = required_stop_distance_m(
          math.max(speed_toward_target_mps, 0),
          route_plan.stop_buffer_m,
          brake_model
        )
        stop_context.required_stop_m = required_stop_m
        stop_context.in_approach_stop = true
        stop_context.in_no_reverse_approach = true
        stop_context.must_stop_now = speed_toward_target_mps > DEFAULTS.arrival_speed_mps
      end
      if state.stop_first_active then
        state.final_forward_crawl = false
        desired_reverser = state.active_reverser
        speed_toward_target_mps = motion_axis_speed_mps * desired_reverser
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

      near_target_hold = state.stop_first_active
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
    end

    local speed_error = target_speed_mps - speed_toward_target_mps
    local overspeed = speed_toward_target_mps - target_speed_mps
    local switching_reverser = desired_reverser ~= state.active_reverser

    if leg.mode == "terminal" then
      if near_target_hold then
        state.near_target_resolution = "arrive"
      elseif not state.stop_first_active
        and not state.near_target_correction_active
        and state.near_target_resolution ~= "limit" then
        state.near_target_resolution = "idle"
      end

      hold = is_strict_arrival(
        distance_to_target_m,
        longitudinal_distance_m,
        lateral_error_m,
        speed_toward_target_mps
      ) or near_target_hold
      terminal_limit_hold = is_terminal_limit_arrival(
        distance_to_target_m,
        longitudinal_distance_m,
        lateral_error_m,
        speed_toward_target_mps,
        axis_speed_mps,
        stop_context
      )
      if terminal_limit_hold then
        state.terminal_settle_since = state.terminal_settle_since or now
        if now - state.terminal_settle_since >= DEFAULTS.terminal_settle_time_s then
          hold = true
        end
      else
        state.terminal_settle_since = nil
      end

      local terminal_limit_failure = should_fail_terminal_limit(
        distance_to_target_m,
        longitudinal_distance_m,
        lateral_error_m,
        speed_toward_target_mps,
        axis_speed_mps,
        stop_context,
        terminal_recovery_eligible
      )
      if terminal_limit_failure then
        state.terminal_failure_since = state.terminal_failure_since or now
        if now - state.terminal_failure_since >= DEFAULTS.terminal_stall_timeout_s then
          local stop_ok, stop_error = pcall(apply_safe_stop, remote)
          if not stop_ok then
            local normalized_stop_error = normalize_runtime_error(stop_error)
            if is_interrupt_reason(normalized_stop_error) then
              return abort_run(
                remote,
                logger,
                normalized_stop_error,
                distance_to_target_m,
                longitudinal_error_m,
                lateral_error_m,
                speed_toward_target_mps,
                axis_speed_mps
              )
            end
            return nil, "failed to apply terminal safe stop: " .. tostring(normalized_stop_error)
          end
          local terminal_reason = is_off_target_line_failure(
            distance_to_target_m,
            longitudinal_distance_m,
            lateral_error_m,
            speed_toward_target_mps,
            axis_speed_mps,
            stop_context
          ) and "stalled_off_target_line" or "stalled_outside_v1_limit"
          emit_line(logger, ("terminal_limit_exit route_name=%s leg=%d/%d reason=%s distance=%.2fm longitudinal=%.2fm lateral=%.2fm speed_toward_target=%.2fm/s axis_speed=%.2fm/s"):format(
            route_plan.name,
            leg.index,
            leg.count,
            terminal_reason,
            distance_to_target_m,
            longitudinal_error_m,
            lateral_error_m,
            speed_toward_target_mps,
            axis_speed_mps
          ))
          return nil, "stalled outside V1 terminal envelope"
        end
      else
        state.terminal_failure_since = nil
      end

      state.terminal_recovery_active = state.final_forward_crawl
      state.terminal_recovery_eligible = terminal_recovery_eligible
      state.terminal_recovery_block_reason = terminal_recovery_block
      state.terminal_failure_pending = state.terminal_failure_since ~= nil
      state.terminal_failure_elapsed_s = state.terminal_failure_since and (now - state.terminal_failure_since) or 0
    else
      state.terminal_recovery_active = false
      state.terminal_recovery_eligible = false
      state.terminal_recovery_block_reason = "pass_through_leg"
      state.terminal_failure_pending = false
      state.terminal_failure_elapsed_s = 0
    end

    local control
    if hold then
      runtime_context.settled_since = runtime_context.settled_since or now
      state.mode = "hold"
      state.phase = "hold"
      state.reason = terminal_limit_hold and "arrived_within_v1_limit"
        or (near_target_hold and "near_target_arrival" or "arrival_window")
      state.active_reverser = desired_reverser
      state.stop_first_active = false
      state.stopped_after_overshoot = false
      state.halted_near_target_since = nil
      state.near_target_correction_active = false
      state.near_target_resolution = near_target_hold and "arrive" or "idle"
      state.final_forward_crawl = false
      state.terminal_failure_since = nil
      control = {
        throttle = 0,
        reverser = 0,
        brake = DEFAULTS.hold_brake,
        independent_brake = DEFAULTS.hold_independent_brake,
      }
      if now - runtime_context.settled_since >= DEFAULTS.settle_time_s then
        local hold_ok, hold_error = pcall(apply_safe_stop, remote, control.brake)
        if not hold_ok then
          local normalized_hold_error = normalize_runtime_error(hold_error)
          if is_interrupt_reason(normalized_hold_error) then
            return abort_run(
              remote,
              logger,
              normalized_hold_error,
              distance_to_target_m,
              longitudinal_error_m,
              lateral_error_m,
              speed_toward_target_mps,
              axis_speed_mps
            )
          end
          return nil, "failed to apply arrival hold controls: " .. tostring(normalized_hold_error)
        end
        local completion_reason = terminal_limit_hold and "arrived_within_v1_limit" or "arrived_at_target"
        emit_line(logger, ("%s route_name=%s leg=%d/%d learned_brake=%.3f m/s^2 samples=%d distance=%.2fm longitudinal=%.2fm lateral=%.2fm"):format(
          completion_reason,
          route_plan.name,
          leg.index,
          leg.count,
          brake_model.full_service_mps2,
          brake_model.samples,
          distance_to_target_m,
          longitudinal_error_m,
          lateral_error_m
        ))
        return "complete"
      end
    else
      runtime_context.settled_since = nil
      local throttle = 0
      local brake = 0

      if leg.mode == "terminal" and state.near_target_resolution == "limit" then
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
        local hold_ok, hold_error = pcall(apply_safe_stop, remote, control.brake)
        if not hold_ok then
          local normalized_hold_error = normalize_runtime_error(hold_error)
          if is_interrupt_reason(normalized_hold_error) then
            return abort_run(
              remote,
              logger,
              normalized_hold_error,
              distance_to_target_m,
              longitudinal_error_m,
              lateral_error_m,
              speed_toward_target_mps,
              axis_speed_mps
            )
          end
          return nil, "failed to apply near-target limit hold controls: " .. tostring(normalized_hold_error)
        end
        emit_line(logger, ("near-target correction exceeds V1 envelope route_name=%s leg=%d/%d distance=%.2fm longitudinal=%.2fm lateral=%.2fm stop_buffer=%.2fm"):format(
          route_plan.name,
          leg.index,
          leg.count,
          distance_to_target_m,
          longitudinal_error_m,
          lateral_error_m,
          route_plan.stop_buffer_m
        ))
        return nil, "near-target correction exceeds V1 envelope"
      end

      if switching_reverser and math.abs(axis_speed_mps) > DEFAULTS.reverser_switch_speed_mps then
        state.mode = "brake"
        state.phase = "reverse_brake"
        state.reason = "reverser_mismatch"
        runtime_context.integral = 0
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
            runtime_context.integral = runtime_context.integral * profile.end_phase_integral_decay
          end
          runtime_context.integral = clamp(
            runtime_context.integral + speed_error * dt_s,
            -target_speed_mps * 2,
            target_speed_mps * 2
          )
          local derivative = (speed_error - runtime_context.previous_error) / dt_s
          local effort = pid.kp * speed_error + pid.ki * runtime_context.integral + pid.kd * derivative
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
            target_speed_mps = math.min(
              target_speed_mps,
              profile.terminal_recovery_speed_mps or profile.forward_crawl_speed_mps
            )
            throttle_limit = math.min(
              throttle_limit,
              profile.terminal_recovery_throttle_limit or profile.forward_crawl_throttle_limit
            )
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
          if state.final_forward_crawl
            and throttle_limit > 0
            and longitudinal_error_m > DEFAULTS.arrival_longitudinal_m
            and math.abs(speed_toward_target_mps) <= (profile.terminal_recovery_speed_mps or profile.forward_crawl_speed_mps) then
            throttle = math.max(
              throttle,
              math.min(
                profile.terminal_recovery_min_throttle or profile.forward_crawl_throttle_limit,
                throttle_limit
              )
            )
          end
          if throttle < DEFAULTS.throttle_deadband then
            throttle = 0
          end
          if state.phase == "reverse_launch" and math.abs(axis_speed_mps) >= DEFAULTS.axis_lock_speed_mps then
            state.phase = "tracking"
          end
        elseif state.mode == "brake" then
          runtime_context.integral = 0
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
            brake = math.max(
              DEFAULTS.min_brake_command,
              compute_brake_command(
                math.max(overspeed, DEFAULTS.enter_brake_margin_mps),
                DEFAULTS.min_brake_command
              )
            )
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
            if should_use_final_forward_crawl(profile, longitudinal_error_m, speed_toward_target_mps, stop_context)
              or terminal_recovery_eligible then
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
          elseif should_force_moving_away_brake(state, speed_toward_target_mps) then
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
          runtime_context.integral = 0
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

    if runtime_context.previous_time and runtime_context.previous_speed_toward_target_mps > 0 then
      local observed_decel = math.max((runtime_context.previous_speed_toward_target_mps - speed_toward_target_mps) / dt_s, 0)
      if runtime_context.last_control.brake >= DEFAULTS.brake_learning_min_cmd
        and runtime_context.last_control.throttle <= DEFAULTS.throttle_deadband
        and math.abs(speed_toward_target_mps) >= DEFAULTS.brake_learning_min_speed_mps then
        local effective_command = math.max(
          runtime_context.last_control.brake ^ DEFAULTS.brake_learning_curve_exponent,
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

    local apply_ok, apply_error = pcall(apply_controls, remote, control)
    if not apply_ok then
      local reason = normalize_runtime_error(apply_error)
      if is_interrupt_reason(reason) then
        return abort_run(
          remote,
          logger,
          reason,
          distance_to_target_m,
          longitudinal_error_m,
          lateral_error_m,
          speed_toward_target_mps,
          axis_speed_mps
        )
      end
      error(apply_error)
    end

    if now - runtime_context.last_report >= DEFAULTS.report_interval_s then
      runtime_context.last_report = now
      local final_profile_mode = leg.mode == "pass_through"
        and "pass_through"
        or (stop_context.in_no_reverse_approach and "no_reverse_approach" or "normal")
      emit_line(logger, (
        "mode=%s phase=%s reason=%s profile=%s final_profile_mode=%s distance=%.2fm longitudinal=%.2fm lateral=%.2fm target_axis=(%.3f,%.3f,%.3f) motion_axis=(%.3f,%.3f,%.3f) axis_source=%s alignment_to_target=%.3f distance_delta=%.2fm progress_speed=%.2fm/s moving_away_confidence=%.2f startup_guard_active=%s curve_guard_active=%s required_stop=%.2fm approach_stop=%s no_reverse_approach=%s final_forward_crawl=%s terminal_recovery_active=%s terminal_recovery_eligible=%s terminal_recovery_block_reason=%s terminal_failure_pending=%s terminal_failure_elapsed_s=%.2f stop_first=%s near_target_correction=%s near_target_resolution=%s speed_toward_target=%.2fm/s axis_speed=%.2fm/s motion_axis_speed=%.2fm/s cap=%.2fm/s overspeed=%.2fm/s desired_reverser=%d switching_reverser=%s reverser=%d throttle=%.2f brake=%.2f brake_model=%.3f route_name=%s leg=%d/%d leg_mode=%s leg_target=%s leg_transition_reason=%s\n"
      ):format(
        state.mode,
        state.phase,
        state.reason,
        profile.name,
        final_profile_mode,
        distance_to_target_m,
        longitudinal_error_m,
        lateral_error_m,
        target_axis.x,
        target_axis.y,
        target_axis.z,
        motion_axis.x,
        motion_axis.y,
        motion_axis.z,
        state.axis_source,
        state.axis_alignment,
        state.distance_delta_m,
        state.progress_speed_mps,
        state.moving_away_confidence,
        tostring(state.startup_guard_active),
        tostring(state.curve_guard_active),
        required_stop_m,
        tostring(stop_context.in_approach_stop),
        tostring(stop_context.in_no_reverse_approach),
        tostring(state.final_forward_crawl),
        tostring(state.terminal_recovery_active),
        tostring(state.terminal_recovery_eligible),
        state.terminal_recovery_block_reason,
        tostring(state.terminal_failure_pending),
        state.terminal_failure_elapsed_s,
        tostring(state.stop_first_active),
        tostring(state.near_target_correction_active),
        state.near_target_resolution,
        speed_toward_target_mps,
        axis_speed_mps,
        motion_axis_speed_mps,
        target_speed_mps,
        overspeed,
        desired_reverser,
        tostring(switching_reverser),
        state.active_reverser,
        control.throttle,
        control.brake,
        brake_model.full_service_mps2,
        route_plan.name,
        leg.index,
        leg.count,
        leg.mode,
        format_point(target),
        leg_transition_reason or "route_start"
      ):gsub("\n$", ""))
    end

    runtime_context.previous_time = now
    runtime_context.previous_position = position
    runtime_context.previous_distance_to_target_m = distance_to_target_m
    runtime_context.previous_speed_toward_target_mps = speed_toward_target_mps
    runtime_context.previous_error = speed_error
    runtime_context.last_control = control
    runtime_context.active_reverser = state.active_reverser

    local sleep_ok, sleep_reason = sleep_for(DEFAULTS.loop_dt_s)
    if not sleep_ok then
      return abort_run(
        remote,
        logger,
        sleep_reason,
        distance_to_target_m,
        longitudinal_error_m,
        lateral_error_m,
        speed_toward_target_mps,
        axis_speed_mps
      )
    end
  end
end

local function execute_route_plan(remote, route_plan, logger)
  local runtime_context, runtime_error = make_runtime_context(remote, route_plan.cruise_kmh)
  if not runtime_context then
    return nil, runtime_error
  end

  ensure_ignition(remote)
  emit_line(logger, ("route_start route_name=%s legs=%d cruise_kmh=%s stop_buffer_m=%s profile=%s first_target=%s"):format(
    route_plan.name,
    #route_plan.legs,
    route_plan.cruise_kmh,
    route_plan.stop_buffer_m,
    route_plan.profile_name,
    format_point(route_plan.legs[1].target)
  ))

  local leg_transition_reason = "route_start"
  for _, leg in ipairs(route_plan.legs) do
    local status, detail = run_route_leg(remote, route_plan, leg, runtime_context, leg_transition_reason, logger)
    if status == nil then
      return nil, detail
    end
    if status == "complete" then
      return true
    end

    local next_leg = route_plan.legs[leg.index + 1]
    if not next_leg then
      return nil, "route ended without terminal completion"
    end
    emit_line(logger, ("route_leg_transition route_name=%s leg=%d/%d leg_mode=%s reason=%s leg_target=%s next_leg=%d/%d next_target=%s"):format(
      route_plan.name,
      leg.index,
      leg.count,
      leg.mode,
      detail,
      format_point(leg.target),
      next_leg.index,
      next_leg.count,
      format_point(next_leg.target)
    ))
    leg_transition_reason = detail
  end

  return nil, "route ended without terminal completion"
end

local function parse_goto_parameters(argv, profile_name)
  local cruise_kmh = argv[5] and parse_number("cruise_kmh", argv[5]) or DEFAULTS.cruise_kmh
  local stop_buffer_m = argv[6] and parse_number("stop_buffer_m", argv[6]) or DEFAULTS.stop_buffer_m
  return cruise_kmh, stop_buffer_m, get_profile(profile_name).name
end

local function usage()
  io.write("usage:\n")
  io.write("  trainctl inspect [--log[=path]]\n")
  io.write("  trainctl goto <x> <y> <z> [cruise_kmh] [stop_buffer_m] [--via <x> <y> <z> ...] [--profile=conservative|fast] [--log[=path]]\n")
  io.write("  trainctl route <name> [--profile=conservative|fast] [--log[=path]]\n")
  io.write("  lua train_controller.lua -- inspect [--log[=path]]\n")
  io.write("  lua train_controller.lua -- goto <x> <y> <z> [cruise_kmh] [stop_buffer_m] [--via <x> <y> <z> ...] [--profile=conservative|fast] [--log[=path]]\n")
  io.write("  lua train_controller.lua -- route <name> [--profile=conservative|fast] [--log[=path]]\n")
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
    if #cli.via_points > 0 then
      close_logger(logger)
      return nil, "inspect does not accept --via"
    end
    if logger then
      emit_line(logger, "logging to " .. logger.path)
    end
    inspect(remote, nil, logger)
    close_logger(logger)
    return true
  end

  if argv[1] == "goto" then
    local route_plan = build_goto_route_plan(argv, cli)
    if logger then
      emit_line(logger, ("logging to %s"):format(logger.path))
      emit_line(logger, ("goto final_target=%s cruise_kmh=%s stop_buffer_m=%s profile=%s via_count=%d"):format(
        format_point(route_plan.legs[#route_plan.legs].target),
        route_plan.cruise_kmh,
        route_plan.stop_buffer_m,
        route_plan.profile_name,
        #cli.via_points
      ))
    end
    local ok, err = execute_route_plan(remote, route_plan, logger)
    close_logger(logger)
    return ok, err
  end

  if argv[1] == "route" then
    if #cli.via_points > 0 then
      close_logger(logger)
      return nil, "route does not accept --via"
    end
    if not argv[2] then
      close_logger(logger)
      return nil, "route requires <name>"
    end
    if argv[3] then
      close_logger(logger)
      return nil, "route accepts only <name> plus flags"
    end

    local route_plan = build_named_route_plan(argv[2], cli)
    if logger then
      emit_line(logger, ("logging to %s"):format(logger.path))
      emit_line(logger, ("route name=%s cruise_kmh=%s stop_buffer_m=%s profile=%s legs=%d"):format(
        route_plan.name,
        route_plan.cruise_kmh,
        route_plan.stop_buffer_m,
        route_plan.profile_name,
        #route_plan.legs
      ))
    end
    local ok, err = execute_route_plan(remote, route_plan, logger)
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
  DEFAULTS = DEFAULTS,
  PROFILES = PROFILES,
  INFO_PATHS = INFO_PATHS,
  HORSEPOWER_PATHS = HORSEPOWER_PATHS,
  HORSEPOWER_TO_W = HORSEPOWER_TO_W,
  parse_cli = parse_cli,
  build_goto_route_plan = build_goto_route_plan,
  build_named_route_plan = build_named_route_plan,
  load_route_book = load_route_book,
  execute_route_plan = execute_route_plan,
}

if ... ~= "__module__" and can_auto_run() then
  local argv = {...}
  local ok, success, err = pcall(main, argv)

  if not ok then
    local reason = normalize_runtime_error(success)
    io.stderr:write(reason .. "\n")
    if is_interrupt_reason(reason) then
      os.exit(130)
    end
    usage()
    os.exit(1)
  end

  if success == nil then
    local reason = normalize_runtime_error(err)
    io.stderr:write(reason .. "\n")
    if err == "aborted by user" or is_interrupt_reason(reason) then
      os.exit(130)
    end
    usage()
    os.exit(1)
  end
end

return exports
