local function clamp(value, low, high)
  if value < low then
    return low
  end
  if value > high then
    return high
  end
  return value
end

local function ema(previous, sample, memory_s, dt_s)
  if previous == nil then
    return sample
  end
  local alpha = clamp(dt_s / math.max(memory_s, dt_s), 0, 1)
  return previous + (sample - previous) * alpha
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

local function pick_number(source, paths)
  if type(source) ~= "table" then
    return nil
  end

  for _, path in ipairs(paths) do
    local value = get_nested(source, path)
    if type(value) == "string" then
      value = tonumber(value)
    end
    if type(value) == "number" then
      return value
    end
  end

  return nil
end

local function derive_pid(mass_kg, power_w, traction_n, cruise_kmh, brake_mps2)
  local v_ref_mps = math.max(cruise_kmh / 3.6, 4.0)
  local a_drive = math.min(traction_n / mass_kg, power_w / math.max(v_ref_mps, 1) / mass_kg)
  local t_drive = v_ref_mps / a_drive
  local t_brake = v_ref_mps / brake_mps2

  return {
    kp = 1 / v_ref_mps,
    ki = (1 / v_ref_mps) / t_brake,
    kd = (1 / v_ref_mps) * math.min(t_drive, t_brake),
  }
end

local function learn_brake(initial_brake_mps2, prev_speed_mps, curr_speed_mps, dt_s, brake_cmd)
  local observed = math.max((prev_speed_mps - curr_speed_mps) / dt_s, 0)
  local full_service = observed / math.max(brake_cmd ^ 1.2, 0.05)
  return ema(initial_brake_mps2, full_service, 12.0, dt_s)
end

local function stop_speed_cap(remaining_m, stop_buffer_m, brake_mps2, cruise_kmh)
  local cruise_mps = cruise_kmh / 3.6
  return math.min(
    cruise_mps,
    math.sqrt(2 * brake_mps2 * math.max(remaining_m - stop_buffer_m, 0))
  )
end

local function target_speed_cap(distance_to_target_m, lateral_error_m, stop_buffer_m, brake_mps2, cruise_kmh)
  local cruise_mps = cruise_kmh / 3.6
  local cap = stop_speed_cap(distance_to_target_m, stop_buffer_m, brake_mps2, cruise_kmh)
  local terminal_stop_zone_m = math.max(stop_buffer_m, 1.5 + 0.75)
  if distance_to_target_m <= terminal_stop_zone_m and lateral_error_m <= 1.5 then
    return 0
  end
  return math.min(cap, cruise_mps)
end

local function normalize(vector)
  local length = math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
  if length <= 0 then
    return nil
  end
  return {
    x = vector.x / length,
    y = vector.y / length,
    z = vector.z / length,
  }
end

local function abs_dot(a, b)
  return math.abs(a.x * b.x + a.y * b.y + a.z * b.z)
end

local function should_capture_axis(to_target, filtered_velocity, capture_speed_mps, alignment_min)
  local speed = math.sqrt(
    filtered_velocity.x * filtered_velocity.x +
    filtered_velocity.y * filtered_velocity.y +
    filtered_velocity.z * filtered_velocity.z
  )
  if speed < capture_speed_mps then
    return false
  end

  local target_axis = normalize(to_target)
  local velocity_axis = normalize(filtered_velocity)
  if not target_axis or not velocity_axis then
    return false
  end

  return abs_dot(target_axis, velocity_axis) >= alignment_min
end

