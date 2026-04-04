local function clamp(value, low, high)
  if value < low then
    return low
  end
  if value > high then
    return high
  end
  return value
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
  return "tests/previews/controller_preview.lua"
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

local preview_directory = split_path(script_source_path())
local controller_path = join_paths(preview_directory, "../../programs/train_controller.lua")
local controller_chunk, controller_error = loadfile(controller_path)
assert(controller_chunk, controller_error)

local controller = controller_chunk("__module__")
local DEFAULTS = controller.DEFAULTS
local PROFILES = controller.PROFILES
local INFO_PATHS = controller.INFO_PATHS
local HORSEPOWER_PATHS = controller.HORSEPOWER_PATHS
local HORSEPOWER_TO_W = controller.HORSEPOWER_TO_W
local parse_cli = controller.parse_cli
local build_goto_route_plan = controller.build_goto_route_plan
local build_named_route_plan = controller.build_named_route_plan

local function get_profile(name)
  local profile = PROFILES[name or DEFAULTS.profile]
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
  local effective_brake_mps2 = math.max(brake_mps2, DEFAULTS.min_brake_mps2)
  effective_brake_mps2 = effective_brake_mps2 * profile.stop_cap_brake_scale
  effective_brake_mps2 = math.max(effective_brake_mps2, DEFAULTS.min_brake_mps2)
  return stop_speed_cap(remaining_m, stop_buffer_m, effective_brake_mps2, cruise_kmh)
end

