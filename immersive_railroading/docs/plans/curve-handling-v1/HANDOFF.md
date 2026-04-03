# Curve Handling Handoff

## Ready Prompt
You are continuing the next planning/implementation phase for the Immersive Railroading OpenComputers project in:

`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`

Important constraints:
- You may write only inside `/home/mrphaot/Dokumente/lua/minecraft`.
- The PrismLauncher instance and the test-world save are inspect-only:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`
- Do not invent APIs or behavior. If something is unclear, inspect local files, the installed environment, and the real OpenComputers save logs first.
- `programs/train_controller.lua` stays the single production controller file for V1.
- Comments should explain mainly why.
- Prefer reading the real save logs directly instead of relying on screenshots.

Before making changes:
1. Read this handoff first.
2. Then read `docs/runtime.md` and inspect `programs/train_controller.lua`.
3. Treat this session as curve-handling work, not a restart of the earlier PID/logging/debugging work.

## Current Status
- The PID/regulator baseline is now stable enough for straight runs and some reverse runs.
- `programs/trainctl.lua` exists and is the preferred OpenOS entrypoint.
- Logging works and writes real files to the OpenComputers drive.
- `Strg+C` abort works, confirmed by `abort_test28.log`.
- The remaining blocker is route geometry before curves, not logger creation, not OpenOS argument parsing, and not a stale deployment mismatch.

## Important Paths
- Workspace root:
  - `/home/mrphaot/Dokumente/lua/minecraft`
- Project root:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- Read-only PrismLauncher instance:
  - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
- Read-only test save:
  - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`
- Real OpenComputers drive used for debugging:
  - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs`
- Local controller:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/programs/train_controller.lua`
- Deployed controller in the save:
  - `/home/mrphaot/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/train_controller.lua`

## Confirmed Runtime / CLI Facts
- OpenOS `lua` pre-parses `-` and `--`, which is why `trainctl.lua` exists.
- Preferred in-game usage:
  - `trainctl inspect --log`
  - `trainctl goto <x> <y> <z> <cruise_kmh> <stop_buffer_m> --log=reverse_test30.log`
- Fallback only when necessary:
  - `lua train_controller.lua -- goto ...`
- `argv` inside the script stays 1-based.
- Negative coordinates were not a Lua indexing issue once `trainctl` was used correctly.

## Confirmed Current Controller Features
- Per-line append logging works.
- The controller already tracks both `target_line_axis` and `motion_axis`.
- The log already includes:
  - `target_axis`
  - `motion_axis`
  - `axis_source`
  - `alignment_to_target`
  - `distance_delta`
  - `progress_speed`
  - `moving_away_confidence`
  - `startup_guard_active`
  - `curve_guard_active`
- Terminal handling already includes `arrived_within_v1_limit`.
- User abort handling already includes `aborted_by_user` and a safe-stop path.

## Latest Verified Findings
- `reverse_test28.log` contains a good result when the run begins in the curve. It reaches `arrived_within_v1_limit`.
- `reverse_test29.log` still shows no meaningful improvement when the run begins before the curve. It repeatedly enters `moving_away_from_target` early.
- `reverse_test30.log` confirms that the newest controller version really is deployed:
  - `startup_guard_active=true` appears in the early lines
  - the train still moves strongly away from the target early anyway
  - early samples show strongly negative `progress_speed` and `speed_toward_target`
- `abort_test28.log` confirms that `Strg+C` now produces a real logged abort:
  - `aborted_by_user reason=interrupted ...`

Key interpretation:
- This is not a version mismatch.
- This is no longer mainly a threshold-tuning bug.
- The direct world-space target vector is a poor proxy for real rail direction before a curve.

## Core Diagnosis
- The remaining problem is structural curve/path handling.
- A single target point in world space is insufficient before curves.
- When the train starts before a curve, the controller can measure genuine negative progress against the straight target vector even while the train is still following the correct rail path.
- Starting inside the curve works better because the instantaneous rail tangent is then closer to the goal vector.

## Next Recommended Direction
- Plan a waypoint or multi-stage route approach instead of adding more local threshold tuning.
- Keep the current controller core, but add route guidance above it.
- Acceptable next directions include:
  - explicit waypoints supplied by the user
  - a short sequence of sub-goals
  - a route-book-driven intermediate target system

Do not spend the next session on these first:
- re-fixing logger creation
- re-opening the old OpenOS argument parsing issue
- assuming a version mismatch without checking the deployed file and the newest logs

## Useful Logs To Read First
- `abort_test28.log`
- `reverse_test28.log`
- `reverse_test29.log`
- `reverse_test30.log`

Older logs still help for history, but those four should drive the next session.

## Acceptance Criteria For The Next Session
- Produce a concrete curve-handling design that works when the train starts before a curve.
- Preserve the current working behavior for the start-inside-curve case.
- Preserve `Strg+C` abort behavior.
- Keep `train_controller.lua` as the single V1 production controller file.
- Do not write anything under the PrismLauncher instance or save paths.

## Preserved User-Facing Behavior
- `trainctl goto <x> <y> <z> <cruise_kmh> <stop_buffer_m> [--log=...]`
- `trainctl inspect [--log=...]`
- No silent parameter swapping.
- No dependence on `lua ...` as the primary user-facing entrypoint.
- Curve handling is the only major open planning topic for the next session.