local function extract_characteristics(info, consist, requested_cruise_kmh)
  local mass_paths = {
    {"weight_kg"},
    {"mass_kg"},
    {"weight"},
  }
  local traction_paths = {
    {"total_traction_N"},
    {"traction"},
  }
  local power_paths = {
    {"power_w"},
    {"power_kw"},
  }
  local horsepower_paths = {
    {"horsepower"},
  }
  local max_speed_paths = {
    {"max_speed"},
    {"max_speed_kmh"},
  }

  local mass_kg = pick_number(consist, mass_paths)
    or pick_number(info, mass_paths)
    or 425000

  local traction_n = pick_number(consist, traction_paths)
    or pick_number(info, traction_paths)
    or 180000

  local power_w = pick_number(info, power_paths)
    or pick_number(consist, power_paths)
  if power_w and power_w < 10000 then
    power_w = power_w * 1000
  end
  if not power_w then
    local horsepower = pick_number(info, horsepower_paths)
      or pick_number(consist, horsepower_paths)
    if horsepower then
      power_w = horsepower * 745.7
    end
  end
  power_w = power_w or 1800000

  local max_speed_kmh = pick_number(info, max_speed_paths)
    or pick_number(consist, max_speed_paths)
    or 65

  return {
    mass_kg = mass_kg,
    traction_n = traction_n,
    power_w = power_w,
    cruise_kmh = clamp(requested_cruise_kmh or 40, 1, math.max(max_speed_kmh, 1)),
  }
end

local function conservative_stop_brake_mps2(brake_mps2)
  return math.max(0.2, math.min(brake_mps2, 1.0))
end

local function required_stop_distance_m(speed_mps, stop_buffer_m, brake_mps2)
  if speed_mps <= 0 then
    return stop_buffer_m
  end
  local conservative_brake = conservative_stop_brake_mps2(brake_mps2)
  return stop_buffer_m + (speed_mps * speed_mps) / (2 * conservative_brake)
end

local function must_stop_now(distance_to_target_m, speed_toward_target_mps, stop_buffer_m, brake_mps2)
  local required_stop_m = required_stop_distance_m(speed_toward_target_mps, stop_buffer_m, brake_mps2)
  return speed_toward_target_mps > 0.35 and required_stop_m + 1.5 >= distance_to_target_m
end

local function weight_approach_factor(mass_kg)
  local weight_ratio = clamp(mass_kg / 425000, 0.3, 2.5)
  return clamp(1.15 / math.sqrt(weight_ratio), 0.5, 1.1)
end

local function should_suppress_reverse_recovery(raw_desired_reverser, active_reverser, distance_to_target_m, speed_toward_target_mps, lateral_error_m)
  return raw_desired_reverser ~= active_reverser
    and distance_to_target_m <= 18
    and math.abs(speed_toward_target_mps) > 0.35
    and lateral_error_m <= math.max(6.0, distance_to_target_m * 0.9)
end

