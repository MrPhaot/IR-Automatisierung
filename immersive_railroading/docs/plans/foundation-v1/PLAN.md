# Immersive Railroading OpenComputers Foundation V1

## Summary
- Implement the project only inside `immersive_railroading/`.
- Build one real controller program in a single Lua file for `component.ir_remote_control`, plus concise skeleton programs for stations, signals, junctions, routes, and installation.
- Add agent-oriented documentation, a `docs/plans/` area, explicit acceptance criteria, and a ready-to-run handoff prompt for a future agent.
- Use `ir_remote_control` as the primary V1 control surface, while structuring the repo so later sessions can add `ir_augment_detector`, `ir_augment_control`, Factorio-like block reservations, and station/junction logic cleanly.

## Orientation Sources
Use these as the baseline references during implementation so the next agent knows what to inspect and imitate.

- Main reference repo for documentation style and plan/prompt layout:
  - `https://github.com/oleksandr-k73/Kryptografie-Projekt`
- Architecture inspiration for dispatcher/station/junction separation:
  - `https://github.com/Enlight3ned/AutoRail`
- Local research note for brake behavior:
  - `/home/mrphaot/Downloads/Air Brake Func for 1.9 WIP.pdf`
- Read-only Minecraft instance to inspect only:
  - `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft`

Confirmed environment facts already derived from the real instance and worth preserving in the new docs:

- Mods present:
  - `ImmersiveRailroading-1.7.10-forge-1.10.0.jar`
  - `OpenComputers-1.12.16-GTNH.jar`
- Confirmed IR OC component names:
  - `ir_remote_control`
  - `ir_augment_detector`
  - `ir_augment_control`
- Confirmed useful methods/events from the installed IR build:
  - `ir_remote_control`: `info`, `consist`, `getTag`, `setTag`, `setThrottle`, `setReverser`, `setBrake`, `setIndependentBrake`, `horn`, `bell`, `getPos`, `getLinkUUID`, `getIgnition`, `setIgnition`
  - augment event: `ir_train_overhead`
- Confirmed OC delivery path facts:
  - OpenComputers HTTP is enabled
  - OpenOS provides `wget`
  - `RadioRange=1000`
  - `RadioCostPerMetre=0`
  - `RadioEquipmentRequired=false`

## Implementation Changes
Create this repo structure under `immersive_railroading/`:

- `README.md`
- `AGENTS.md`
- `programs/train_controller.lua`
- `programs/station_dispatch.lua`
- `programs/signal_reservation.lua`
- `programs/junction_controller.lua`
- `programs/route_book.lua`
- `programs/install.lua`
- `programs/install_manifest.lua`
- `docs/README.md`
- `docs/runtime.md`
- `docs/control-model.md`
- `docs/signals-and-blocks.md`
- `docs/operations/download-and-run.md`
- `docs/research/air-brake-notes.md`
- `docs/plans/foundation-v1/PLAN.md`
- `docs/plans/foundation-v1/PROMPT.md`
- `tests/previews/controller_preview.lua`
- `tests/previews/manifest_preview.lua`
- `tests/previews/reservation_preview.lua`

Implement `programs/train_controller.lua` as the only non-skeleton production program in V1.

Behavior and interface:

- It must be one file.
- It must use `component.ir_remote_control` as the primary runtime dependency.
- It must support:
  - `inspect`
  - `goto <x> <y> <z> [cruise_kmh] [stop_buffer_m]`
- It must internally include:
  - train snapshot reading
  - brake-model learning from observed deceleration
  - physics-derived PID baseline from available train data
  - stop-speed envelope from remaining distance
  - output mapping to throttle, reverser, brake, and hold state
- It must keep tunables explicit and named, not magic numbers.
- It must explain “why” in comments at the important decision points.

Controller design defaults:

- Derive a proportional-scale equivalent from a characteristic speed horizon.
- Derive integral and derivative scales from drive/brake horizons rather than arbitrary constants.
- Use runtime brake calibration as the primary brake source.
- Keep a documented extension point for future brake-source enrichment from your PDF or other measurements.
- Use straight-line waypoint distance in V1.
- Prepare interfaces so later route/station code can feed waypoint sequences without rewriting the controller core.

Skeleton program intent:

- `station_dispatch.lua`
  - TODO-only reminder for named stations, stop sequencing, and station handoff to `train_controller.lua`.
- `signal_reservation.lua`
  - TODO-only reminder for block ownership, route claims, and signal states.
- `junction_controller.lua`
  - TODO-only reminder for switch locking, conflict checks, and release rules.
- `route_book.lua`
  - TODO-only reminder for named routes, station definitions, and waypoint chains.
- `install.lua` and `install_manifest.lua`
  - real enough to show intended GitHub Raw download/update model, even if still lightweight in V1.

## Important Interfaces
Station shape to standardize for later sessions:

```lua
STATIONS = {
  depot = {x = 0, y = 64, z = 0, cruise_kmh = 40, stop_buffer_m = 2},
  yard_exit = {x = 120, y = 64, z = -35, cruise_kmh = 25, stop_buffer_m = 3},
}
```

