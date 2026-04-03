# Immersive Railroading OpenComputers

Foundation V1 for an OpenComputers-driven Immersive Railroading control stack.

V1 deliberately keeps scope narrow:
- one real controller in `programs/train_controller.lua`
- compact TODO skeletons for stations, signals, junctions, routes, and install flow
- agent-friendly docs that preserve observed runtime facts and known mismatches

The controller targets `component.ir_remote_control` and currently supports:
- `inspect`
- `goto <x> <y> <z> [cruise_kmh] [stop_buffer_m]`

For OpenOS train control, prefer `trainctl ...`.
Why: the built-in `lua` frontend parses `-` and `--` arguments before your script sees them, which breaks negative coordinates and `--log`.

For OpenOS installation, prefer `lua programs/ir_install.lua`.
Why: OpenOS already ships a different `install` command, so the project uses a distinct entrypoint to avoid collisions.

See `docs/README.md` for the documentation map and `AGENTS.md` for working rules for future sessions.
