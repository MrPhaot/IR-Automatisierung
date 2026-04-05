You are continuing the current curve-handling debugging thread for the Immersive Railroading OpenComputers project in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Use this handoff as the current working context:

docs/plans/curve-handling-v1.8/PLAN.md

Important constraints:
- You may write only inside /home/mrphaot/Dokumente/lua/minecraft.
- The PrismLauncher instance and the save are inspect-only:
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)
- Do not invent APIs or behavior. If something is unclear, inspect the local code and the real OpenComputers save logs first.
- programs/train_controller.lua stays the single production controller file for V1.
- Comments should explain mainly why.
- Prefer reading real logs directly instead of screenshots.

Read in this order before making changes:
1. AGENTS.md
2. docs/plans/curve-handling-v1.8/PLAN.md
3. docs/runtime.md
4. docs/control-model.md
5. programs/train_controller.lua
6. docs/plans/curve-handling-v1.7/HANDOFF.md
7. docs/plans/curve-handling-v1.7/PROMPT.md
8. Real save logs relevant to this thread, especially path_test19.log, path_test20.log, path_test21.log, path_test22.log, path_test23.log, and path_test26.log

Current confirmed context:
- The global PID baseline is still physics-derived and is not the main problem to redesign first.
- The current remaining issue sits in the terminal control layer.
- test26 shows two linked problems:
  1. in terminal route guidance, buffer_approach can still run with buffer_target_speed_mps above actual speed while throttle and brake are both zero
  2. after stop_guidance_entry, final_brake_hold can transition into terminal failure while deadlock recovery is still waiting for its stall timer
- The v1.7 minimal emergency-throttle fix only covered the narrow just-outside-capture-window case and does not solve the in-window soft-zone buffer_approach stall visible in test26.

Your implementation priorities are fixed:
1. Replace the narrow emergency-throttle hack with a proper terminal buffer progress floor for route-guidance buffer_approach.
2. Keep fast visibly faster than conservative in the terminal approach.
3. Prevent terminal failure from arming while deadlock recovery is still intentionally waiting for its stall timer.
4. Preserve earlier regressions as fixed: do not reintroduce test23, test20, or false success for test19.

Do not:
- redesign route geometry
- redesign waypoint semantics
- redesign CLI behavior
- redesign route_book
- redesign the global PID model
- do a logger redesign

Implement these changes exactly:
1. Add a helper like terminal_buffer_progress_floor(...) that computes a small adaptive throttle floor from:
   - throttle deadband
   - current shortfall to buffer_target_speed_mps
   - profile (fast > conservative)
   - current throttle_limit
2. Apply that floor in terminal route guidance when:
   - leg.mode == "terminal"
   - guidance_mode == "route"
   - buffer_target_speed_mps > 0
   - stop_guidance_block_reason == "outside_capture_window"
   - speed_toward_target_mps is meaningfully below buffer_target_speed_mps
   - no terminal braking is active
3. Remove the v1.7 logic as the primary mechanism:
   - do not rely only on the narrow emergency_threshold branch outside the capture window
4. Retune fast terminal approach slightly:
   - keep fast.terminal_buffer_throttle_limit at 0.05
   - raise fast.terminal_buffer_final_speed_cap_mps from 0.7 to 0.9
   - keep fast.terminal_buffer_capture_distance_m unchanged for now
5. Prevent failure/recovery race in stop guidance:
   - while buffer_settle_block_reason == "waiting_for_deadlock_timer", terminal failure must not arm
   - only after the deadlock timer expires and recovery is still unavailable may failure start
6. Tighten deadlock-candidate timing so it reflects true near-standstill, not ordinary braking

Required verification:
- luac -p programs/train_controller.lua
- lua tests/previews/controller_preview.lua
- Add preview coverage for:
  - adaptive progress floor in active buffer_approach
  - fast progress floor > conservative progress floor under the same shortfall
  - no terminal failure while waiting_for_deadlock_timer
  - regression coverage for the old outside_capture_window stall case
- If possible, inspect a fresh real save log and report:
  - whether buffer_approach still shows throttle=0.00 with positive target shortfall
  - stop_guidance_entry
  - final_brake_hold
  - waiting_for_deadlock_timer
  - terminal_failure_pending
  - terminal_limit_exit

When you are done, summarize:
- how the terminal progress floor works
- how fast and conservative now differ in terminal approach behavior
- how the failure/recovery race was removed
- what you verified locally
- what still remains uncertain in the real save
