# Immersive Railroading OpenComputers

Foundation V1 for an OpenComputers-driven Immersive Railroading control stack.

V1 deliberately keeps scope narrow:
- one real controller in `programs/train_controller.lua`
- compact TODO skeletons for stations, signals, junctions, routes, and install flow
- agent-friendly docs that preserve observed runtime facts and known mismatches

The controller targets `component.ir_remote_control` and currently supports:
- `inspect`
- `goto <x> <y> <z> [cruise_kmh] [stop_buffer_m]`

See `docs/README.md` for the documentation map and `AGENTS.md` for working rules for future sessions.
