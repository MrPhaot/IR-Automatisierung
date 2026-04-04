# Immersive Railroading OpenComputers

Foundation V1 for an OpenComputers-driven Immersive Railroading control stack.

V1 deliberately keeps scope narrow:
- one real controller in `programs/train_controller.lua`
- compact TODO skeletons for stations, signals, junctions, routes, and install flow
- agent-friendly docs that preserve observed runtime facts and known mismatches

The controller targets `component.ir_remote_control` and currently supports:
- `inspect [--log[=path]]`
- `goto <x> <y> <z> [cruise_kmh] [stop_buffer_m] [--via <x> <y> <z> ...] [--profile=conservative|fast] [--log[=path]]`
- `route <name> [--profile=conservative|fast] [--log[=path]]`

`stop_buffer_m` is the terminal stop distance that the final leg should leave in front of the train.
Why: V1 now uses that buffer first as remaining distance to the physical target and only freezes a final stop axis late in the end approach, so known-good curves keep working without forcing another waypoint.

Why the extra route layer exists:
- the controller still does not infer rail topology from the world
- `--via` and `route_book.lua` let you supply explicit curve geometry so before-curve runs do not collapse back onto one misleading straight target vector
- `route_book.lua` ships empty on purpose because station coordinates are save-specific
- the final stop now includes a low-speed forward recovery inside the terminal no-reverse window, so heavy consists are less likely to deadlock short of the goal after the route legs already worked

For OpenOS train control, prefer `trainctl ...`.
Why: the built-in `lua` frontend parses `-` and `--` arguments before your script sees them, which breaks negative coordinates and flags such as `--log` and `--profile`.

For OpenOS installation, prefer `lua programs/ir_install.lua`.
Why: OpenOS already ships a different `install` command, so the project uses a distinct entrypoint to avoid collisions.

See `docs/README.md` for the documentation map and `AGENTS.md` for working rules for future sessions.
