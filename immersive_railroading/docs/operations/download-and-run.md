# Download And Run

## Hosting Assumption
- Files are expected to be hosted on GitHub Raw.
- `programs/install_manifest.lua` uses raw URLs in the shape:
  - `https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/<ref>/immersive_railroading/...`

## OpenOS Install Flow
From an OpenComputers machine inside OpenOS:

```sh
mkdir -p /home/immersive_railroading
cd /home/immersive_railroading
wget -f https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/main/immersive_railroading/programs/install.lua programs/install.lua
wget -f https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/main/immersive_railroading/programs/ir_install.lua programs/ir_install.lua
wget -f https://raw.githubusercontent.com/MrPhaot/IR-Automatisierung/main/immersive_railroading/programs/install_manifest.lua programs/install_manifest.lua
lua programs/ir_install.lua
```

Why this is the preferred entrypoint:
- `install` is already an OpenOS system command, so using that name is misleading.
- `ir_install.lua` avoids the name collision and still delegates to the same project installer logic.
- `lua programs/install.lua` also works, but `lua programs/ir_install.lua` is the documented default.

## Update Flow
- Replace `main` with a branch, tag, or commit ref when you want reproducible installs.
- Re-run `lua programs/ir_install.lua` after updating `programs/install_manifest.lua`.
- When testing a non-`main` ref such as a feature branch or commit SHA, `programs/install_manifest.lua` still points to `main`, so branch-specific controller testing is safer with direct `wget` for the individual files you want to deploy.

## Train Controller Invocation
Preferred OpenOS entrypoint:

```sh
cd /home/immersive_railroading/programs
trainctl inspect --log
trainctl goto -120 64 -35 40 3 --log=test.log
trainctl goto -120 64 -35 40 3 --via -80 64 -20 --via -45 64 -10 --log=test-curve.log
trainctl goto -120 64 -35 40 3 --profile=fast --log=test-fast.log
trainctl route depot_to_yard --log=route-test.log
```

Fallback when you explicitly want to invoke the Lua frontend:

```sh
cd /home/immersive_railroading/programs
lua train_controller.lua -- inspect --log
lua train_controller.lua -- goto -120 64 -35 40 3 --log=test.log
lua train_controller.lua -- goto -120 64 -35 40 3 --via -80 64 -20 --log=test-curve.log
lua train_controller.lua -- route depot_to_yard --log=route-test.log
```

Why this matters:
- OpenOS `lua` parses command-line options before your script runs.
- Without the separating `--`, negative coordinates like `-35` and flags like `--log` never reach `train_controller.lua`.
- `trainctl` avoids that pre-processing and passes the arguments through unchanged.
- If you omit `--profile`, `trainctl goto` defaults to `conservative`.
- `trainctl route` uses the route defaults from `route_book.lua` unless you override the profile on the CLI.
- `--profile` only changes the end-phase driving style; `cruise_kmh` and `stop_buffer_m` still keep their normal meaning.
- `stop_buffer_m` still defines the stop point separately from the profile choice; it does not replace `--profile`.
- Intermediate `--via` points are pass-through geometry only; only the final waypoint uses the terminal stop envelope.
- `route_book.lua` ships as an empty schema, so `trainctl route <name>` only works after you add your own stations and routes for this save.

## Station Dispatcher Invocation
From `/home/immersive_railroading/programs`:

```sh
lua station_dispatch.lua run ore_loop --log=station_dispatch.log
lua station_dispatch.lua validate
lua station_dispatch.lua inspect ore_loop
lua station_dispatch.lua detectors
```

Why this stays separate:
- `train_controller.lua` still owns only local motion control along a chosen route
- `station_dispatch.lua` owns schedule order, detector waits, and station-side redstone outputs

## Augment Configuration

Augment filtering is configured in-game through the **AugmentFilterGUI** (tag/predicate filters:
includeTags/excludeTags, positiveFilter/negativeFilter, stockDetectorMode, locoControlMode,
redstoneMode, pushpull, couplerAugmentMode). The older right-click / redstone-torch configuration
method is superseded. Tags are managed via augment `getTag`/`setTag` plus the filter's
includeTags/excludeTags fields, not a stock-config `tags` key.

The `/immersiverailroading reload` command still exists in this 1.11.0 build and reloads config;
do not document it as removed.

## Route Book Editor Invocation
From `/home/immersive_railroading/programs`:

```sh
lua route_book_editor.lua
```

Editor direction:
- mouse is the primary interaction path
- tabs cover detectors, stations, routes, schedules, and save/validate
- keyboard use is limited to prompted text entry plus terminal escape/interrupt behavior

## Test-World Log Location

The current OpenComputers test machine writes logs under a path shaped like:

`<launcher_root>/instances/<instance_name>/minecraft/saves/<world_name>/opencomputers/<computer_uuid>/home/immersive_railroading/programs/`

Useful real example logs found under that pattern:
- `train_controller.log`
- `station_dispatch.log`
- `path_test37.log`
- `path_test38.log`
- additional `path_test*.log` and earlier `reverse_test*.log` files from older controller phases

That directory pattern is inspect-only for this project, but it is the quickest place to verify what `--log` captured during an in-game run.

Current interpretation of those reference logs:
- Current controller reference family as of commit `a67fcee`: `path_test*.log`.
- `path_test37.log` and `path_test38.log` are the verified terminal examples for the speed-centric branch at commit `a67fcee`.
- The current logs include both the speed-centric longitudinal signals and the terminal guidance diagnostics in the same line stream, including:
  - `speed_plan_limit_mps`
  - `speed_plan_command_mps`
  - `speed_plan_target_mps`
  - `speed_plan_force_mode`
  - `terminal_speed_commit_active`
  - `d_term_active`
  - `effort_cmd`
  - `allocated_throttle`
  - `allocated_brake`
  - `stop_guidance_entry_margin_m`
  - `stop_guidance_required_stop_m`
- Older `reverse_test*.log` files remain useful historical evidence for earlier phases, but for commit `a67fcee` they are no longer the main baseline for current controller behavior.

## Dev Note

The current local developer machine uses this exact path:

`~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/`

That exact hashed path is the current program path for the active OpenComputers machine.
The parent `opencomputers/` directory may also contain older non-hashed logs from earlier phases, so both locations can be relevant during local debugging.
The portable directory pattern above remains the stable documentation target.

## Safety Notes
- The installer rejects:
  - absolute paths
  - `..` path traversal
  - duplicate manifest paths
- Keep manifest paths repo-relative under `immersive_railroading/`.
- Do not use bare `install`, because that calls the OpenOS system installer instead of this project.

## Offline Or Manual Fallback
- Copy the `immersive_railroading/` folder into the OpenOS filesystem manually.
- Prefer `cd /home/immersive_railroading/programs && trainctl inspect` to confirm the control card is visible.
- If you explicitly need the Lua frontend, use `cd /home/immersive_railroading/programs && lua train_controller.lua -- inspect`.
