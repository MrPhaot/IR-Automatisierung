You are continuing the current curve-handling debugging thread for the Immersive Railroading OpenComputers project in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Use this handoff as the current working context:

docs/plans/curve-handling-v1.6/PLAN.md

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
2. docs/plans/curve-handling-v1.6/PLAN.md
3. docs/runtime.md
4. docs/control-model.md
5. programs/train_controller.lua
6. docs/plans/curve-handling-v1.5/PLAN.md
7. docs/plans/curve-handling-v1.5/PROMPT.md
8. Real save logs from both OpenComputers locations:
   - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test19.log
   - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test20.log
   - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test21.log
   - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/path_test22.log
   - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/path_test23.log
9. Deployed save controller:
   - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/train_controller.lua

Current thread context you must preserve:
- path_test19 is still the "bad physical halt is rejected" reference.
- path_test20 is the original target-ahead terminal deadlock.
- path_test21 is the route-guidance overspeed stall.
- path_test22 improved both partially, but deadlock_forward_recovery became too broad and too conservative for fast.
- path_test23 now shows the old pre-stop route stall pattern again:
  - guidance_mode=route
  - reason=buffer_approach
  - stop_guidance_entry=false
  - stop_guidance_block_reason=outside_capture_window
  - throttle=0.00
  - brake=0.00
  - no forward progress
  - physical_distance=10.24m
  - physical_distance_minus_buffer=7.24m
- However, the current workspace controller and deployed save controller are different.
- Therefore, do not treat path_test23 as proof against the current workspace file until deployment parity is resolved.

Your priority order is fixed:
1. Verify and summarize the exact workspace vs save mismatch.
2. Determine whether path_test23 is explainable by outdated deployed code.
3. Only after parity is resolved, decide whether the current workspace controller still reproduces the same stall.
4. Only then propose or implement a logic fix.

Do not:
- redesign route geometry
- redesign waypoint semantics
- redesign CLI behavior
- redesign route_book
- redesign logging

If parity is restored and the same failure still reproduces, focus only on this behavior:
- terminal leg
- guidance_mode=route
- reason=buffer_approach
- stop_guidance blocked by outside_capture_window
- throttle=0.00
- brake=0.00
- no forward progress before stop_guidance

Required verification:
- compare workspace and deployed save copies of programs/train_controller.lua
- luac -p programs/train_controller.lua
- lua tests/previews/controller_preview.lua if it still runs in the current workspace
- if possible, inspect a fresh real save log and report:
  - whether workspace/save were identical at run time
  - guidance_mode
  - reason
  - stop_guidance_entry
  - stop_guidance_block_reason
  - throttle
  - brake
  - physical_distance
  - physical_distance_minus_buffer
  - whether the run stalled before stop_guidance

When you are done, summarize:
- whether test23 was caused by deployment drift or by a true current-code regression
- the exact mismatch you found
- whether a logic fix is still needed
- what you verified locally
- what remains uncertain in the real save
