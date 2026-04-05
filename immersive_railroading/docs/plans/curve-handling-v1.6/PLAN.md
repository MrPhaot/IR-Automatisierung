# Curve Handling V1.6: Current-State Handoff for `test23`, Deployment Drift, and Continuation of This Session

## Summary
- This handoff replaces `curve-handling-v1.5` as the current working context.
- It is intended to let another agent continue this exact debugging thread without reconstructing the earlier reasoning from scratch.
- The newest problem is that `path_test23.log` shows the old pre-stop route stall pattern again, but the deployed save controller and the workspace controller are currently different.
- Because of that mismatch, the immediate priority is not another controller redesign. It is to determine whether `test23` is a true regression in the current workspace controller or simply runtime evidence from an outdated deployed save copy.
- `route` remains the primary focus. `goto` and `goto --via` still use the same shared route/leg runner and must inherit the same terminal behavior automatically.

## Sources and Runtime Paths
- Source-of-truth files:
  - `AGENTS.md`
  - `programs/train_controller.lua`
  - `docs/runtime.md`
  - `docs/control-model.md`
  - `docs/plans/curve-handling-v1.5/PLAN.md`
  - `docs/plans/curve-handling-v1.5/PROMPT.md`
- Real save logs are split across two locations and both must always be checked:
  - OpenComputers root directory:
    - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test19.log`
    - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test20.log`
    - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test21.log`
  - Specific machine home tree:
    - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/path_test22.log`
    - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/path_test23.log`
    - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/train_controller.lua`
- Important working rule for follow-up sessions:
  - never assume a log is missing until both the OpenComputers root and the specific machine home tree have been checked

## Current Verified Context
- The single V1 production controller remains `programs/train_controller.lua`.
- The current workspace controller still contains the newer terminal/deadlock model, including:
  - `guidance_mode=route|stop`
  - `terminal_stop_target`
  - `terminal_brake_snapshot_mps2`
  - `terminal_buffer_brake_active`
  - `buffer_settle_mode`
  - `terminal_success_stop_ok`
  - `terminal_success_physical_ok`
  - `terminal_deadlock_candidate_elapsed_s`
  - `terminal_deadlock_recovery_active`
- The workspace controller is currently syntactically valid:
  - `luac -p programs/train_controller.lua`
- The previously established good buffered-stop reference from this debugging thread remains important:
  - `arrived_at_target`
  - `stop_buffer_m=6`
  - `physical_distance=5.24m`
  - `physical_buffer_error=0.76m`
  - `terminal_success_stop_ok=true`
  - `terminal_success_physical_ok=true`
- Newest hard fact that supersedes the old `v1.5` assumption:
  - the workspace controller and the deployed save controller are currently different

## Thread History and Diagnosis
- `path_test19.log` remains the "bad physical halt is rejected" reference:
  - `physical_distance=3.63m`
  - `physical_buffer_error=2.37m`
  - `terminal_success_stop_ok=true`
  - `terminal_success_physical_ok=false`
  - not falsely accepted
- `path_test20.log` showed the original target-ahead terminal deadlock:
  - `stop_guidance_entry_physical_distance=9.99m`
  - `stop_guidance_entry_stop_longitudinal=3.94m`
  - repeated `final_brake_hold`
  - `buffer_settle_mode=none`
  - `buffer_settle_block_reason=target_ahead`
  - no `terminal_limit_exit`
- `path_test21.log` showed the route-guidance stall before `stop_guidance`:
  - repeated `guidance_mode=route`
  - repeated `reason=overspeed`
  - `throttle=0.00`
  - `brake=0.00`
  - no forward progress
- `path_test22.log` showed an intermediate partial improvement:
  - the route stall from `test21` was improved
  - the terminal deadlock from `test20` was partially improved
  - but `deadlock_forward_recovery` became too broad
  - and it corrected too slowly for `fast`, effectively at conservative-like speed
- `path_test23.log` is the newest evidence and now shows the old pre-stop route stall pattern again:
  - repeated:
    - `guidance_mode=route`
    - `reason=buffer_approach`
    - `stop_guidance_entry=false`
    - `stop_guidance_block_reason=outside_capture_window`
    - `buffer_settle_mode=none`
    - `buffer_settle_block_reason=route_guidance_active`
  - stalled terminal-leg state:
    - `physical_distance=10.24m`
    - `physical_distance_minus_buffer=7.24m`
    - `physical_buffer_error=7.24m`
    - `speed_toward_target=0.00m/s`
    - `axis_speed=0.00m/s`
    - `throttle=0.00`
    - `brake=0.00`
- Mandatory conclusion:
  - `test23` currently looks like the old pre-stop route-guidance stall family
  - but it is not yet valid proof against the current workspace controller
  - because the deployed save controller differs from the workspace controller, and the runtime may have executed an older save copy

## Required Direction for the Next Agent
- Priority order is fixed:
  1. verify the exact mismatch between workspace and deployed save controller
  2. determine whether `path_test23.log` is explainable by outdated deployed code
  3. restore runtime parity or otherwise prove which controller copy produced the log
  4. only then assess whether a new logic fix is needed
- Do not:
  - redesign route geometry
  - redesign waypoint semantics
  - redesign CLI behavior
  - redesign `route_book`
  - redesign logging
  - jump straight back into deadlock-forward retuning before deployment parity is settled
- If parity is restored and `test23` still reproduces, the next logic focus is very narrow:
  - terminal leg
  - still in `guidance_mode=route`
  - `reason=buffer_approach`
  - `stop_guidance` blocked by `outside_capture_window`
  - zero throttle and zero brake
  - no forward progress before `stop_guidance`

## Evidence and Verification Plan
- First, perform these non-mutating checks:
  - compare workspace `programs/train_controller.lua` with deployed save `train_controller.lua`
  - inspect both OpenComputers log locations
  - inspect the relevant terminal-leg routing/capture logic in `programs/train_controller.lua`
- Keep these local verification steps in the workflow:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua` if it still runs clean in the workspace
- Runtime interpretation rule:
  - before using any new in-game log as evidence, re-check whether the workspace controller and save controller were identical at run time
- Acceptance criteria for the eventual follow-up implementation phase:
  - no more `test23`-style terminal-leg stall with:
    - `guidance_mode=route`
    - `reason=buffer_approach`
    - `stop_guidance_entry=false`
    - `throttle=0.00`
    - `brake=0.00`
    - no forward progress
  - `path_test19` must still not be falsely accepted
  - `path_test20` must still not regress to endless `final_brake_hold`
  - `path_test22` concern remains relevant:
    - `fast` deadlock-forward correction must not collapse to conservative-level behavior

## Assumptions
- This is a handoff-creation phase, not an implementation phase.
- The next agent should be able to continue this session directly without re-synthesizing the `test19` to `test23` progression.
- The most important new context is the contradiction between:
  - the old `v1.5` assumption that save/workspace were identical
  - the current verified fact that they are different during the `test23` investigation
