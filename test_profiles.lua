dofile("immersive_railroading/programs/train_controller.lua")

local fast_profile = get_profile("fast")
local conservative_profile = get_profile("conservative")

print("fast.terminal_buffer_release_speed_mps:", fast_profile.terminal_buffer_release_speed_mps)
print("conservative.terminal_buffer_release_speed_mps:", conservative_profile.terminal_buffer_release_speed_mps)
print("fast.terminal_buffer_final_speed_cap_mps:", fast_profile.terminal_buffer_final_speed_cap_mps)
print("conservative.terminal_buffer_final_speed_cap_mps", conservative_profile.terminal_buffer_final_speed_cap_mps)
print("fast.terminal_recovery_max_longitudinal_m:", fast_profile.terminal_recovery_max_longitudinal_m)
print("conservative.terminal_recovery_max_longitudinal_m:", conservative_profile.terminal_recovery_max_longitudinal_m)

local capture_blocked, capture_block_reason, release_limit = can_enter_stop_guidance(7.0, 4.0, 0.6, 0.99, 5.0, 1.6, 0.94, fast_profile)
print("\ncan_enter_stop_guidance result:")
print("  blocked:", capture_blocked)
print("  reason:", capture_block_reason)
print("  release_limit:", release_limit)
print("  match check:", math.abs(release_limit - fast_profile.terminal_buffer_release_speed_mps) < 0.001)
