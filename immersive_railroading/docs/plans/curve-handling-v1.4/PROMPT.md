You are continuing the next implementation phase for the Immersive Railroading OpenComputers project in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Your task is to fix the two current route-runner regressions using the current-state handoff in:

docs/plans/curve-handling-v1.4/PLAN.md

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
2. Read docs/plans/curve-handling-v1.4/PLAN.md.
3. Read docs/runtime.md.
4. Read docs/control-model.md.
5. Inspect programs/train_controller.lua.
6. Read the real logs path_test19.log, path_test20.log, and path_test21.log from the OpenComputers save.

Current confirmed state:
- Save and workspace controllers are currently identical.
- Local static verification for the current workspace state is green:
  - luac -p programs/train_controller.lua
  - lua tests/previews/controller_preview.lua
- route, goto, and goto --via already use the same internal route/leg runner.
- The controller already has:
  - guidance_mode=route|stop
  - terminal_stop_target
  - terminal_brake_snapshot_mps2
  - terminal_buffer_brake_active
  - buffer_settle_mode
  - terminal_success_stop_ok
  - terminal_success_physical_ok

Current confirmed evidence:
- Good buffered-stop reference from the current project state:
  - arrived_at_target
  - stop_buffer_m=6
  - physical_distance=5.24m
  - physical_buffer_error=0.76m
  - terminal_success_stop_ok=true
  - terminal_success_physical_ok=true
- path_test19.log remains the “bad physical halt is rejected” reference:
  - physical_distance=3.63m
  - physical_buffer_error=2.37m
  - terminal_success_stop_ok=true
  - terminal_success_physical_ok=false
  - not falsely accepted
- path_test20.log shows terminal deadlock after stop guidance:
  - stop_guidance_entry_physical_distance=9.99m
  - stop_guidance_entry_stop_longitudinal=3.94m
  - repeated final_brake_hold
  - buffer_settle_mode=none
  - buffer_settle_block_reason=target_ahead
  - no terminal_limit_exit
- path_test21.log shows route-guidance stall before stop guidance:
  - stop_guidance_entry=false
  - guidance_mode=route
  - repeated reason=overspeed
  - physical_distance=8.57m
  - throttle=0.00
  - brake=0.00
  - no forward progress

This means:
- the previous v1.3 handoff identified the right deadlock family but did not fully specify the second regression now visible in test21
- this v1.4 handoff is the new current working context

Implementation priorities:
1. Fix the route-guidance stall first.
2. Fix the target-ahead terminal deadlock second.
3. Preserve the shared code path for route, goto, and goto --via.
4. Do not redesign route geometry.

Implementation requirements:
- Do not redesign route geometry, waypoint semantics, CLI behavior, or route_book schema.
- Keep pass-through leg behavior intact unless a direct change is required for the terminal leg.
- Keep the existing terminal_stop_target concept.
- Keep the current two-part terminal success model:
  - terminal_success_stop_ok
  - terminal_success_physical_ok
- Keep current safety priorities intact:
  - stop_first
  - near_target_correction
  - off-target-line and stall failures
- Do not do a logger redesign.

Code-shape requirement:
- Implement the changes exactly as specified in docs/plans/curve-handling-v1.4/PLAN.md.
- Use the provided code fragments as the default implementation shape unless local inspection reveals a direct conflict.
- If you need to adapt names or placement, preserve the semantics exactly.

Required verification:
- luac -p programs/train_controller.lua
- lua tests/previews/controller_preview.lua
- If possible, inspect a new real save log and report:
  - stop_guidance_entry
  - buffer_settle_mode
  - buffer_settle_block_reason
  - terminal_limit_exit
  - final_brake_hold
  - guidance_mode=route
  - reason=overspeed
  - throttle
  - brake

Important runtime hygiene:
- Before interpreting any in-game result, verify whether the workspace controller and deployed save controller are identical.
- Do not draw conclusions from screenshots when the real log says something more precise.

When you are done, summarize:
- the route-stall fix
- the terminal-deadlock fix
- the preview coverage that was added
- the remaining runtime uncertainty
