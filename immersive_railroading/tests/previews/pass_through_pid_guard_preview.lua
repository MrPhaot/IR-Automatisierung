package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local controller = assert(loadfile("./programs/train_controller.lua"))("__module__")

local force_mode, force_reason = controller.moving_away_force_mode("auto", true)
assert(force_mode == "full_brake" and force_reason == "moving_away_from_target", "moving-away auto mode should force full brake")

local effort, suppressed = controller.limit_pass_through_effort("pass_through", "auto", -0.45, 2.0)
assert(effort == 0 and suppressed == true, "pass-through auto brake should be suppressed below target speed")

effort, suppressed = controller.limit_pass_through_effort("pass_through", "full_brake", -0.45, 2.0)
assert(effort == -0.45 and suppressed == false, "force-mode brake must stay allowed")

effort, suppressed = controller.limit_pass_through_effort("terminal", "auto", -0.45, 2.0)
assert(effort == -0.45 and suppressed == false, "terminal brake gate must not use pass-through rule")

local state = {moving_away_confidence = 1.0}
local mode, reason = controller.terminal_stop_first_force_mode(state, -2, -2)
assert(mode == nil and reason == nil, "PLAN24 stop-first helper should stay scoped")

local candidate = controller.choose_forward_guardrail({
  {point = {x = 10, y = 64, z = 0}, id = "front"},
  {point = {x = -5, y = 64, z = 0}, id = "behind"},
}, {x = 0, y = 64, z = 0}, {x = 1, y = 0, z = 0})
assert(candidate.id == "front", "guardrail picker should ignore candidates behind train")

local straight, straight_reason = controller.choose_forward_guardrail({
  {point = {x = 10, y = 64, z = 1}, id = "near"},
  {point = {x = 11, y = 64, z = -1}, id = "far"},
}, {x = 0, y = 64, z = 0}, {x = 1, y = 0, z = 0})
assert(straight.id == "near" and straight_reason == "straight_pair_nearest", "straight double track should choose nearest")

local left, left_reason = controller.choose_forward_guardrail({
  {point = {x = 10, y = 64, z = 5}, id = "near"},
  {point = {x = 11, y = 64, z = 6}, id = "far"},
}, {x = 0, y = 64, z = 0}, {x = 1, y = 0, z = 0})
assert(left.id == "far" and left_reason == "left_curve_farther", "left curve should choose farther point")

local right, right_reason = controller.choose_forward_guardrail({
  {point = {x = 10, y = 64, z = -5}, id = "near"},
  {point = {x = 11, y = 64, z = -6}, id = "far"},
}, {x = 0, y = 64, z = 0}, {x = 1, y = 0, z = 0})
assert(right.id == "near" and right_reason == "right_curve_nearest", "right curve should choose nearest point")

local missing, missing_reason = controller.choose_forward_guardrail({}, {x = 0, y = 64, z = 0}, nil)
assert(missing == nil and missing_reason == "missing_heading", "missing heading should not guess")

local none, none_reason = controller.choose_forward_guardrail({
  {point = {x = -10, y = 64, z = 0}, id = "behind"},
}, {x = 0, y = 64, z = 0}, {x = 1, y = 0, z = 0})
assert(none == nil and none_reason == "no_forward_candidate", "missing forward candidates should not guess")

print("pass_through_pid_guard_preview ok")
