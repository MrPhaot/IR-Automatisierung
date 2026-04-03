# Cleanup-1 Handoff

## Current Status
- Repo root: `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- This session is about cleanup and anti-drift work, not route geometry or curve planning.
- The current `cleanup-1` plan already captures the intended refactor direction, but it needed a handoff packet so another agent can continue without chat history.
- The main remaining work is concentrated in:
  - `programs/trainctl.lua`
  - `programs/train_controller.lua`
  - `tests/previews/controller_preview.lua`

## Important Paths
- Repo root:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- Writable root:
  - `/home/mrphaot/Dokumente/lua/minecraft`
- Read-only PrismLauncher instance:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
- Read-only test save:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`
- Cleanup plan:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/plans/cleanup-1/PLAN.md`
- Cleanup handoff:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/plans/cleanup-1/HANDOFF.md`
- Cleanup prompt:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/plans/cleanup-1/PROMPT.md`

## Constraints To Preserve
- Write only inside `/home/mrphaot/Dokumente/lua/minecraft`.
- Never modify anything under `~/.local/share/PrismLauncher/...`.
- Keep `programs/train_controller.lua` as the single production controller file for V1.
- Comments should explain why.
- Do not mix this cleanup pass with the separate `curve-handling-v1` work.

## What Is Already Fixed
- Docs lint and wording cleanup from the earlier review rounds.
- Abort logging and `aborted_by_user` handling in `train_controller.lua`.
- Preview `must_stop_now` shadowing.
- Preview brake-exit margin alignment.
- Preview runtime-error normalization order.
- `train_controller.lua` built-in auto-run path preserving exit code `130`.

## What Is Still Open
- The wrapper must preserve abort semantics even when failures are thrown instead of returned.
- The controller must prefer consist-level power totals, not per-locomotive `info` power, when deriving train characteristics.
- Motion-axis stabilization must be used consistently in all `speed_toward_target_mps` recomputations.
- Safe-stop handling must attempt all stop setters even if one setter fails.
- The preview harness must stop copying production constants and lookup-path tables.

## Current Code Facts
- `trainctl.lua` currently calls `controller("__module__")` directly.
- `trainctl.lua` currently calls `module.main({...})` directly.
- `train_controller.lua` currently uses:
  - `power_w = pick_number(info, INFO_PATHS.power_w) or pick_number(consist, INFO_PATHS.power_w)`
- `train_controller.lua` still has two branch-local assignments of:
  - `speed_toward_target_mps = axis_speed_mps * desired_reverser`
- `train_controller.lua` currently implements `apply_safe_stop()` by delegating to:
  - `apply_controls(remote, safe_stop_control(brake))`
- `controller_preview.lua` still contains:
  - `local PROFILES =`
  - local lookup arrays for `INFO_PATHS`-style extraction and `HORSEPOWER_PATHS`

## Required Implementation Direction
- In `programs/trainctl.lua`:
  - add a local interrupt helper
  - `pcall`-protect both module load and `module.main`
  - stringify or normalize thrown errors before deciding between exit `130` and exit `1`
  - preserve stderr output
- In `programs/train_controller.lua`:
  - prefer `consist` before `info` for `power_w`
  - prefer `consist` before `info` for horsepower fallback
  - keep kW-to-W scaling and fallback defaults unchanged
  - make every `speed_toward_target_mps` reassignment use `motion_axis_speed_mps * desired_reverser`
  - rewrite `apply_safe_stop()` to call `setBrake`, `setIndependentBrake`, `setThrottle`, and `setReverser` independently in that order
  - aggregate setter failures into one error after attempting all setters
  - export `DEFAULTS`, `PROFILES`, `INFO_PATHS`, `HORSEPOWER_PATHS`, and `HORSEPOWER_TO_W` in `__module__` mode
- In `tests/previews/controller_preview.lua`:
  - load `train_controller.lua` in module mode
  - remove local duplicated constant/path-table definitions
  - source `DEFAULTS`, `PROFILES`, `INFO_PATHS`, `HORSEPOWER_PATHS`, and `HORSEPOWER_TO_W` from the production module
  - keep the already-fixed parity helpers and assertions intact
  - add or retain assertions for consist-first power precedence and imported profile completeness

## Validation Commands
- `luac -p immersive_railroading/programs/train_controller.lua`
- `lua immersive_railroading/tests/previews/controller_preview.lua`
- `rg -n "speed_toward_target_mps\\s*=" immersive_railroading/programs/train_controller.lua`
- `rg -n "local DEFAULTS = \\{|local PROFILES = \\{|local mass_paths =|local traction_paths =|local power_paths =|local horsepower_paths =|local max_speed_paths =" immersive_railroading/tests/previews/controller_preview.lua`
- `rg -n "controller\\(|module\\.main|os\\.exit" immersive_railroading/programs/trainctl.lua`

## Acceptance Criteria
- The wrapper returns exit code `130` for returned or thrown interrupt-like aborts.
- Controller power extraction prefers consist totals over per-locomotive `info` values.
- No special branch resets `speed_toward_target_mps` back to target-axis projection.
- `apply_safe_stop()` no longer routes through `apply_controls()`.
- The preview imports canonical definitions from `train_controller.lua` module mode.
- The preview test file still runs cleanly after the import switch.
