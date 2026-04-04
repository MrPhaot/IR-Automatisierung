You are continuing the next implementation phase for the Immersive Railroading OpenComputers project in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Your task is to implement the final V1 terminal-stop fix for the shared route runner from the immersive_railroading/docs/plans/curve-handling-v1.1/PLAN.md.

Important constraints:
- You may write only inside /home/mrphaot/Dokumente/lua/minecraft.
- The PrismLauncher instance and the save are inspect-only:
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)
- Do not invent APIs or behavior. If something is unclear, inspect the local code and the real OpenComputers save logs first.
- programs/train_controller.lua stays the single production controller file for V1.
- Comments should explain mainly why.
- Prefer reading the real save logs directly instead of screenshots.
- Do not restart old logger/OpenOS/deployment debugging. This phase is only about the remaining terminal-stop behavior.

Before making changes:
1. Read docs/plans/curve-handling-v1/HANDOFF.md.
2. Read docs/runtime.md.
3. Read docs/control-model.md.
4. Inspect programs/train_controller.lua.
5. Read the real logs path_test16.log and path_test17.log from the OpenComputers save.

Current confirmed state:
- Route/waypoint handling is already in place and is not the main problem anymore.
- route, goto, and goto --via already use the same internal route/leg runner.
- The controller already has:
  - guidance_mode=route|stop
  - terminal_stop_target
  - terminal_brake_snapshot_mps2
  - terminal_buffer_brake_active
  - buffer_settle_active
  - physical_buffer_error
  - terminal_success_consistent
- The logger is already strong enough; only add minimal terminal fields if needed.

Current confirmed problem:
- The remaining issue is only the terminal endgame in the final leg.
- path_test17.log shows two complementary failures:
  - fast with stop_buffer_m=6 overshoots even after terminal_buffer_brake
  - conservative with stop_buffer_m=6 undershoots and still ends as arrived_within_v1_limit at physical_distance=7.83m with physical_buffer_error=1.83m
- This means the terminal endgame is asymmetric:
  - undershoot correction is incomplete
  - tiny safe overshoots do not have a dedicated controlled reverse corridor
  - terminal_success_consistent is too coarse because it does not cleanly separate stop-target correctness from physical buffer correctness

Implementation requirements:
- Do not change CLI, route_book schema, waypoint semantics, or the overall route geometry model.
- Do not add special-case logic only for goto; fix the shared terminal code path.
- Keep pass-through leg logic intact unless a direct terminal-leg entry fix is truly necessary.
- Keep the existing terminal_stop_target concept.
- Keep the existing terminal_buffer_* approach tuning for the pre-stop phase.

Implement these behavior changes:
1. Split terminal success into two explicit checks:
   - terminal_success_stop_ok
   - terminal_success_physical_ok
   Then derive terminal_success_consistent only as the conjunction of both.
2. Do not allow arrived_at_target or arrived_within_v1_limit unless both checks are true.
3. Refactor the terminal endgame after guidance_mode=stop into explicit settle modes:
   - none
   - forward
   - reverse
4. Integrate or subsume final_forward_crawl into forward settle so there is only one forward endgame correction path.
5. For conservative:
   - if the train is still short of the stop target, slow, aligned, and still outside the physical buffer success corridor, activate a small forward settle instead of declaring success.
   - conservative must not use reverse settle.
6. For fast:
   - if the train has only slightly overshot the stop target, is laterally well aligned, and is moving very slowly, allow a very small reverse settle corridor.
   - if the overshoot is larger or laterally unsafe, keep the existing safe overshoot/failure behavior.
7. Only lightly tighten can_enter_stop_guidance(...):
   - keep it snapshot-based and speed-aware
   - do not redesign capture geometry
   - only prevent entering stop guidance with clearly implausible terminal energy
8. Add explicit per-profile endgame parameters:
   - terminal_success_buffer_tolerance_m
   - buffer_settle_forward_speed_mps
   - buffer_settle_forward_throttle_limit
   - buffer_settle_forward_max_longitudinal_m
   - buffer_settle_reverse_speed_mps
   - buffer_settle_reverse_throttle_limit
   - buffer_settle_reverse_max_overshoot_m
   - buffer_settle_max_lateral_m
9. Add only minimal new log fields:
   - buffer_settle_mode
   - buffer_settle_eligible
   - buffer_settle_block_reason
   - terminal_success_stop_ok
   - terminal_success_physical_ok

Decision order in the terminal leg after guidance_mode=stop:
1. Check stop-target success and physical-buffer success.
2. If not successful, evaluate forward settle.
3. If still not successful, evaluate reverse settle.
4. If no settle mode is allowed, fall back to the existing safe failure/recovery logic.
5. Existing safety paths like near_target_correction and stop_first must remain higher priority than small settle corrections.

Acceptance criteria:
- path_test17 conservative-style undershoot must no longer be accepted as success without correction.
- path_test17 fast-style small overshoot must be correctable in a tight safe corridor, without oscillation.
- The good fast behavior seen in path_test16 must remain working or improve.
- Equal route + equal stop_buffer_m should produce a tighter final stopping range across different starting points.
- No new oscillation on the final curve.
- No new reverser_mismatch regression.
- goto and goto --via should inherit the fix automatically via the shared code path.

Required verification:
- luac -p programs/train_controller.lua
- lua tests/previews/controller_preview.lua
- Add preview coverage for:
  - conservative undershoot not yet counting as success
  - fast tiny overshoot entering reverse settle
  - success only when terminal_success_stop_ok and terminal_success_physical_ok are both true

When you are done, summarize:
- what changed in the terminal decision model
- how forward and reverse settle are bounded
- what log fields were added
- what you verified
- any remaining risks