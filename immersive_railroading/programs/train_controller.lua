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

local function distance(a, b)
  local dx = b.x - a.x
  local dy = b.y - a.y
  local dz = b.z - a.z
  return math.sqrt(dx * dx + dy * dy + dz * dz)
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

local function select_motion_mode(state, speed_mps, target_speed_mps, remaining_m)
  local overspeed = speed_mps - target_speed_mps
  local must_hold_brake = state.brake_release_until and uptime() < state.brake_release_until

  if must_hold_brake then
    return "brake"
  end

  if remaining_m <= DEFAULTS.arrival_distance_m * 4 then
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

local function print_table(title, value, indent, visited)
  indent = indent or ""
  visited = visited or {}

  if title then
    io.write(title .. "\n")
  end

  if type(value) ~= "table" then
    io.write(indent .. tostring(value) .. "\n")
    return
  end

  if visited[value] then
    io.write(indent .. "<cycle>\n")
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
      io.write(("%s%s:\n"):format(indent, tostring(key)))
      print_table(nil, item, indent .. "  ", visited)
    else
      io.write(("%s%s = %s\n"):format(indent, tostring(key), tostring(item)))
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

local function inspect(remote, requested_cruise_kmh)
  local info, info_error = read_info(remote)
  local consist = read_consist(remote)
  local position, position_error = read_position(remote)
  local characteristics = extract_characteristics(info, consist, requested_cruise_kmh)
  local brake_model = {full_service_mps2 = DEFAULTS.fallback_brake_mps2}
  local pid = derive_pid(characteristics, brake_model)

  if not info then
    io.write("info() unavailable: " .. tostring(info_error) .. "\n")
  end
  if not position then
    io.write("getPos() unavailable: " .. tostring(position_error) .. "\n")
  end

  print_table("position", position or {})
  print_table("derived_characteristics", characteristics)
  print_table("baseline_pid", {
    kp = round(pid.kp, 4),
    ki = round(pid.ki, 4),
    kd = round(pid.kd, 4),
    a_drive_mps2 = round(pid.a_drive_mps2, 3),
    a_brake_mps2 = round(pid.a_brake_mps2, 3),
  })

  if info then
    print_table("raw_info", info)
  end
  if consist then
    print_table("raw_consist", consist)
  end
end

