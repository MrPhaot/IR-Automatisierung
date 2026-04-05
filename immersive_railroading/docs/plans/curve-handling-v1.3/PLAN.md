# Curve Handling V1.3: Current-State Handoff for Terminal Deadlock Fix

## Summary
- This handoff is based on the current workspace controller and the newest verified save-log evidence.
- Route and waypoint handling are already in place and are no longer the primary problem.
- The primary problem is now a terminal deadlock in the final leg:
  - a good buffered stop reference already exists
  - a farther-start run still shows buffer spread
  - the newest regression reaches `guidance_mode=stop` and then stalls forever in `final_brake_hold`
- `route` is the primary focus. `goto` and `goto --via` inherit the same terminal behavior automatically because they use the same route/leg runner.

## Sources
- `AGENTS.md`
- `programs/train_controller.lua`
- `docs/runtime.md`
- `docs/control-model.md`
- real save logs:
  - `path_test19.log`
  - `path_test20.log`
- current workspace verification:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`

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
- The previously verified good buffered-stop reference remains:
  - `arrived_at_target`
  - `stop_buffer_m=6`
  - `physical_distance=5.24m`
  - `physical_buffer_error=0.76m`
  - `terminal_success_stop_ok=true`
  - `terminal_success_physical_ok=true`
- Note on evidence hygiene:
  - `path_test18.log` is referenced by the current project state as the good reference run
  - the file is not currently present in the inspected save tree
  - this handoff therefore preserves the verified reference values above and uses `path_test19.log` plus `path_test20.log` as the directly readable current save evidence

## Current Diagnosis
- `path_test19.log` shows the remaining determinism issue from a farther start:
  - `stop_guidance_entry` at `physical_distance=5.78m`
  - later `physical_distance=3.63m`
  - `physical_buffer_error=2.37m`
  - `terminal_success_stop_ok=true`
  - `terminal_success_physical_ok=false`
  - the run is not falsely accepted; it is aborted by the user
- `path_test20.log` shows the new main regression:
  - `stop_guidance_entry` at `physical_distance=9.99m`
  - `stop_guidance_entry_stop_longitudinal=3.94m`
  - then repeated `reason=final_brake_hold`
  - `physical_distance=9.97m`
  - `physical_buffer_error=3.97m`
  - `buffer_settle_mode=none`
  - `buffer_settle_block_reason=target_ahead`
  - `terminal_success_stop_ok=false`
  - `terminal_success_physical_ok=false`
  - no `arrived_*`
  - no `terminal_limit_exit`
  - the run ends only with `aborted_by_user`

## Deadlock Interpretation
- The current problem is not primarily:
  - false success acceptance
  - generic curve handling before the final leg
  - route syntax or waypoint modeling
- The current main problem is a terminal deadlock state:
  - the train is already in `guidance_mode=stop`
  - the target is still ahead
  - the train is effectively stopped
  - success is false
  - neither forward nor reverse settle activates
  - failure does not escalate
  - the controller therefore loops in `final_brake_hold`
- From the current controller structure this strongly suggests a state that is:
  - not successful
  - not recoverable under current settle gating
  - not failing
  - therefore non-terminating

## Implementation Direction
- Do not redesign route geometry, CLI behavior, route-book handling, or waypoint semantics.
- Do not introduce special-case logic for `goto`; keep all work in the shared terminal path used by `route`, `goto`, and `goto --via`.
- Keep the existing route architecture:
  - pass-through legs for intermediate geometry
  - terminal leg with `route_guidance -> stop_guidance`
  - late stop-axis capture
- Focus the next implementation only on terminal deadlock removal and safe resolution:
  - deadlock-free terminal decision-making after `stop_guidance`
  - controlled forward recovery when the target is still ahead and the train has stalled
  - explicit failure escalation when the run is neither successful nor recoverable
  - only after that, further terminal determinism tuning

## Concrete Next-Step Focus
- Detect the “stopped short in stop guidance” deadlock explicitly.
- Guarantee that this state resolves into exactly one of:
  - controlled forward recovery
  - explicit terminal failure
- Keep reverse settle restricted to true overshoot cases.
- Avoid using the fine-trim forward settle window as the only recovery gate for deadlock resolution.
- Preserve the current good buffered-stop behavior represented by the verified reference run.
- Preserve the current rejection behavior from `path_test19.log`: a bad physical buffer halt must still not be accepted as success.

## Non-Goals
- No automatic rail graph discovery
- No new route syntax
- No route-book schema changes
- No waypoint redesign
- No logger redesign
- No restart of old OpenOS argument/debugging work unless workspace and save deployment are first shown to differ in a way that matters

## Test Plan
- Static checks:
  - `luac -p programs/train_controller.lua`
  - `lua tests/previews/controller_preview.lua`
- Real-log validation must use save logs, not screenshots.
- Primary current save evidence:
  - `path_test19.log`
  - `path_test20.log`
- Historical-but-still-relevant verified reference:
  - the good buffered stop summarized above from the current project state
- Acceptance scenarios:
  - a `path_test20`-style run must no longer hang forever in `final_brake_hold`
  - acceptable outcomes for that state are:
    - controlled forward recovery
    - or explicit `terminal_limit_exit`
  - unacceptable outcome:
    - repeated stationary `final_brake_hold` with no success and no failure
  - a `path_test19`-style farther-start run must still not be falsely accepted
  - no regression into oscillation on the final curve
  - no new `reverser_mismatch`
- Cross-entrypoint regression:
  - `route` is the primary case
  - `goto` and `goto --via` only need regression coverage because they share the same terminal code path

## Assumptions and Defaults
- `programs/train_controller.lua` is the source of truth for the current implementation state.
- `AGENTS.md` must be read first in any follow-up session.
- `path_test20.log` is the highest-priority evidence source because the deadlock must be removed before further accuracy tuning is meaningful.
- The next session should treat this as a terminal deadlock and recovery problem first, and only then as a remaining determinism problem.
- Deployment to the save must be verified separately before interpreting any new in-game result.
