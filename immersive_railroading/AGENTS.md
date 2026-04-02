# AGENTS

## Project Overview
- Project root: `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`
- Goal: build an OpenComputers control stack for Immersive Railroading with a conservative V1 foundation.
- V1 ships one real runtime program: `programs/train_controller.lua`.
- Other production program files stay as short TODO skeletons so later sessions can expand them without untangling premature logic.

## Confirmed Runtime Facts
- Primary V1 component: `component.ir_remote_control`
- Also present for later phases: `component.ir_augment_detector`, `component.ir_augment_control`
- Confirmed `ir_remote_control` methods for this environment:
  - `info()`
  - `consist()`
  - `getPos()`
  - `setThrottle(number)`
  - `setReverser(number)`
  - `setBrake(number)`
  - `setIndependentBrake(number)`
  - `getIgnition()`
  - `setIgnition(boolean)`
  - tag, horn, and bell helpers are also available
- Confirmed augment event: `ir_train_overhead`
- OpenComputers HTTP is enabled and OpenOS provides `wget`
- The Minecraft instance at `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft` is read-only for this project

## Known Mismatch
- The installed IR jar contains bundled OpenComputers wiki text for the augment components, but not a field-by-field contract for the remote-control card `info()` payload.
- Because of that mismatch, `programs/train_controller.lua` uses confirmed method names plus defensive field extraction for train characteristics instead of assuming one undocumented `info()` schema.
- If future in-game inspection reveals the exact payload shape, update `docs/runtime.md` and simplify the extractor rather than leaving guesses in place.

## Documentation Map
- `README.md`: project entry point
- `docs/README.md`: documentation index
- `docs/runtime.md`: observed runtime/API notes and mismatches
- `docs/control-model.md`: controller model and why it is shaped this way
- `docs/signals-and-blocks.md`: future reservation architecture notes
- `docs/operations/download-and-run.md`: OpenOS `wget` install/update flow
- `docs/research/air-brake-notes.md`: research notes from the local PDF
- `docs/plans/foundation-v1/PLAN.md`: implementation plan snapshot
- `docs/plans/foundation-v1/PROMPT.md`: handoff prompt for future sessions

## Working Rules
- Write only inside `/home/mrphaot/Dokumente/lua/minecraft`.
- Treat the PrismLauncher Minecraft instance as inspect-only.
- Do not invent APIs or in-game behavior. Inspect local files, jars, docs, or tests first.
- Keep docs compact and progressive rather than repetitive.
- Comments should explain mainly why a decision exists.
- Preserve the separation between the real controller and future skeleton programs.
- Run local Lua previews and `luac -p` after edits.
- Record mismatches between the plan and observed runtime behavior in docs instead of silently coding around them.

## Reference Material
- Docs/plan style reference: `https://github.com/oleksandr-k73/Kryptografie-Projekt`
- Architecture inspiration only: `https://github.com/Enlight3ned/AutoRail`
- Local brake research note: `/home/mrphaot/Downloads/Air Brake Func for 1.9 WIP.pdf`
