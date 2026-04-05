You are continuing the next implementation phase for the Immersive Railroading OpenComputers project in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Your task is to refine the current V1.4 fixes using the new current-state handoff in:

docs/plans/curve-handling-v1.5/PLAN.md

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
2. Read docs/plans/curve-handling-v1.5/PLAN.md.
3. Read docs/runtime.md.
4. Read docs/control-model.md.
5. Inspect programs/train_controller.lua.
6. Read the real logs path_test19.log, path_test20.log, path_test21.log, and path_test22.log from the OpenComputers save.

Current confirmed state:
- Save and workspace controllers are currently identical.
- Local static verification for the current workspace state is green:
  - luac -p programs/train_controller.lua
  - lua tests/previews/controller_preview.lua
- The route-stall from test21 is improved in test22.
- The target-ahead deadlock from test20 is also improved in test22.
- However, test22 shows the new deadlock-forward recovery now activates too early and too slowly for fast:
  - stop_guidance_entry at physical_distance=7.32m
  - stop_longitudinal=4.28m
  - then deadlock_forward_recovery becomes active
  - fast correction runs at about 0.15 m/s with tiny throttle
  - that is effectively conservative behavior, not fast

What this means:
- The current deadlock-forward path is too broad.
- It is acting like a normal terminal approach mode instead of a true deadlock fallback.
- The next fix must preserve the route-stall fix, preserve the deadlock escape hatch, but make deadlock-forward:
  - stall-gated
  - profile-aware
  - not the default fast correction path

Implementation requirements:
- Do not redesign route geometry, waypoint semantics, CLI behavior, or route_book schema.
- Keep the shared code path for route, goto, and goto --via.
- Keep the existing terminal_stop_target model.
- Keep current safety priorities intact.
- Do not do a logger redesign.

Implement these changes:
1. Add explicit stall gating for deadlock-forward recovery.
2. Track a deadlock candidate timer in terminal stop guidance.
3. Only allow deadlock-forward recovery after the train has actually stalled short of the target for a short time.
4. Split deadlock-forward speed/throttle by profile so fast is meaningfully faster than conservative during correction.
5. Keep the test21 route-stall fix intact.
6. Do not let deadlock-forward replace normal approach_stop behavior.

Required verification:
- luac -p programs/train_controller.lua
- lua tests/previews/controller_preview.lua
- If possible, inspect a new real save log and report:
  - stop_guidance_entry
  - buffer_settle_mode
  - buffer_settle_block_reason
  - whether deadlock_forward_recovery activates only after a stall
  - whether fast recovery speed is still too conservative
  - terminal_limit_exit
  - final_brake_hold

When you are done, summarize:
- how deadlock-forward is now stall-gated
- how fast and conservative differ in deadlock-forward correction speed
- how you preserved the route-stall fix
- what you verified locally
- what still remains uncertain in the real save
