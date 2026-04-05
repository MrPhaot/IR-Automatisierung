-- Simple harness to inspect buffer approach values and emergency throttle activation
local controller_chunk = loadfile("immersive_railroading/programs/train_controller.lua")
assert(controller_chunk, "failed to load train_controller.lua")
local controller = controller_chunk("__module__")
local PROFILES = controller.PROFILES
local DEFAULTS = controller.DEFAULTS
local buffer_approach_target_speed = controller.buffer_approach_target_speed
local buffer_pre_capture_target_speed = controller.buffer_pre_capture_target_speed

local profile = PROFILES["fast"]
local physical_distance = 10.24
local terminal_buffer_reserve = 3.0
local physical_distance_minus_buffer = physical_distance - terminal_buffer_reserve

local buffer_target_speed = buffer_approach_target_speed(profile, physical_distance_minus_buffer) or 0
local pre_capture = buffer_pre_capture_target_speed(profile, physical_distance_minus_buffer, profile.terminal_buffer_release_speed_mps or 0, profile.terminal_buffer_capture_distance_m) or 0
local capture_base = profile.terminal_buffer_capture_distance_m or DEFAULTS.terminal_stop_capture_distance_m
local emergency_threshold = 1.5 * capture_base

print(string.format("physical_distance = %.2f", physical_distance))
print(string.format("physical_distance_minus_buffer = %.2f", physical_distance_minus_buffer))
print(string.format("buffer_target_speed = %.3f m/s", buffer_target_speed))
print(string.format("pre_capture_target_speed = %.3f m/s", pre_capture))
print(string.format("capture_base = %.2f, emergency_threshold = %.2f", capture_base, emergency_threshold))

if buffer_target_speed > 0 then
  print("buffer_target_speed active; throttle cap:", profile.terminal_buffer_throttle_limit)
elseif physical_distance_minus_buffer > capture_base and physical_distance_minus_buffer <= emergency_threshold then
  print("emergency_buffer_throttle_active; throttle cap:", profile.terminal_buffer_throttle_limit or DEFAULTS.approach_stop_throttle_limit)
else
  print("no buffer throttle active")
end

os.exit(0)