local function is_near_target_arrival(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
  return distance_to_target_m <= 3.75
    and longitudinal_distance_m <= 2.5
    and lateral_error_m <= 3.0
    and math.abs(speed_toward_target_mps) <= 0.35
end

local function should_release_near_target_correction(stop_first_active, stopped_after_overshoot, distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
  return stop_first_active
    and stopped_after_overshoot
    and not is_near_target_arrival(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
end

local function approach_stop_brake(speed_toward_target_mps, overspeed)
  if speed_toward_target_mps <= 0.35 then
    return 0
  end
  local brake = clamp(math.max(overspeed, 0.35) / 0.35, 0, 1)
  if brake > 0 and brake < 0.2 then
    brake = 0.2
  end
  return brake
end

local pid = derive_pid(90000, 3000000, 200000, 38.25, 1.23)
assert(math.abs(pid.kp - 0.0942) < 0.002, "unexpected kp")
assert(math.abs(pid.ki - 0.0109) < 0.002, "unexpected ki")
assert(math.abs(pid.kd - 0.4522) < 0.02, "unexpected kd")

local learned = learn_brake(nil, 12.0, 11.59914, 0.5, 0.7)
assert(math.abs(learned - 1.2300) < 0.01, "unexpected learned brake")

local stop_cap_short = stop_speed_cap(25, 3, 1.23, 200)
local stop_cap_long = stop_speed_cap(400, 3, 1.23, 76.464)
assert(math.abs(stop_cap_short - 7.36) < 0.05, "unexpected short stop cap")
assert(math.abs(stop_cap_long - 21.24) < 0.05, "unexpected long stop cap")

local lateral_regression_cap = target_speed_cap(
  math.sqrt(0.68 ^ 2 + 147.5 ^ 2),
  147.5,
  3,
  0.863,
  55
)
assert(math.abs(lateral_regression_cap - (55 / 3.6)) < 0.05, "lateral frame regression collapsed cap")
assert(
  should_capture_axis(
    {x = -0.28, y = 0, z = -147.5},
    {x = 1.32, y = 0, z = 0},
    0.75,
    0.75
  ) == false,
  "sideways startup jitter should not freeze the axis"
)
assert(
  must_stop_now(3.47, 4.31, 3, 0.889) == true,
  "small remaining distance with high residual speed must force braking"
)
assert(
  should_suppress_reverse_recovery(-1, 1, 5.46, 3.77, 4.42) == true,
  "small straight overshoot should brake before flipping into a large reverse recovery"
)
assert(
  should_suppress_reverse_recovery(-1, 1, 9.04, 4.14, 7.71) == true,
  "near-target overshoot should still suppress reverse recovery when lateral error tracks with distance"
)
assert(
  should_suppress_reverse_recovery(-1, 1, 12.23, -0.29, 10.59) == false,
  "after the overshoot has already been braked to a crawl, reverse recovery should wait for explicit stop-first state instead of re-triggering from raw geometry"
)
assert(math.abs(approach_stop_brake(7.02, -0.03) - 1.0) < 0.001, "approach stop should keep braking even when overspeed briefly dips below zero")
assert(math.abs(approach_stop_brake(0.8, -0.2) - 1.0) < 0.001, "approach stop minimum brake should not release too early")
assert(weight_approach_factor(200000) > weight_approach_factor(700000), "lighter train should allow a less conservative approach factor")
assert(
  is_near_target_arrival(3.35, 1.98, 2.71, 0.0) == true,
  "a stopped near-target overshoot like log8 should resolve as near-target arrival instead of deadlocking"
)
assert(
  should_release_near_target_correction(true, true, 5.5, 4.2, 2.0, 0.0) == true,
  "after a confirmed stop outside the relaxed arrival window, a tiny correction phase should be allowed"
)
assert(
  should_release_near_target_correction(true, false, 5.5, 4.2, 2.0, 0.0) == false,
  "near-target correction must stay blocked until stop-first has produced a confirmed halt"
)
assert(weight_approach_factor(700000) < weight_approach_factor(425000), "heavier train should force a more conservative approach factor")

local extracted = extract_characteristics(
  {
    horsepower = 2549,
    traction = 194161,
    max_speed = 76.465505226481,
    weight = 80930,
  },
  {
    weight_kg = 100493,
    total_traction_N = 194161,
  },
  55
)
assert(math.abs(extracted.mass_kg - 100493) < 0.001, "expected consist mass")
assert(math.abs(extracted.traction_n - 194161) < 0.001, "expected consist traction")
assert(math.abs(extracted.power_w - 1900789.3) < 1, "expected horsepower conversion")
assert(math.abs(extracted.cruise_kmh - 55) < 0.001, "expected requested cruise")

print(("pid ok: kp=%.4f ki=%.4f kd=%.4f"):format(pid.kp, pid.ki, pid.kd))
print(("brake learning ok: %.3f m/s^2"):format(learned))
print(("stop profile ok: %.2f m/s at 25m, %.2f m/s at 400m"):format(stop_cap_short, stop_cap_long))
print(("lateral frame regression ok: %.2f m/s cap stays above zero"):format(lateral_regression_cap))
print("axis capture regression ok: sideways startup jitter rejected")
print("approach stop regression ok: late braking is forced near the target")
print("overshoot recovery regression ok: small overshoot keeps braking before reverse recovery")
print("terminal brake hold regression ok: approach stop does not release the brake too early")
print(("characteristic extraction ok: mass=%.0f traction=%.0f power=%.0fW"):format(
  extracted.mass_kg,
  extracted.traction_n,
  extracted.power_w
))
