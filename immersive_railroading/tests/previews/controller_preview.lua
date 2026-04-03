local function clamp(value, low, high)
  if value < low then
    return low
  end
  if value > high then
    return high
  end
  return value
end

local PROFILES = {
  conservative = {
    name = "conservative",
    stop_cap_brake_scale = 0.6,
    required_stop_margin_m = 5.0,
    no_reverse_distance_m = 42.0,
    forward_crawl_speed_mps = 0.6,
    forward_crawl_release_speed_mps = 0.2,
    brake_exit_margin_mps = 0.2,
  },
  fast = {
    name = "fast",
    stop_cap_brake_scale = 1.0,
    required_stop_margin_m = 1.5,
    no_reverse_distance_m = 22.0,
    brake_exit_margin_mps = 0.9,
  },
}

local function get_profile(name)
  local profile = PROFILES[name or "conservative"]
  if not profile then
    error("invalid profile")
  end
  return profile
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

local function profiled_stop_speed_cap(remaining_m, stop_buffer_m, brake_mps2, cruise_kmh, profile_name)
  local profile = get_profile(profile_name)
  local effective_brake_mps2 = math.max(brake_mps2 * profile.stop_cap_brake_scale, 0.2)
  return stop_speed_cap(remaining_m, stop_buffer_m, effective_brake_mps2, cruise_kmh)
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

local function dot(a, b)
  return a.x * b.x + a.y * b.y + a.z * b.z
end

local function blend_axes(base_axis, candidate_axis, candidate_weight)
  local aligned_candidate = candidate_axis
  if dot(base_axis, candidate_axis) < 0 then
    aligned_candidate = {
      x = -candidate_axis.x,
      y = -candidate_axis.y,
      z = -candidate_axis.z,
    }
  end
  return normalize({
    x = base_axis.x * (1 - candidate_weight) + aligned_candidate.x * candidate_weight,
    y = base_axis.y * (1 - candidate_weight) + aligned_candidate.y * candidate_weight,
    z = base_axis.z * (1 - candidate_weight) + aligned_candidate.z * candidate_weight,
  })
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

local function choose_axes(target_axis, filtered_velocity, capture_speed_mps, alignment_min)
  local speed = math.sqrt(
    filtered_velocity.x * filtered_velocity.x +
    filtered_velocity.y * filtered_velocity.y +
    filtered_velocity.z * filtered_velocity.z
  )
  local velocity_axis = speed >= capture_speed_mps and normalize(filtered_velocity) or nil
  local alignment = velocity_axis and abs_dot(target_axis, velocity_axis) or 0
  if velocity_axis and alignment >= alignment_min then
    return blend_axes(target_axis, velocity_axis, 0.25), "blended", alignment
  end
  return target_axis, "target", alignment
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

local function must_stop_now_for_profile(distance_to_target_m, speed_toward_target_mps, stop_buffer_m, brake_mps2, profile_name)
  local profile = get_profile(profile_name)
  local required_stop_m = required_stop_distance_m(speed_toward_target_mps, stop_buffer_m, brake_mps2)
  return speed_toward_target_mps > 0.35 and required_stop_m + profile.required_stop_margin_m >= distance_to_target_m
end

local function parse_cli_profile(argv)
  local profile_name = "conservative"
  local index = 1
  while index <= #argv do
    local value = argv[index]
    if value == "--profile" then
      local next_value = argv[index + 1]
      if next_value and next_value ~= "" and next_value:sub(1, 1) ~= "-" then
        profile_name = next_value
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
      index = index + 1
    else
      index = index + 1
    end
  end
  return get_profile(profile_name).name
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

local function is_near_target_correction_candidate(distance_to_target_m, longitudinal_distance_m, lateral_error_m)
  return distance_to_target_m <= 8.0
    and longitudinal_distance_m <= 5.0
    and lateral_error_m <= 6.0
end