local function control_loop(remote, target, requested_cruise_kmh, stop_buffer_m)
  local info, info_error = read_info(remote)
  if not info then
    return nil, "failed to read train info: " .. tostring(info_error)
  end

  local consist = read_consist(remote)
  local characteristics = extract_characteristics(info, consist, requested_cruise_kmh)
  local brake_model = {full_service_mps2 = DEFAULTS.fallback_brake_mps2, samples = 0}

  local previous_time = nil
  local previous_position = nil
  local previous_speed_mps = 0
  local filtered_speed_mps = 0
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

    local raw_speed_mps = 0
    if previous_position then
      raw_speed_mps = distance(previous_position, position) / dt_s
    end
    filtered_speed_mps = ema(filtered_speed_mps, raw_speed_mps, DEFAULTS.speed_filter_memory_s, dt_s)

    local remaining_m = distance(position, target)
    local pid = derive_pid(characteristics, brake_model)
    local target_speed_mps = stop_speed_cap(remaining_m, stop_buffer_m, brake_model, characteristics.cruise_mps)
    local speed_error = target_speed_mps - filtered_speed_mps

    local hold = remaining_m <= DEFAULTS.arrival_distance_m and filtered_speed_mps <= DEFAULTS.arrival_speed_mps
    local control

    if hold then
      settled_since = settled_since or now
      state.mode = "hold"
      control = {
        throttle = 0,
        reverser = 0,
        brake = DEFAULTS.hold_brake,
        independent_brake = DEFAULTS.hold_independent_brake,
      }
      if now - settled_since >= DEFAULTS.settle_time_s then
        apply_controls(remote, control)
        io.write(("arrived at target with learned brake %.3f m/s^2 after %d samples\n"):format(
          brake_model.full_service_mps2,
          brake_model.samples
        ))
        return true
      end
    else
      settled_since = nil
      state.mode = select_motion_mode(state, filtered_speed_mps, target_speed_mps, remaining_m)
      local throttle = 0
      local brake = 0

      if state.mode == "drive" then
        integral = clamp(integral + speed_error * dt_s, -target_speed_mps * 2, target_speed_mps * 2)
        local derivative = (speed_error - previous_error) / dt_s
        local effort = pid.kp * speed_error + pid.ki * integral + pid.kd * derivative
        local throttle_limit = remaining_m <= DEFAULTS.approach_distance_m
          and DEFAULTS.approach_throttle_limit
          or DEFAULTS.cruise_throttle_limit
        throttle = clamp(effort, 0, throttle_limit)
        if throttle < DEFAULTS.throttle_deadband then
          throttle = 0
        end
      elseif state.mode == "brake" then
        -- Resetting the drive integrator while braking avoids the controller
        -- immediately snapping back to throttle after one slow sample.
        integral = 0
        local overspeed = filtered_speed_mps - target_speed_mps
        brake = clamp(overspeed / math.max(DEFAULTS.enter_brake_margin_mps, 0.05), 0, 1)
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
        reverser = 1,
        brake = brake,
        independent_brake = 0,
      }
    end

    -- Brake learning is tied to measured deceleration so the stopping model can improve
    -- without assuming a hidden API field that might not exist in this IR build.
    if previous_time and previous_speed_mps > 0 then
      local observed_decel = math.max((previous_speed_mps - filtered_speed_mps) / dt_s, 0)
      if last_control.brake >= DEFAULTS.brake_learning_min_cmd
        and last_control.throttle <= DEFAULTS.throttle_deadband
        and filtered_speed_mps >= DEFAULTS.brake_learning_min_speed_mps then
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
      io.write((
        "remaining=%.2fm speed=%.2fm/s cap=%.2fm/s throttle=%.2f brake=%.2f brake_model=%.3f\n"
      ):format(
        remaining_m,
        filtered_speed_mps,
        target_speed_mps,
        control.throttle,
        control.brake,
        brake_model.full_service_mps2
      ))
    end

    previous_time = now
    previous_position = position
    previous_speed_mps = filtered_speed_mps
    previous_error = speed_error
    last_control = control

    sleep_for(DEFAULTS.loop_dt_s)
  end
end

local function parse_number(label, value)
  local number = tonumber(value)
  if not number then
    error(("invalid %s: %s"):format(label, tostring(value)))
  end
  return number
end

local function parse_goto_args(argv)
  local fourth = argv[5] and parse_number("arg4", argv[5]) or nil
  local fifth = argv[6] and parse_number("arg5", argv[6]) or nil

  if fourth == nil and fifth == nil then
    return DEFAULTS.cruise_kmh, DEFAULTS.stop_buffer_m
  end

  if fourth ~= nil and fifth == nil then
    return fourth, DEFAULTS.stop_buffer_m
  end

  -- Accept both orders because early field testing exposed confusion between
  -- cruise speed and stop buffer, and the values are easy to distinguish.
  if fourth <= 10 and fifth > 10 then
    return fifth, fourth
  end

  return fourth, fifth
end

local function usage()
  io.write("usage:\n")
  io.write("  lua programs/train_controller.lua inspect\n")
  io.write("  lua programs/train_controller.lua goto <x> <y> <z> [cruise_kmh] [stop_buffer_m]\n")
  io.write("  lua programs/train_controller.lua goto <x> <y> <z> [stop_buffer_m] [cruise_kmh]\n")
end

local function main(argv)
  if not argv[1] or argv[1] == "help" or argv[1] == "--help" then
    usage()
    return true
  end

  local remote, remote_error = get_remote()
  if not remote then
    return nil, remote_error
  end

  if argv[1] == "inspect" then
    inspect(remote)
    return true
  end

  if argv[1] == "goto" then
    local target = {
      x = parse_number("x", argv[2]),
      y = parse_number("y", argv[3]),
      z = parse_number("z", argv[4]),
    }
    local cruise_kmh, stop_buffer_m = parse_goto_args(argv)
    return control_loop(remote, target, cruise_kmh, stop_buffer_m)
  end

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
