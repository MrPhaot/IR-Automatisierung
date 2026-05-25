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
  return "tests/previews/test_late_buffer_terminal_stop.lua"
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
local controller_chunk = assert(loadfile(controller_path))
local controller = controller_chunk("__module__")

local profile = controller.PROFILES.conservative
local stop_context = {
  in_no_reverse_approach = true,
  must_stop_now = false,
}

local function base_state(extra)
  local state = {
    stop_first_active = false,
    stopped_after_overshoot = false,
    near_target_correction_active = false,
    moving_away_confidence = 0,
    late_stop_capture = true,
    buffer_settle_mode = "none",
  }
  for key, value in pairs(extra or {}) do
    state[key] = value
  end
  return state
end

local mode, reason = controller.terminal_stop_first_force_mode(
  base_state({
    stop_first_active = true,
    stopped_after_overshoot = false,
  }),
  -5.26,
  -5.26
)
assert(mode == "full_brake", "logged late stop-first state must force full brake")
assert(reason == "stop_first_brake", "logged late stop-first state must not stay in auto")

mode, reason = controller.terminal_stop_first_force_mode(
  base_state({
    stop_first_active = true,
    stopped_after_overshoot = false,
  }),
  0.05,
  0.05
)
assert(mode == "hold", "stopped stop-first state must hold before buffer correction")
assert(reason == "stop_first_settle", "stopped stop-first state should settle")

local reverse_block = controller.reverse_buffer_settle_block_reason(
  profile,
  base_state({stopped_after_overshoot = true}),
  -1,
  -8.70,
  0.5,
  0.05,
  0.05,
  stop_context
)
assert(reverse_block == nil, "conservative late overshoot should allow reverse buffer settle")

local reverse_limit = controller.terminal_buffer_settle_drive_limit(profile, "reverse", "eligible")
assert(reverse_limit == profile.buffer_settle_reverse_throttle_limit, "reverse settle throttle must be hard-limited")

reverse_block = controller.reverse_buffer_settle_block_reason(
  profile,
  base_state({stopped_after_overshoot = true}),
  -1,
  -12.0,
  0.5,
  0.05,
  0.05,
  stop_context
)
assert(reverse_block == "beyond_reverse_window", "large late overshoot must stay outside reverse settle")

local late_arrival = controller.is_late_buffer_station_arrival(
  profile,
  base_state({stopped_after_overshoot = true}),
  stop_context,
  8.70,
  8.70,
  0.5,
  2.85,
  0.5,
  6.0,
  0.05,
  0.05
)
assert(late_arrival == false, "raw late capture must not arrive before physical buffer is restored")

late_arrival = controller.is_late_buffer_station_arrival(
  profile,
  base_state({stopped_after_overshoot = true}),
  stop_context,
  0.5,
  0.5,
  0.5,
  6.4,
  0.5,
  6.0,
  0.05,
  0.05
)
assert(late_arrival == true, "late capture should arrive after stop target and physical buffer agree")

local forward_block = controller.forward_buffer_settle_block_reason(
  profile,
  base_state({stopped_after_overshoot = true}),
  4.0,
  0.5,
  0.05,
  0.05,
  stop_context
)
assert(forward_block == nil, "late undershoot should allow forward buffer settle")

print("test_late_buffer_terminal_stop ok")