local function should_release_near_target_correction(stop_first_active, stopped_after_overshoot, distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
  return stop_first_active
    and stopped_after_overshoot
    and is_near_target_correction_candidate(distance_to_target_m, longitudinal_distance_m, lateral_error_m)
    and not is_near_target_arrival(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
end

local function should_use_final_forward_crawl(profile_name, longitudinal_error_m, speed_toward_target_mps, in_no_reverse_approach, must_stop_now)
  local profile = get_profile(profile_name)
  return profile.name == "conservative"
    and in_no_reverse_approach
    and not must_stop_now
    and longitudinal_error_m > 1.5
    and math.abs(speed_toward_target_mps) <= profile.forward_crawl_release_speed_mps
end

local function is_off_target_line_failure(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps, axis_speed_mps, in_no_reverse_approach)
  return in_no_reverse_approach
    and math.abs(speed_toward_target_mps) <= 0.35
    and math.abs(axis_speed_mps) <= 0.35
    and distance_to_target_m > 3.75
    and lateral_error_m > 3.0
    and longitudinal_distance_m > 2.5
end

local function should_force_moving_away_brake(state, speed_toward_target_mps)
  if speed_toward_target_mps > -0.15 then
    return false
  end
  if state.startup_guard_active then
    if speed_toward_target_mps <= -2.5 then
      return true
    end
    if state.moving_away_confidence < 0.95 or state.progress_speed_mps > -1.0 then
      return false
    end
  end
  if state.curve_guard_active and state.moving_away_confidence < 0.55 then
    return false
  end
  return true
end

local function is_interrupt_reason(reason)
  reason = tostring(reason or ""):lower()
  return reason:match("interrupted") ~= nil or reason:match("terminated") ~= nil or reason == "terminate"
end

local function normalize_runtime_error(reason)
  if type(reason) == "table" then
    return reason.reason or reason.message or reason[1] or tostring(reason)
  end
  return reason
end

local function select_motion_mode(state, speed_toward_target_mps, target_speed_mps, distance_to_target_m, stop_context)
  local profile = get_profile(state.profile_name)
  local overspeed = speed_toward_target_mps - target_speed_mps
  if state.final_forward_crawl then
    return "drive"
  end
  if state.near_target_correction_active then
    if math.abs(speed_toward_target_mps) <= 0.4 then
      return "drive"
    end
    if should_force_moving_away_brake(state, speed_toward_target_mps) then
      return "brake"
    end
  end
  if stop_context and stop_context.must_stop_now then
    return "brake"
  end
  if stop_context and stop_context.in_no_reverse_approach and not state.near_target_correction_active then
    return "brake"
  end
  if distance_to_target_m <= 1.5 * 4 and not state.near_target_correction_active then
    return "brake"
  end
  if should_force_moving_away_brake(state, speed_toward_target_mps) then
    return "brake"
  end
  if overspeed >= 0.35 then
    return "brake"
  end
  if state.mode == "brake"
    and not state.near_target_correction_active
    and overspeed >= -profile.brake_exit_margin_mps then
    return "brake"
  end
  if target_speed_mps <= 0.35 * 2 then
    return "coast"
  end
  return "drive"
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
local conservative_stop_cap = profiled_stop_speed_cap(25, 3, 1.23, 55, "conservative")
local fast_stop_cap = profiled_stop_speed_cap(25, 3, 1.23, 55, "fast")
assert(math.abs(stop_cap_short - 7.36) < 0.05, "unexpected short stop cap")
assert(math.abs(stop_cap_long - 21.24) < 0.05, "unexpected long stop cap")
assert(conservative_stop_cap < fast_stop_cap, "conservative profile should clamp the end-phase speed harder than fast")
assert(parse_cli_profile({"goto", "1", "2", "3"}) == "conservative", "missing profile flag should default to conservative")
assert(parse_cli_profile({"goto", "1", "2", "3", "--profile=fast"}) == "fast", "inline profile flag should parse")
assert(parse_cli_profile({"goto", "1", "2", "3", "--profile", "conservative"}) == "conservative", "split profile flag should parse")
assert(pcall(parse_cli_profile, {"goto", "1", "2", "3", "--profile"}) == false, "bare split profile flag should fail")
assert(pcall(parse_cli_profile, {"goto", "1", "2", "3", "--profile", "--log"}) == false, "split profile flag must reject another flag as its value")
assert(pcall(parse_cli_profile, {"goto", "1", "2", "3", "--profile="}) == false, "empty inline profile flag should fail")

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
do
  local target_axis = normalize({x = -0.28, y = 0, z = -147.5})
  local motion_axis, axis_source, alignment = choose_axes(
    target_axis,
    {x = 1.32, y = 0, z = 0},
    0.75,
    0.75
  )
  assert(axis_source == "target", "misaligned startup motion should not replace the target line axis")
  assert(abs_dot(motion_axis, target_axis) > 0.999, "target line axis should remain primary under sideways jitter")
  assert(alignment < 0.75, "sideways jitter alignment should stay below the capture threshold")
end
do
  local target_axis = normalize({x = 0, y = 0, z = -100})
  local motion_axis, axis_source, alignment = choose_axes(
    target_axis,
    {x = 0.2, y = 0, z = -8.0},
    0.75,
    0.75
  )
  assert(axis_source == "blended", "well-aligned motion should only blend into the target line, not replace it")
  assert(abs_dot(motion_axis, target_axis) > 0.99, "blended axis should stay close to the target line")
  assert(alignment > 0.99, "aligned motion should report strong target alignment")
end
assert(
  must_stop_now(3.47, 4.31, 3, 0.889) == true,
  "small remaining distance with high residual speed must force braking"
)
assert(
  must_stop_now_for_profile(33.0, 7.27, 3, 1.392, "conservative") == true,
  "conservative profile should force braking earlier on the same approach geometry"
)
assert(
  must_stop_now_for_profile(33.0, 7.27, 3, 1.392, "fast") == false,
  "fast profile should leave more room before forcing the same early braking decision"
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
assert(
  should_release_near_target_correction(true, true, 13.96, 7.21, 11.96, 0.0) == false,
  "a log11-sized residual miss should be treated as a near-target limit, not as a micro-correction candidate"
)
assert(
  select_motion_mode({mode = "brake", near_target_correction_active = true, profile_name = "conservative"}, 0.02, 0.8, 7.24, {must_stop_now = false, in_no_reverse_approach = false}) == "drive",
  "active near-target correction must be able to leave brake mode from a near-stop state"
)
assert(
  select_motion_mode({mode = "brake", near_target_correction_active = false, profile_name = "fast"}, 0.02, 0.8, 3.0, {must_stop_now = false, in_no_reverse_approach = false}) == "brake",
  "without near-target correction the close-range brake bias should remain active"
)
assert(
  select_motion_mode({
    mode = "drive",
    near_target_correction_active = false,
    final_forward_crawl = false,
    profile_name = "conservative",
    startup_guard_active = false,
    curve_guard_active = true,
    moving_away_confidence = 0.2,
    progress_speed_mps = -0.05,
  }, -0.22, 8.0, 205.0, {must_stop_now = false, in_no_reverse_approach = false}) == "drive",
  "curve guard should suppress stop-and-go when target projection briefly goes negative on a bend"
)
assert(
  select_motion_mode({
    mode = "brake",
    near_target_correction_active = false,
    final_forward_crawl = false,
    profile_name = "conservative",
    startup_guard_active = false,
    curve_guard_active = false,
    moving_away_confidence = 0.0,
    progress_speed_mps = 0.0,
  }, 0.0, 0.8, 50.0, {must_stop_now = false, in_no_reverse_approach = false}) == "drive",
  "conservative profile should release brake sooner when overspeed drops below its tighter exit margin"
)
assert(
  select_motion_mode({
    mode = "brake",
    near_target_correction_active = false,
    final_forward_crawl = false,
    profile_name = "fast",
    startup_guard_active = false,
    curve_guard_active = false,
    moving_away_confidence = 0.0,
    progress_speed_mps = 0.0,
  }, 0.0, 0.8, 50.0, {must_stop_now = false, in_no_reverse_approach = false}) == "brake",
  "fast profile should keep braking longer because its exit margin is looser"
)
assert(
  select_motion_mode({
    mode = "drive",
    near_target_correction_active = false,
    final_forward_crawl = false,
    startup_guard_active = false,
    curve_guard_active = false,
    moving_away_confidence = 0.8,
    progress_speed_mps = -2.0,
  }, -0.22, 8.0, 205.0, {must_stop_now = false, in_no_reverse_approach = false}) == "brake",
  "stable negative progress should still trigger moving-away braking"
)
assert(
  select_motion_mode({
    mode = "drive",
    near_target_correction_active = false,
    final_forward_crawl = false,
    startup_guard_active = true,
    curve_guard_active = false,
    moving_away_confidence = 0.8,
    progress_speed_mps = -0.3,
  }, -0.35, 8.0, 135.0, {must_stop_now = false, in_no_reverse_approach = false}) == "drive",
  "startup guard should suppress early stop-and-go on shallow negative samples"
)
assert(
  select_motion_mode({
    mode = "drive",
    near_target_correction_active = false,
    final_forward_crawl = false,
    startup_guard_active = true,
    curve_guard_active = false,
    moving_away_confidence = 0.98,
    progress_speed_mps = -2.5,
  }, -2.8, 8.0, 135.0, {must_stop_now = false, in_no_reverse_approach = false}) == "brake",
  "startup guard must still allow braking when the train is clearly moving away"
)
assert(
  should_use_final_forward_crawl("conservative", 9.74, 0.03, true, false) == true,
  "log14-style conservative under-target state should switch into a slow final forward crawl"
)
assert(
  should_use_final_forward_crawl("fast", 9.74, 0.03, true, false) == false,
  "fast profile should not reuse the conservative final forward crawl path"
)
assert(
  select_motion_mode({mode = "brake", near_target_correction_active = false, final_forward_crawl = true, profile_name = "conservative"}, 0.03, 0.6, 21.08, {must_stop_now = false, in_no_reverse_approach = false}) == "drive",
  "final forward crawl must be able to leave the conservative brake hold deadlock"
)
assert(
  select_motion_mode({
    mode = "drive",
    near_target_correction_active = false,
    final_forward_crawl = false,
    profile_name = "conservative",
    startup_guard_active = false,
    curve_guard_active = false,
    moving_away_confidence = 0.0,
    progress_speed_mps = 0.0,
  }, 0.0, 0.6, 50.0, {must_stop_now = false, in_no_reverse_approach = false}) == "coast",
  "low target speeds should fall through to coast instead of pretending a drive command is required"
)
assert(
  select_motion_mode({
    mode = "drive",
    near_target_correction_active = false,
    final_forward_crawl = false,
    profile_name = "fast",
    startup_guard_active = false,
    curve_guard_active = false,
    moving_away_confidence = 0.0,
    progress_speed_mps = 0.0,
  }, 0.1, 4.0, 20.0, {must_stop_now = false, in_no_reverse_approach = true}) == "brake",
  "preview should honor no-reverse approach braking from the stop context"
)
assert(weight_approach_factor(700000) < weight_approach_factor(425000), "heavier train should force a more conservative approach factor")
assert(
  is_off_target_line_failure(28.73, 25.56, 13.11, 0.0, 0.0, true) == true,
  "abort-test style terminal stop on the wrong line should be classified as off-target-line failure"
)
assert(
  is_off_target_line_failure(2.14, 0.72, 2.02, 0.0, 0.0, true) == false,
  "reverse-test21 style near stop should remain eligible for arrived_within_v1_limit"
)
assert(is_interrupt_reason(normalize_runtime_error("interrupted")) == true, "plain interrupted should be recognized")
assert(is_interrupt_reason(normalize_runtime_error("terminated")) == true, "terminated should be recognized as an abort-like exit")
assert(is_interrupt_reason(normalize_runtime_error({reason = "terminated"})) == true, "preview interrupt checks should use normalized runtime errors")

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
print("target line axis regression ok: target geometry stays primary over early motion samples")
print("approach stop regression ok: late braking is forced near the target")
print("overshoot recovery regression ok: small overshoot keeps braking before reverse recovery")
print("terminal brake hold regression ok: approach stop does not release the brake too early")
print("off-target line regression ok: large residual miss is not treated as a valid terminal arrival")
print("curve guard regression ok: bends do not immediately trigger moving-away braking")
print("startup guard regression ok: early shallow regressions do not trigger stop-and-go")
print("interrupt regression ok: interrupted and terminated reasons are recognized")
print(("characteristic extraction ok: mass=%.0f traction=%.0f power=%.0fW"):format(
  extracted.mass_kg,
  extracted.traction_n,
  extracted.power_w
))
