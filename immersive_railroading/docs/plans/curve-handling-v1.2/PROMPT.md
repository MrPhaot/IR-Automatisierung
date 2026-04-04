You are continuing the next implementation phase for the Immersive Railroading OpenComputers project in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Your task is to continue the remaining terminal-determinism work for the shared route runner using the current-state handoff in:

docs/plans/curve-handling-v1.2/PLAN.md

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
2. Read docs/plans/curve-handling-v1.2/PLAN.md.
3. Read docs/runtime.md.
4. Read docs/control-model.md.
5. Inspect programs/train_controller.lua.
6. Read the real logs path_test18.log and path_test19.log from the OpenComputers save.

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

Current confirmed problem:
- path_test18.log is the good current reference:
  - fast
  - stop_buffer_m=6
  - arrived_at_target
  - physical_distance=5.24m
  - physical_buffer_error=0.76m
- path_test19.log shows the remaining issue:
  - the train starts farther from the target
  - stop_guidance_entry happens at physical_distance=5.78m
  - later the run reaches physical_distance=3.63m
  - physical_buffer_error=2.37m
  - terminal_success_stop_ok=true
  - terminal_success_physical_ok=false
  - the controller does not falsely accept the run; the user aborts it
- This means the remaining issue is not generic curve handling and not simple false-success acceptance.
- The remaining issue is start-position-dependent residual dynamics in the terminal leg, especially around late stop capture and convergence to the buffered physical halt.

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
- Improve reproducibility of the final buffered halt for the same route and stop_buffer_m, even when the train starts farther away and carries more residual energy into the final leg.

What to optimize:
- entry timing into stop_guidance
- buffer-aware deceleration before stop_guidance
- deterministic convergence inside the final terminal corridor

What not to optimize first:
- new route architectures
- new waypoint systems
- old OpenOS parsing issues
- logger infrastructure

Required verification:
- luac -p programs/train_controller.lua
- lua tests/previews/controller_preview.lua
- If possible, inspect a new real save log and evaluate:
  - physical_distance
  - physical_buffer_error
  - terminal_success_stop_ok
  - terminal_success_physical_ok
  - stop_guidance_entry

Important runtime hygiene:
- Before interpreting any in-game result, verify whether the workspace controller and deployed save controller are identical.
- Do not draw conclusions from screenshots when the real log says something more precise.

When you are done, summarize:
- what changed in the terminal endgame
- how the new behavior improves determinism across different starting positions
- what you verified locally
- what still remains uncertain in the real save
