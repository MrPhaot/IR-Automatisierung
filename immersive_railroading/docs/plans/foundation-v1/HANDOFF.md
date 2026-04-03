# Foundation V1 Handoff

## Current Status
- Repo root: `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- The only real production program is `programs/train_controller.lua`.
- The current local workspace version passed:
  - `luac -p` for all Lua files
  - `lua tests/previews/controller_preview.lua`
  - module load of `programs/train_controller.lua`
- The OpenComputers test machine in the test world has a matching deployed `train_controller.lua`.

## Important Paths
- Workspace project:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- Read-only Minecraft instance:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`
- Test world save, inspect only:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)`
- Real OpenComputers virtual drive used for debugging:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs`

## Confirmed OpenOS / CLI Facts
- `trainctl.lua` exists because OpenOS `lua` pre-parses `-` and `--` arguments.
- Preferred in-game invocation:
  - `trainctl inspect --log`
  - `trainctl goto <x> <y> <z> <cruise_kmh> <stop_buffer_m> --log=reverse_test1.log`
- Fallback only when necessary:
  - `lua train_controller.lua -- goto ...`
- `argv` inside Lua stays 1-based.
- Negative coordinates and `--log` were previously misdiagnosed; the real problem was OpenOS `lua` argument parsing.

## Confirmed Logger State
- Logger works now.
- Real log files exist in the OC drive, for example:
  - `train_controller.log`
  - `reverse_test.log`
  - `reverse_test1.log`
- The problem is no longer log creation; the problem is controller geometry / stopping logic.

## Confirmed Runtime Data
From `inspect` on the real OC machine:
- Position example:
  - `x = 251.28341075907`
  - `y = 64.234685373987`
  - `z = -76.5`
- Useful `raw_info` fields actually present:
  - `direction = EAST`
  - `max_speed = 76.465505226481`
  - `horsepower = 2549`
  - `traction = 194161`
  - `weight = 80930.0`
  - `reverser = -1.0`
  - `speed = -0.0`
- `raw_consist` also exposes:
  - `weight_kg = 100493.0`
  - `total_traction_N = 194161`

## Current Controller Diagnosis
The current failure is not mainly the reverse-state machine anymore. The bigger issue is geometry:

- The controller computes:
  - `longitudinal_m = dot(to_target, axis)`
  - `lateral_m = length(reject(to_target, axis))`
  - `remaining_m = abs(longitudinal_m)`
- But stop logic and speed envelope use only `remaining_m`.
- `lateral_m` is only logged, not used in stopping or arrival.

This is confirmed by the real log `reverse_test1.log`:
- Start:
  - `longitudinal=147.50m lateral=0.00m`
- Almost immediately later:
  - `longitudinal=0.68m lateral=147.50m cap=0.00m/s`
- That means the learned axis rotated so that nearly the whole target error became lateral.
- The controller then thought it was almost longitudinally arrived and stopped on the opposite side.

## Most Important Consequence
The next agent should treat this as an axis / target-frame problem:
- arrival must not depend only on longitudinal distance
- stop-speed cap must not collapse to `0` while lateral error is huge
- axis updates near low speed can rotate the local frame into nonsense

## Suggested Next Fix
Implement a more robust target-frame policy in `programs/train_controller.lua`:

1. Freeze or heavily constrain the motion axis once a maneuver is underway.
2. Add a combined arrival condition that requires both:
   - small longitudinal error
   - small lateral error
3. Prevent `target_speed_mps` from dropping to `0` unless lateral error is also within a small threshold.
4. Log the frame state explicitly:
   - axis vector
   - longitudinal error
   - lateral error
   - whether axis is frozen
5. Keep the strict CLI:
   - `goto <x> <y> <z> <cruise_kmh> <stop_buffer_m>`
   - no silent parameter swapping

## Useful Real Logs
Read these directly from the save, do not rely only on screenshots:
- `.../programs/train_controller.log`
- `.../programs/reverse_test.log`
- `.../programs/reverse_test1.log`

The most important observed pattern:
- `reverse_test.log` showed the old reverser flip problem.
- `reverse_test1.log` shows the newer geometry problem:
  - the train stops with `longitudinal` near zero
  - while `lateral` remains about `147.50m`

## Branch / Download Notes
- The user currently works on the Git branch `PID-Regler`.
- Raw branch URL shape:
  - `https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/PID-Regler/...`
- `install_manifest.lua` still points to `main`, so direct `wget` for specific files is safer than running the installer if the user wants branch-specific updates.

## Rules To Preserve
- Write only inside `/home/mrphaot/Dokumente/lua/minecraft`.
- The PrismLauncher instance and the test world save are inspect-only.
- Do not modify anything under `~/.local/share/PrismLauncher/...`.
- Comments should explain why.
- Keep `train_controller.lua` as a single production file for V1.
