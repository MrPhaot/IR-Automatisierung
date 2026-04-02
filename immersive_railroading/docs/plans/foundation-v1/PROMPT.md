You are implementing the foundation plan for the Immersive Railroading OpenComputers project in:

`/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading`

Important constraints:
- You may write only inside `/home/mrphaot/Dokumente/lua/minecraft`.
- The Minecraft instance at `~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft` is read-only.
- Do not invent APIs or behavior. If something is unclear, inspect local files, the installed mod jars, existing docs, or ask.
- Comments must explain mainly “why”, not just “what”.
- Keep documentation agent-friendly and compact.
- This project is meant to continue across multiple sessions and multiple agents.

Your primary references:
- Plan to implement:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/docs/plans/foundation-v1/PLAN.md`
- Agent guide:
  - `/home/mrphaot/Dokumente/lua/minecraft/immersive_railroading/AGENTS.md`
- Style/reference repo for docs/plans:
  - https://github.com/oleksandr-k73/Kryptografie-Projekt
- Architecture inspiration only:
  - https://github.com/Enlight3ned/AutoRail
- Brake research note:
  - `/home/mrphaot/Downloads/Air Brake Func for 1.9 WIP.pdf`

Confirmed runtime facts from the installed environment:
- Primary V1 OC component: `component.ir_remote_control`
- Also present for later phases: `ir_augment_detector`, `ir_augment_control`
- Confirmed `ir_remote_control` methods relevant to V1:
  - `info()`
  - `consist()`
  - `getPos()`
  - `setThrottle(number)`
  - `setReverser(number)`
  - `setBrake(number)`
  - `setIndependentBrake(number)`
  - `getIgnition()`
  - `setIgnition(boolean)`
  - plus tag/horn/bell helpers
- OpenComputers HTTP is enabled and OpenOS provides `wget`

Implementation goals:
1. Create the planned repo structure and docs under `immersive_railroading/`.
2. Fully implement `programs/train_controller.lua` as a single-file controller.
3. Keep the other listed program files as short TODO skeletons only.
4. Add `AGENTS.md`, progressive docs, the plan copy, and this prompt file.
5. Add pure-Lua preview/test files and run them locally.
6. Validate syntax with `luac -p`.
7. Summarize what was implemented, what was tested, and any remaining uncertainties.

Controller requirements:
- Support `inspect`
- Support `goto <x> <y> <z> [cruise_kmh] [stop_buffer_m]`
- Use train data from `ir_remote_control.info()` and `getPos()`
- Derive PID scales from train characteristics instead of raw magic constants
- Learn brake capability from observed deceleration
- Use a stop-speed envelope based on remaining distance
- Keep the code one file
- Explain key decisions with “why” comments

Required preview/test coverage:
- PID derivation preview
- brake-learning preview
- stop-profile preview
- manifest validation preview
- reservation logic preview
- local syntax checks for all Lua files

Before coding:
- Read the plan and `AGENTS.md` first.
- Inspect the current contents of `immersive_railroading/`.
- Preserve the planned separation between the real controller and future skeleton programs.
- If any plan point conflicts with observed repo/runtime facts, document the mismatch and choose the safest implementation that stays closest to the plan.
