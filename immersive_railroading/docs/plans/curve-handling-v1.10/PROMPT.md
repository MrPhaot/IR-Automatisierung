# Curve Handling V1.10 Prompt

You are continuing the curve-handling debugging thread for the Immersive Railroading OpenComputers project in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Use this handoff as the current working context:

docs/plans/curve-handling-v1.10/PLAN.md

Important constraints:
- You may write only inside /home/mrphaot/Dokumente/lua/minecraft.
- The PrismLauncher instance and save are inspect-only:
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)
- Do not invent APIs or behavior. Inspect real code and real logs first.
- programs/train_controller.lua remains the single production controller file for V1.
- Comments should explain mainly why.
- Prefer reading real logs directly over screenshots.

Read in this order before making changes:
1. AGENTS.md
2. docs/plans/curve-handling-v1.10/PLAN.md
3. docs/runtime.md
4. docs/control-model.md
5. programs/train_controller.lua
6. Real logs:
   - /home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/path_test28.log
   - /home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/path_test29.log

Current verified state:
- test28 (fast) succeeded with stop_guidance_entry and arrived_at_target.
- test29 (conservative) hung without stop_guidance_entry and repeatedly reported stop_guidance_block_reason=insufficient_braking_room before manual abort.
- v1.9 stop-progress channel/logging is already present.

Root cause to preserve:
- The current blocker is stop-guidance entry gating in low-speed near-buffer conditions (test29), not a global PID redesign.

Implementation priorities (fixed):
1) Fix test29 hang in can_enter_stop_guidance(...).
2) Make fast terminal/braking behavior 1:1 with conservative.
3) Keep fast only faster on the way (+15% travel phase).

Implement exactly this:
1. In can_enter_stop_guidance(...), add a low-speed capture override:
   - Applies only when the current result would be insufficient_braking_room.
   - Conditions:
     - forward_speed_mps <= DEFAULTS.arrival_speed_mps
     - physical_distance_minus_buffer_m <= DEFAULTS.arrival_distance_m + DEFAULTS.terminal_stop_margin_m
   - Return true with dedicated reason low_speed_capture_override.
   - Keep existing guards for outside_capture_window, lateral error, and implausible energy.
2. In PROFILES.fast, align all terminal/braking relevant parameters to current conservative values:
   - stop_cap_brake_scale
   - required_stop_margin_m
   - no_reverse_distance_m
   - force_brake_distance_m
   - terminal_recovery_*
   - approach_stop_target_speed_scale
   - approach_stop_throttle_scale
   - terminal_buffer_*
   - terminal_success_buffer_tolerance_m
   - buffer_settle_forward_*
   - buffer_settle_reverse_*
   - buffer_settle_max_lateral_m
   - launch_throttle_scale
   - brake_exit_margin_mps
   - end_phase_integral_decay
3. Add travel-only fast speed-up:
   - Introduce pass_through_throttle_scale (or equivalent):
     - conservative = 1.0
     - fast = 1.15
   - Apply only in pass-through drive behavior (leg.mode == "pass_through").
   - Do not apply this scaling in terminal stop-guidance/brake logic.
4. Keep existing v1.9 failure serialization and stop-progress instrumentation intact.
5. Ensure logs clearly expose stop_guidance_entry_reason=low_speed_capture_override when used.

Do not:
- redesign route geometry
- redesign waypoint semantics
- redesign CLI or route_book
- redesign global PID architecture
- remove terminal_failure_arming_allowed serialization
- solve this via arbitrary global threshold retuning only

Required preview/test work:
- Keep green:
  - luac -p programs/train_controller.lua
  - lua tests/previews/controller_preview.lua
  - lua tests/previews/test_outside_capture_window.lua
- Add/extend preview coverage for:
  - low-speed capture override in can_enter_stop_guidance(...)
  - fast/conservative terminal-parameter parity
  - travel-only fast throttle scaling
- If possible, inspect fresh real logs for test28/test29 patterns.

When done, summarize:
- exact technical fix for test29 hang
- how fast differs from conservative after changes (travel only)
- whether stop_guidance_entry now appears in former test29 scenario
- which checks/previews passed
- what remains uncertain in real-save behavior
