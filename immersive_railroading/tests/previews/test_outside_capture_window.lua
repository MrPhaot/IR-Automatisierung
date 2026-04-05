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
  return "tests/previews/test_outside_capture_window.lua"
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
local controller_chunk = loadfile(controller_path)
assert(controller_chunk, ("failed to load train_controller.lua from %s"):format(controller_path))
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
if not use_sg or reason ~= "buffer_window" then
  io.stderr:write("Test failed: expected stop guidance to be ready with reason=buffer_window\n")
  os.exit(1)
end
if math.abs(cap - profile.terminal_buffer_release_speed_mps) > 0.001 then
  io.stderr:write("Test failed: expected capture speed limit to match terminal_buffer_release_speed_mps\n")
  os.exit(1)
end
os.exit(0)