Installer manifest shape:

```lua
return {
  version = "0.1.0",
  files = {
    {
      path = "programs/train_controller.lua",
      url = "https://raw.githubusercontent.com/<user>/<repo>/<ref>/immersive_railroading/programs/train_controller.lua"
    }
  }
}
```

Reservation model shape for future signal work:

```lua
BLOCKS = {
  main_01 = {owner = nil},
  main_02 = {owner = nil},
}

ROUTES = {
  northbound_main = {
    blocks = {"main_01", "main_02"},
    switches = {J1 = "main"}
  }
}
```

## Tested Previews
These previews were already exercised locally with host `lua 5.4.6` and should be reproduced in repo-local preview files.

Physics-derived PID baseline preview:

```lua
local a_drive = math.min(traction_n / mass_kg, power_w / math.max(v_ref_mps, 1) / mass_kg)
local t_drive = v_ref_mps / a_drive
local t_brake = v_ref_mps / brake_model.full_service_mps2

local kp = 1 / v_ref_mps
local ki = kp / t_brake
local kd = kp * math.min(t_drive, t_brake)
```

Brake learning and stop-profile preview:

```lua
local observed = math.max((prev_speed_mps - curr_speed_mps) / dt_s, 0)
local full_service = observed / math.max(brake_cmd ^ curve_exponent, 0.05)
model.full_service_mps2 = ema(model.full_service_mps2, full_service, memory_s, dt_s)

local target_speed = math.min(
  cruise_mps,
  math.sqrt(2 * model.full_service_mps2 * math.max(remaining_m - stop_buffer_m, 0))
)
```

Factorio-like reservation preview:

```lua
for _, block_id in ipairs(route.blocks) do
  if blocks[block_id].owner and blocks[block_id].owner ~= owner then
    return false
  end
end

for switch_id, required in pairs(route.switches) do
  if switch_locks[switch_id] and switch_locks[switch_id] ~= owner then
    return false
  end
  switches[switch_id] = required
  switch_locks[switch_id] = owner
end
```

Observed preview values from the passing harness using your screenshot train data:

- `kp=0.0942`
- `ki=0.0109`
- `kd=0.4522`
- learned full-service brake estimate: `1.230 m/s^2`
- stop-speed cap example:
  - `7.36 m/s` at `25 m` remaining
  - `21.24 m/s` at `400 m` remaining
- manifest preview passed for a GitHub Raw `wget -f` install plan

## Test Plan
Local validation inside this workspace:

- `luac -p` for every Lua file under `immersive_railroading/`
- `lua tests/previews/controller_preview.lua`
- `lua tests/previews/manifest_preview.lua`
- `lua tests/previews/reservation_preview.lua`

In-game smoke checks to document after implementation:

- `inspect` prints a sane snapshot from `ir_remote_control`
- `goto` accelerates, cruises, brakes, and settles near the target point
- brake learning updates over time instead of staying constant
- `wget` install path works from GitHub Raw on OpenOS
- `install_manifest.lua` rejects duplicate or unsafe paths
- docs match actual runtime behavior observed in game

## Abgabekriterien
Die Arbeit gilt erst dann als fertig, wenn alle Punkte unten erfüllt sind.

- The repo structure under `immersive_railroading/` exists exactly as planned, with only the controller fully implemented and the other listed program files as concise TODO skeletons.
- `programs/train_controller.lua` is a single file and contains:
  - real `ir_remote_control` integration
  - explicit named tunables
  - no unexplained PID magic numbers
  - comments focused on “why”
- `AGENTS.md` contains:
  - project overview
  - confirmed runtime/API facts
  - documentation map
  - working rules
  - explicit note that the Minecraft instance path is read-only
  - links to both reference repos
- The documentation set exists and is progressive rather than repetitive.
- `docs/plans/foundation-v1/PLAN.md` exists as a Markdown copy of the finalized implementation plan.
- `docs/plans/foundation-v1/PROMPT.md` exists and contains the handoff prompt below in adapted repo-local form.
- Preview/test files exist and pass locally with `lua` and `luac -p`.
- `docs/operations/download-and-run.md` contains:
  - GitHub Raw hosting assumption
  - exact OpenOS `wget` workflow
  - update workflow
  - offline/manual fallback note
- The implementation records any mismatch between planned and observed in-game behavior in docs instead of silently assuming.
- No file outside `/home/mrphaot/Dokumente/lua/minecraft` is modified.

## Assumptions And Defaults
- V1 uses absolute XYZ targets for actual stopping, because that is the lowest-risk first implementation.
- Architecture must still prepare for named stations, routes, block reservations, signals, and junction ownership.
- The air-brake PDF is a research source, not automatically canonical for your installed build.
- The future agent may read the Minecraft instance and the PDF, but must not write there.
- The future agent should prefer OpenComputers/OpenOS assumptions over ComputerCraft assumptions when adapting ideas from `AutoRail`.
