You are continuing the next implementation phase for the Immersive Railroading OpenComputers project in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Your task is to fix the current terminal deadlock regression in the shared route runner using the current-state handoff in:

docs/plans/curve-handling-v1.3/PLAN.md

Important constraints:
- You may write only inside /home/mrphaot/Dokumente/lua/minecraft.
- The PrismLauncher instance and the save are inspect-only:
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)
- Do not invent APIs or behavior. If something is unclear, inspect the local code and the real OpenComputers save logs first.
- programs/train_controller.lua stays the single production controller file for V1.
- Comments should explain mainly why.
- Prefer reading the real save logs directly instead of screenshots.

Before making changes:
1. Read AGENTS.md first.
2. Read docs/plans/curve-handling-v1.3/PLAN.md.
3. Read docs/runtime.md.
4. Read docs/control-model.md.
5. Inspect programs/train_controller.lua.
6. Read the real logs path_test19.log and path_test20.log from the OpenComputers save.
7. Use the verified good-reference summary from PLAN.md for the earlier successful buffered stop. If `path_test18.log` is not present in the current save tree, do not assume it can be read directly.

Current confirmed state:
- Route and waypoint handling are already implemented and are no longer the primary problem.
- route, goto, and goto --via already use the same internal route/leg runner.
- The controller already has:
  - guidance_mode=route|stop
  - terminal_stop_target
  - terminal_brake_snapshot_mps2
  - terminal_buffer_brake_active
  - buffer_settle_mode
  - terminal_success_stop_ok
  - terminal_success_physical_ok
- Local static verification for the current workspace state is green:
  - luac -p programs/train_controller.lua
  - lua tests/previews/controller_preview.lua

Current confirmed evidence:
- Good buffered-stop reference from the current project state:
  - arrived_at_target
  - stop_buffer_m=6
  - physical_distance=5.24m
  - physical_buffer_error=0.76m
  - terminal_success_stop_ok=true
  - terminal_success_physical_ok=true
- path_test19.log shows the remaining spread issue:
  - the train starts farther from the target
  - stop_guidance_entry happens at physical_distance=5.78m
  - later the run reaches physical_distance=3.63m
  - physical_buffer_error=2.37m
  - terminal_success_stop_ok=true
  - terminal_success_physical_ok=false
  - the controller does not falsely accept the run; the user aborts it
- path_test20.log shows the current main regression:
  - stop_guidance_entry happens at physical_distance=9.99m
  - stop_guidance_entry_stop_longitudinal=3.94m
  - then the controller repeats reason=final_brake_hold
  - physical_distance stays at 9.97m
  - physical_buffer_error stays at 3.97m
  - buffer_settle_mode=none
  - buffer_settle_block_reason=target_ahead
  - terminal_success_stop_ok=false
  - terminal_success_physical_ok=false
  - there is no arrived_* and no terminal_limit_exit
  - the run ends only with aborted_by_user

This means:
- the primary issue is now a terminal deadlock in the final leg
- the deadlock is more urgent than further buffer-accuracy tuning
- the remaining determinism work only matters after the controller can no longer hang forever in stop guidance

Implementation requirements:
- Do not redesign route geometry, CLI behavior, route_book schema, or waypoint semantics.
- Do not create special-case logic only for goto; fix the shared terminal code path.
- Keep pass-through leg behavior intact unless a change is directly required for the final leg.
- Keep the existing terminal_stop_target concept.
- Keep the current two-part terminal success model:
  - terminal_success_stop_ok
  - terminal_success_physical_ok
- Keep current safety priorities intact:
  - stop_first
  - near_target_correction
  - off-target-line/stall failures
- Do not do a logger redesign.

Primary objective:
- Remove the terminal deadlock shown by path_test20.log.

Required end-state semantics for the deadlock case:
- Acceptable outcomes:
  - controlled forward recovery when the target is still ahead and the train has stalled
  - or explicit terminal_limit_exit if the run is not recoverable
- Unacceptable outcome:
  - endless final_brake_hold with no success and no failure

Secondary objective after deadlock removal:
- Preserve or improve deterministic buffered stopping across different starting positions.

What to optimize first:
- deadlock-free decision-making after guidance_mode=stop
- forward recovery for “target ahead but stalled”
- explicit failure escalation for “not successful, not recoverable, already stopped”

What not to optimize first:
- new route architectures
- new waypoint systems
- old OpenOS parsing issues
- logger infrastructure

Required verification:
- luac -p programs/train_controller.lua
- lua tests/previews/controller_preview.lua
- If possible, inspect a new real save log and evaluate:
  - stop_guidance_entry
  - buffer_settle_mode
  - buffer_settle_block_reason
  - terminal_success_stop_ok
  - terminal_success_physical_ok
  - terminal_limit_exit
  - final_brake_hold

Important runtime hygiene:
- Before interpreting any in-game result, verify whether the workspace controller and deployed save controller are identical.
- Do not draw conclusions from screenshots when the real log says something more precise.

When you are done, summarize:
- what changed in the terminal decision path
- how the deadlock is now resolved
- whether target-ahead stalls recover forward or fail explicitly
- what you verified locally
- what still remains uncertain in the real save
