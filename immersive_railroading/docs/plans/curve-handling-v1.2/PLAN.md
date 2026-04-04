# Curve Handling V1.2: Current-State Handoff for Terminal Determinism

## Summary
- This handoff is based only on the current controller state and the newest verified logs.
- Route and waypoint handling are already in place and are no longer the primary problem.
- The remaining issue is terminal determinism in the final leg: with the same `stop_buffer_m`, stopping position still depends too much on start position and residual end-phase dynamics.
- `route` is the primary focus. `goto` and `goto --via` inherit the same terminal behavior automatically because they use the same route/leg runner.

## Current Verified State
- The single V1 production controller remains `programs/train_controller.lua`.
- The current controller already contains:
  - `guidance_mode=route|stop`
  - `terminal_stop_target`
  - `terminal_brake_snapshot_mps2`
  - `terminal_buffer_brake_active`
  - `buffer_settle_mode`
  - `terminal_success_stop_ok`
  - `terminal_success_physical_ok`
- Local verification for the current workspace state is green:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
- `path_test18.log` shows multiple successful `fast` runs with `stop_buffer_m=6`.
  - Relevant good reference:
    - `arrived_at_target`
    - `physical_distance=5.24m`
    - `physical_buffer_error=0.76m`
    - `terminal_success_stop_ok=true`
    - `terminal_success_physical_ok=true`
- `path_test19.log` shows the remaining problem when the train starts farther from the target.
  - Relevant failing reference:
    - `stop_guidance_entry` at `physical_distance=5.78m`
    - later `physical_distance=3.63m`
    - `physical_buffer_error=2.37m`
    - `terminal_success_stop_ok=true`
    - `terminal_success_physical_ok=false`
    - the run is not falsely accepted; it is later aborted by the user

## Diagnosis
- The core problem is no longer false terminal success acceptance in the obvious cases.
- The core problem is also no longer generic curve handling before the final leg.
- The remaining problem is start-position-dependent residual energy and timing in the terminal phase:
  - the train can still enter the final stop corridor too late or with too much residual forward energy
  - this causes the final physical halt to drift relative to the intended `stop_buffer_m`
- The controller now correctly distinguishes:
  - stop-target correctness
  - physical-buffer correctness
- What still needs improvement is deterministic convergence so that both correctness checks become true in a tighter and more reproducible range.

## Implementation Direction
- Do not redesign route geometry, CLI, route book handling, or the waypoint model.
- Do not introduce separate logic for `goto`; keep all work in the shared terminal path used by `route`, `goto`, and `goto --via`.
- Keep the existing route architecture:
  - pass-through legs for intermediate geometry
  - terminal leg with `route_guidance -> stop_guidance`
  - late stop-axis capture
- Focus only on the last-leg endgame:
  - tighten when and how the controller enters `stop_guidance`
  - reduce start-position-dependent residual dynamics before capture
  - improve repeatability of the final physical stop relative to `stop_buffer_m`
- Keep the current two-part terminal result model:
  - `terminal_success_stop_ok`
  - `terminal_success_physical_ok`
- Keep existing safety priorities intact:
  - `stop_first`
  - `near_target_correction`
  - off-target-line and stall failures
- Do not do a logger redesign.
  - Use the existing terminal fields.
  - Add log output only if a missing terminal decision is still not observable.

## Concrete Next-Step Focus
- Evaluate whether `stop_guidance` is still entered too late under higher residual energy from farther starts.
- Tighten terminal determinism without reworking the whole route model:
  - buffer-aware deceleration before `stop_guidance`
  - snapshot-based terminal entry readiness
  - controlled settle behavior only inside the existing safe terminal corridor
- Preserve the current good `fast` result from `path_test18.log`.
- Improve the `path_test19.log` behavior so that the train does not stop materially too close to the physical target when starting farther away.

## Non-Goals
- No automatic rail graph discovery
- No new route syntax
- No route-book schema changes
- No new waypoint requirements for the already working route
- No return to old logger/OpenOS/deployment debugging unless the deployed file is first shown to differ from the workspace file

## Test Plan
- Static checks:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
- Real-log validation must use save logs, not screenshots.
- Primary reference logs:
  - `path_test18.log`
  - `path_test19.log`
- Acceptance scenarios:
  - `path_test18`-style run remains successful
  - `path_test19`-style farther-start run ends materially closer to the desired `stop_buffer_m`
  - no regression in terminal safety behavior
  - no new oscillation on the final curve
  - no new `reverser_mismatch`
- Cross-entrypoint regression:
  - `route` is the primary case
  - `goto` and `goto --via` only need regression coverage because they share the same terminal code path

## Assumptions and Defaults
- `programs/train_controller.lua` is the source of truth for the current implementation state.
- `AGENTS.md` must be read first in any follow-up session.
- The next session should treat this as a terminal-determinism problem, not as a restart of the older route-geometry planning phase.
- Deployment to the save must be verified separately before interpreting any new in-game result.