local function target_speed_cap(distance_to_target_m, lateral_error_m, stop_buffer_m, brake_mps2, cruise_kmh)
  local cruise_mps = cruise_kmh / 3.6
  local cap = stop_speed_cap(distance_to_target_m, stop_buffer_m, brake_mps2, cruise_kmh)
  local terminal_stop_zone_m = math.max(stop_buffer_m, DEFAULTS.arrival_distance_m + DEFAULTS.terminal_stop_margin_m)
  if distance_to_target_m <= terminal_stop_zone_m and lateral_error_m <= DEFAULTS.arrival_lateral_m then
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
  local mass_kg = pick_number(consist, INFO_PATHS.mass_kg)
    or pick_number(info, INFO_PATHS.mass_kg)
    or DEFAULTS.fallback_mass_kg

  local traction_n = pick_number(consist, INFO_PATHS.traction_n)
    or pick_number(info, INFO_PATHS.traction_n)
    or DEFAULTS.fallback_traction_n
  if traction_n and traction_n < 5000 then
    traction_n = traction_n * 1000
  end

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

  local max_speed_kmh = pick_number(info, INFO_PATHS.max_speed_kmh)
    or pick_number(consist, INFO_PATHS.max_speed_kmh)
    or DEFAULTS.fallback_max_speed_kmh

  return {
    mass_kg = mass_kg,
    traction_n = traction_n,
    power_w = power_w,
    cruise_kmh = clamp(requested_cruise_kmh or DEFAULTS.cruise_kmh, 1, math.max(max_speed_kmh, 1)),
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

local function must_stop_now_fn(distance_to_target_m, speed_toward_target_mps, stop_buffer_m, brake_mps2)
  local required_stop_m = required_stop_distance_m(speed_toward_target_mps, stop_buffer_m, brake_mps2)
  return speed_toward_target_mps > DEFAULTS.arrival_speed_mps
    and required_stop_m + DEFAULTS.approach_stop_margin_m >= distance_to_target_m
end

local function must_stop_now_for_profile(distance_to_target_m, speed_toward_target_mps, stop_buffer_m, brake_mps2, profile_name)
  local profile = get_profile(profile_name)
  local required_stop_m = required_stop_distance_m(speed_toward_target_mps, stop_buffer_m, brake_mps2)
  return speed_toward_target_mps > DEFAULTS.arrival_speed_mps
    and required_stop_m + profile.required_stop_margin_m >= distance_to_target_m
end

local function parse_cli_profile(argv)
  local profile_name = DEFAULTS.profile
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
    and distance_to_target_m <= DEFAULTS.overshoot_recovery_distance_m
    and math.abs(speed_toward_target_mps) > DEFAULTS.arrival_speed_mps
    and lateral_error_m <= math.max(DEFAULTS.arrival_lateral_m * 4, distance_to_target_m * 0.9)
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

local function should_release_near_target_correction(stop_first_active, stopped_after_overshoot, distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
  return stop_first_active
    and stopped_after_overshoot
    and is_near_target_correction_candidate(distance_to_target_m, longitudinal_distance_m, lateral_error_m)
    and not is_near_target_arrival(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps)
end

local function should_use_final_forward_crawl(profile_name, longitudinal_error_m, speed_toward_target_mps, in_no_reverse_approach, stop_now_flag)
  local profile = get_profile(profile_name)
  return profile.name == "conservative"
    and in_no_reverse_approach
    and not stop_now_flag
    and longitudinal_error_m > DEFAULTS.arrival_longitudinal_m
    and math.abs(speed_toward_target_mps) <= profile.forward_crawl_release_speed_mps
end

local function is_off_target_line_failure(distance_to_target_m, longitudinal_distance_m, lateral_error_m, speed_toward_target_mps, axis_speed_mps, in_no_reverse_approach)
  return in_no_reverse_approach
    and math.abs(speed_toward_target_mps) <= DEFAULTS.arrival_speed_mps
    and math.abs(axis_speed_mps) <= DEFAULTS.arrival_speed_mps
    and distance_to_target_m > DEFAULTS.near_target_arrival_distance_m
    and lateral_error_m > DEFAULTS.near_target_arrival_lateral_m
    and longitudinal_distance_m > DEFAULTS.near_target_arrival_longitudinal_m
end

local function should_force_moving_away_brake(state, speed_toward_target_mps)
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

local function is_interrupt_reason(reason)
  reason = tostring(reason or ""):lower()
  return reason:match("interrupted") ~= nil or reason:match("terminated") ~= nil or reason == "terminate"
end

local function normalize_runtime_error(reason)
  if type(reason) == "table" then
    return reason.reason or reason.code or tostring(reason)
  end
  return tostring(reason)
end

local function uptime()
  return 100
end

local function select_motion_mode(state, speed_toward_target_mps, target_speed_mps, distance_to_target_m, stop_context)
  local profile = get_profile(state.profile_name)
  local overspeed = speed_toward_target_mps - target_speed_mps
  local must_hold_brake = state.brake_release_until and uptime() < state.brake_release_until
  local stop_now_flag = stop_context and stop_context.must_stop_now

  if state.final_forward_crawl and not stop_now_flag then
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
  if stop_now_flag then
    return "brake"
  end
  if stop_context and stop_context.in_no_reverse_approach and not state.near_target_correction_active then
    return "brake"
  end
  if distance_to_target_m <= DEFAULTS.arrival_distance_m * 4 and not state.near_target_correction_active then
    return "brake"
  end
  if should_force_moving_away_brake(state, speed_toward_target_mps) then
    return "brake"
  end
  if overspeed >= DEFAULTS.enter_brake_margin_mps then
    return "brake"
  end
  if state.mode == "brake"
    and not state.near_target_correction_active
    and overspeed >= -profile.brake_exit_margin_mps then
    return "brake"
  end
  if target_speed_mps <= DEFAULTS.arrival_speed_mps * 2 then
    return "coast"
  end
  return "drive"
end

local function approach_stop_brake(speed_toward_target_mps, overspeed)
  if speed_toward_target_mps <= DEFAULTS.arrival_speed_mps then
    return 0
  end
  local brake = clamp(math.max(overspeed, DEFAULTS.arrival_speed_mps) / DEFAULTS.arrival_speed_mps, 0, 1)
  if brake > 0 and brake < DEFAULTS.approach_stop_min_brake then
    brake = DEFAULTS.approach_stop_min_brake
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
assert(PROFILES.conservative.terminal_recovery_min_throttle > PROFILES.conservative.forward_crawl_throttle_limit, "conservative terminal recovery should keep a real minimum traction floor")
assert(PROFILES.conservative.terminal_recovery_max_longitudinal_m > PROFILES.fast.terminal_recovery_max_longitudinal_m, "conservative terminal recovery should tolerate a longer residual miss window")
assert(parse_cli_profile({"goto", "1", "2", "3"}) == "conservative", "missing profile flag should default to conservative")
assert(parse_cli_profile({"goto", "1", "2", "3", "--profile=fast"}) == "fast", "inline profile flag should parse")
assert(parse_cli_profile({"goto", "1", "2", "3", "--profile", "conservative"}) == "conservative", "split profile flag should parse")
assert(pcall(parse_cli_profile, {"goto", "1", "2", "3", "--profile"}) == false, "bare split profile flag should fail")
assert(pcall(parse_cli_profile, {"goto", "1", "2", "3", "--profile", "--log"}) == false, "split profile flag must reject another flag as its value")
assert(pcall(parse_cli_profile, {"goto", "1", "2", "3", "--profile="}) == false, "empty inline profile flag should fail")
assert(pcall(parse_cli, {"goto", "1", "2", "3", "--via", "4", "5"}) == false, "truncated --via triplet should fail")

do
  local cli = parse_cli({"goto", "10", "64", "-20", "45", "2", "--via", "1", "2", "3", "--via", "4", "5", "6", "--profile=fast"})
  assert(#cli.via_points == 2, "goto CLI should retain repeated --via triplets")
  local route_plan = build_goto_route_plan(cli.argv, cli)
  assert(route_plan.name == "inline", "goto route plan should use the inline route name")
  assert(route_plan.profile_name == "fast", "goto route plan should honor the CLI profile")
  assert(#route_plan.legs == 3, "goto route plan should turn vias plus final target into legs")
  assert(route_plan.legs[1].mode == "pass_through", "intermediate goto waypoints should be pass-through legs")
  assert(route_plan.legs[3].mode == "terminal", "final goto waypoint should stay terminal")
  assert(route_plan.legs[3].route_axis ~= nil, "goto terminal leg should retain the last route axis")
  assert(dot(route_plan.legs[3].route_axis, normalize({x = 6, y = 59, z = -26})) > 0.999, "goto terminal route axis should follow the last segment")
  assert(math.abs(route_plan.legs[3].stop_target.x - 9.81) < 0.05, "goto terminal stop target should honor stop_buffer along the last leg axis")
end

do
  local route_book = {
    STATIONS = {
      depot = {x = 0, y = 64, z = 0},
      yard_exit = {x = 120, y = 64, z = -35},
    },
    ROUTES = {
      depot_to_yard = {
        waypoints = {"depot", {x = 85, y = 64, z = -18}, "yard_exit"},
        cruise_kmh = 40,
        stop_buffer_m = 2,
        profile = "conservative",
      },
      broken = {
        waypoints = {"missing_station"},
      },
    },
  }
  local named_route = build_named_route_plan("depot_to_yard", {profile_name = "conservative", profile_explicit = false}, route_book)
  assert(#named_route.legs == 3, "named routes should resolve mixed station ids and raw waypoint tables")
  assert(named_route.legs[2].target.x == 85, "raw waypoint tables should stay usable in named routes")
  assert(named_route.legs[3].route_axis ~= nil, "named routes should retain the terminal route axis")
  assert(dot(named_route.legs[3].route_axis, normalize({x = 35, y = 0, z = -17})) > 0.999, "named route axis should follow the final segment")
  assert(math.abs(named_route.legs[3].stop_target.x - 118.16) < 0.05, "named routes should derive a terminal stop target from the last leg axis")
  local overridden_route = build_named_route_plan("depot_to_yard", {profile_name = "fast", profile_explicit = true}, route_book)
  assert(overridden_route.profile_name == "fast", "CLI profile should override the route-book profile")
  assert(pcall(build_named_route_plan, "missing", {profile_name = "conservative", profile_explicit = false}, route_book) == false, "unknown route ids should fail clearly")
  assert(pcall(build_named_route_plan, "broken", {profile_name = "conservative", profile_explicit = false}, route_book) == false, "unknown station ids should fail clearly")
end

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
  must_stop_now_fn(3.47, 4.31, 3, 0.889) == true,
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
  select_motion_mode({mode = "brake", near_target_correction_active = false, profile_name = "conservative", brake_release_until = 120}, 0.02, 0.4, 20.0, {must_stop_now = false, in_no_reverse_approach = false}) == "brake",
  "brake-release hold should keep the preview in brake mode until the timer expires"
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
assert(is_interrupt_reason(normalize_runtime_error({code = "terminated"})) == true, "preview normalization should also recognize code-style interrupt objects")
assert(PROFILES.conservative.stop_cap_brake_scale ~= nil, "imported conservative profile should include stop cap scaling")
assert(PROFILES.fast.stop_cap_brake_scale ~= nil, "imported fast profile should include stop cap scaling")
assert(PROFILES.fast.brake_exit_margin_mps ~= nil, "imported fast profile should include brake exit margin")
assert(PROFILES.conservative.end_phase_integral_decay ~= nil, "imported conservative profile should include integral decay")

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

local consist_first_power = extract_characteristics(
  {
    power_w = 800000,
    horsepower = 1000,
  },
  {
    power_w = 2200000,
    horsepower = 3000,
  },
  40
)
assert(math.abs(consist_first_power.power_w - 2200000) < 0.001, "consist power should win over locomotive info power")

local normalized_traction = extract_characteristics(
  {
    traction = 250,
  },
  nil,
  40
)
assert(math.abs(normalized_traction.traction_n - 250000) < 0.001, "small traction inputs should be normalized from kN-style values")

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
print("canonical import regression ok: preview uses production defaults, profiles, and lookup paths")
print(("characteristic extraction ok: mass=%.0f traction=%.0f power=%.0fW"):format(
  extracted.mass_kg,
  extracted.traction_n,
  extracted.power_w
))
