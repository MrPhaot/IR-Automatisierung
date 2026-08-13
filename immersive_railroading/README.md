# Immersive Railroading OpenComputers

Foundation V1 for an OpenComputers-driven Immersive Railroading control stack, now with a station dispatcher and a Factorio-style schedule layer.

Baseline: Minecraft 1.7.10, Immersive Railroading 1.11.0 (GTNH port). The GitHub `TeamOpenIndustry/ImmersiveRailroading` changelog describes a different MC line (1.17+) and does not apply here.

Current production pieces:
- `programs/train_controller.lua` for local motion control
- `programs/station_dispatch.lua` for schedule execution, detector waits, and station-side redstone outputs
- `programs/route_book_editor.lua` for mouse-first terminal editing of detectors, stations, routes, and schedules
- reusable libs under `programs/lib/` for persistence, registry, wait evaluation, redstone I/O, and terminal UI

The controller targets `component.ir_remote_control` and currently supports:
- `inspect [--log[=path]]`
- `goto <x> <y> <z> [cruise_kmh] [stop_buffer_m] [--via <x> <y> <z> ...] [--profile=conservative|fast] [--log[=path]]`
- `route <name> [--profile=conservative|fast] [--log[=path]]`

The station dispatcher adds:
- `run <schedule> [--log[=path]]`
- `validate [schedule]`
- `inspect <schedule>`
- `detectors`

The production route controller is now speed-centric:
- planner/state chooses the current speed envelope and motion intent
- one signed effort path handles normal longitudinal control
- one allocator maps that effort to throttle or brake output

`stop_buffer_m` is the terminal stop distance that the final leg should leave in front of the train.
Why: V1 now uses that buffer first as remaining distance to the physical target and only freezes a final stop axis late in the end approach, so known-good curves keep working without forcing another waypoint.

Why the extra route layer exists:
- the controller still does not infer rail topology from the world
- `--via` and `route_book.lua` let you supply explicit curve geometry so before-curve runs do not collapse back onto one misleading straight target vector
- `route_book.lua` ships empty on purpose because station coordinates are save-specific
- the final stop now includes a low-speed forward recovery inside the terminal no-reverse window, so heavy consists are less likely to deadlock short of the goal after the route legs already worked

Profile intent in the current branch:
- `fast` primarily raises pass-through travel speed
- `conservative` keeps the slower terminal behavior and now also uses a stricter stop-guidance entry margin in the end approach

For OpenOS train control, prefer `trainctl ...`.
Why: the built-in `lua` frontend parses `-` and `--` arguments before your script sees them, which breaks negative coordinates and flags such as `--log` and `--profile`.

For OpenOS installation, prefer `lua programs/ir_install.lua`.
Why: OpenOS already ships a different `install` command, so the project uses a distinct entrypoint to avoid collisions.

`programs/route_book.lua` now ships with the frozen V1 top-level schema:
- `AUGMENTS`
- `STATIONS`
- `ROUTES`
- `SCHEDULES`

See `docs/README.md` for the documentation map, `docs/station-schedules.md` for the schedule model, and `AGENTS.md` for working rules for future sessions.
