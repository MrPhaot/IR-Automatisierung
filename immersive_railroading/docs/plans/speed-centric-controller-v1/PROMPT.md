# Speed-Centric Controller V1 Prompt

You are continuing a control-architecture redesign for the Immersive Railroading OpenComputers controller in:

/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading

Your current working context is:

docs/plans/speed-centric-controller-v1/HANDOFF.md

Important constraints:
- You may write only inside /home/mrphaot/Dokumente/lua/minecraft.
- The PrismLauncher instance and save are inspect-only:
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft
  - ~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)
- programs/train_controller.lua remains the single production controller file for this redesign pass.
- Do not invent APIs or runtime behavior. Inspect real code and real logs first.
- Comments should explain why.
- Prefer real logs over screenshots.

Read in this order before making changes:
1. AGENTS.md
2. docs/plans/speed-centric-controller-v1/HANDOFF.md
3. docs/control-model.md
4. docs/runtime.md
5. programs/train_controller.lua
6. tests/previews/controller_preview.lua
7. tests/previews/test_outside_capture_window.lua
8. Real logs:
   - /home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test31.log
   - /home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/path_test32.log
9. If needed for orientation:
   - `git show 61a179c`
   - `git show b3589a4`

Current verified state:
- `luac -p programs/train_controller.lua` is green.
- `lua tests/previews/controller_preview.lua` is currently red because it still asserts old fast-capture behavior.
- `lua tests/previews/test_outside_capture_window.lua` is currently red because current stop-guidance semantics no longer match its old expectation.
- `path_test31.log` shows conservative success with `arrived_at_target`.
- `path_test32.log` shows fast terminal failure with `terminal_limit_exit reason=stalled_outside_v1_limit`.

Redesign goal:
- Convert the controller from throttle-limit-centric behavior to speed-centric behavior.
- Planner/state machine should define speed targets and force modes.
- A shared signed longitudinal controller should compute normal drive/brake effort.
- An allocator should map that effort to throttle/brake.
- Keep terminal safety, stop-guidance, and failure logic intact.

Implement exactly this:
1. Add internal helpers for:
   - speed-plan construction
   - signed longitudinal effort computation
   - effort-to-actuator allocation
2. Refactor the normal drive path in `run_route_leg(...)` to use:
   - speed target
   - signed effort
   - allocator
3. Remove throttle-limit shaping from normal behavior:
   - no normal-path dependence on `throttle_limit`, terminal progress floor, or profile throttle caps
4. Keep only hard force modes:
   - `hold`
   - `full_brake`
   - `coast`
   - `auto`
5. Preserve the existing speed-envelope planner:
   - `stop_speed_cap(...)`
   - `required_stop_distance_m(...)`
   - `can_enter_stop_guidance(...)`
   - stop-progress channel
   - terminal failure serialization
6. Update preview tests to match the new architecture and current stop-guidance semantics.
7. Update `docs/control-model.md` and `docs/runtime.md` to describe the new speed-centric controller.

Do not:
- redesign route geometry
- redesign waypoint semantics
- redesign CLI or route_book
- remove stop-guidance safety checks
- solve this by adding more throttle caps
- reintroduce a separate aggressive fast endgame strategy

Required validation:
- `luac -p programs/train_controller.lua`
- `lua tests/previews/controller_preview.lua`
- `lua tests/previews/test_outside_capture_window.lua`
- verify that normal control no longer depends on throttle-limit shaping
- inspect whether new logs expose:
  - `speed_plan_target_mps`
  - `speed_plan_force_mode`
  - `effort_cmd`
  - `allocated_throttle`
  - `allocated_brake`

When done, summarize:
- how the planner/state machine now differs from the actuator layer
- which throttle-centric controls are no longer behavior-defining
- which tests were updated and passed
- whether the real-log conservative/fast split still matches the intended behavior
- any remaining uncertainty in real-save terminal behavior
