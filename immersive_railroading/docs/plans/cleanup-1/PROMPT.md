You are continuing the `cleanup-1` pass for the Immersive Railroading OpenComputers project in:

`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`

Read these first:
- `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/plans/cleanup-1/HANDOFF.md`
- `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/plans/cleanup-1/PLAN.md`

Important constraints:
- You may write only inside `/home/mrphaot/Dokumente/lua/minecraft`.
- The PrismLauncher instance and the test save under `~/.local/share/PrismLauncher/...` are read-only.
- Keep `programs/train_controller.lua` as the single production controller file for V1.
- This pass is still cleanup and anti-drift work only. Do not mix it with curve-planning work.
- Preserve the user-facing CLI:
  - `trainctl inspect [--log=...]`
  - `trainctl goto <x> <y> <z> <cruise_kmh> <stop_buffer_m> [--log=...]`

The cleanup plan is mostly implemented. Only these two review findings remain:

1. `programs/trainctl.lua`
- The wrapper now uses `pcall`, but the thrown-error path still maps a thrown `"aborted by user"` to exit code `1`.
- Fix the `pcall(module.main, {...})` failure branch so that:
  - thrown `"aborted by user"` also exits `130`
  - thrown interrupt-like reasons also exit `130`
  - all other thrown failures still exit `1`
- Keep stderr output as it is now.

2. Cleanup docs validation commands
- The validation commands in:
  - `docs/plans/cleanup-1/PLAN.md`
  - `docs/plans/cleanup-1/HANDOFF.md`
  currently tell the reader to grep for `local PROFILES =|INFO_PATHS|HORSEPOWER_PATHS` in the preview.
- That check is now stale, because the preview correctly imports canonical tables from `train_controller.lua` and still contains alias lines like:
  - `local PROFILES = controller.PROFILES`
  - `local INFO_PATHS = controller.INFO_PATHS`
  - `local HORSEPOWER_PATHS = controller.HORSEPOWER_PATHS`
- Update the validation guidance so it verifies that the old duplicated tables/path arrays are gone without flagging the intentional import aliases as failures.

Already verified as correct, so do not reopen these unless you find an actual regression:
- `train_controller.lua` syntax passes `luac -p`
- `tests/previews/controller_preview.lua` runs successfully
- controller power extraction is now consist-first
- `speed_toward_target_mps` uses `motion_axis_speed_mps` consistently
- `apply_safe_stop()` no longer routes through `apply_controls()`
- `train_controller.lua` exports the canonical tables/constants needed by the preview
- the preview imports canonical definitions from the controller module

Expected validation after your fix:
- `luac -p immersive_railroading/programs/train_controller.lua`
- `lua immersive_railroading/tests/previews/controller_preview.lua`
- re-read `programs/trainctl.lua` and confirm thrown `"aborted by user"` now leads to exit `130`
- re-read the cleanup docs and confirm the validation commands no longer produce false negatives for the intentional preview imports

Before finishing:
- Summarize exactly what you changed
- State what you validated
- Mention any remaining cleanup debt, if any
