local controller_chunk = loadfile("immersive_railroading/programs/train_controller.lua")
assert(controller_chunk, "failed to load train_controller.lua")
local controller = controller_chunk("__module__")
local can_enter_stop_guidance = controller.can_enter_stop_guidance
local PROFILES = controller.PROFILES

local profile = PROFILES["fast"]

local use_sg, reason, cap = can_enter_stop_guidance(
  10.24,  -- distance_to_physical_target_m
  7.24,   -- physical_distance_minus_buffer_m (STALL DISTANCE)
  0.5,    -- physical_lateral_error_m
  0.85,   -- route_alignment
  profile.terminal_buffer_capture_distance_m, -- capture_distance_m (fast)
  0.0,    -- speed_toward_target_mps (stalled)
  0.94,   -- brake_snapshot_mps2
  profile
)

print("can_enter_stop_guidance ->", tostring(use_sg), tostring(reason), tostring(cap))
if use_sg then
  io.stderr:write("Test failed: expected stop guidance to be blocked (outside_capture_window)\n")
  os.exit(1)
end
os.exit(0)
