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
trainctl goto -120 64 -35 40 3 --profile=fast --log=test-fast.log
```

Fallback when you explicitly want to invoke the Lua frontend:

```sh
cd /home/immersive_railroading/programs
lua train_controller.lua -- inspect --log
lua train_controller.lua -- goto -120 64 -35 40 3 --log=test.log
```

Why this matters:
- OpenOS `lua` parses command-line options before your script runs.
- Without the separating `--`, negative coordinates like `-35` and flags like `--log` never reach `train_controller.lua`.
- `trainctl` avoids that pre-processing and passes the arguments through unchanged.
- If you omit `--profile`, `trainctl goto` defaults to `conservative`.
- `stop_buffer_m` still defines the stop point separately from the profile choice; it does not replace `--profile`.

## Test-World Log Location
The current OpenComputers test machine writes logs under:

`~/.local/share/PrismLauncher/instances/HBM NTM 2/minecraft/saves/TEST (1)/opencomputers/6999b5c9-34da-42d3-9ab9-c02972b55cfc/home/immersive_railroading/programs/`

Useful real examples from that directory:
- `train_controller.log`
- `reverse_test.log`
- `reverse_test1.log`
- `reverse_test3.log`
- `reverse_test4.log`
- `reverse_test5.log`
- `reverse_test7.log`
- `reverse_test8.log`
- `reverse_test10.log`
- `reverse_test11.log`
- `reverse_test14.log`
- `reverse_test15.log`
- `reverse_test16.log`

That path is inspect-only for this project, but it is the quickest place to verify what `--log` captured during an in-game run.

Current interpretation of those reference logs:
- `reverse_test3.log` and `reverse_test5.log` are the main straight-line reference runs; they reach the target but were used to tune remaining overshoot in the last meters.
- `reverse_test4.log` is a curve-target case and should be treated as a documented V1 limitation, not the baseline acceptance test for the straight-line controller.
- `reverse_test7.log` showed that small near-target roll-away must still stop first instead of immediately flipping into reverse recovery.
- `reverse_test8.log` showed the follow-up edge case: after stop-first, the controller must either accept a small residual miss as near-target arrival or start only a tiny correction move, rather than deadlocking a few meters short.
- `reverse_test10.log` showed the next refinement: after `stop_first`, the controller must let a valid micro-correction actually leave brake mode instead of staying in a `brake=0`, `throttle=0` deadlock.
- `reverse_test11.log` is the same scenario with `stop_buffer_m=1`; it makes it easier to see when the residual miss is already too large for a micro-correction and should be logged as a V1 limit instead.
- `reverse_test12.log` and `reverse_test13.log` showed the next tuning target: the default profile should brake early enough that straight-line arrivals do not need to fall back to reverse recovery in the first place.
- `reverse_test14.log` is the main conservative-profile under-target reference: it brakes early enough to avoid reverse, but then stops too far short and must transition into a very slow final forward crawl instead of deadlocking.
- `reverse_test15.log` is the current good `fast`-profile straight-line reference with `stop_buffer_m=3`.
- `reverse_test16.log` contains both `stop_buffer_m=1` profile runs, so it is the main side-by-side comparison for how `fast` and `conservative` diverge under a tighter stop point.

## Safety Notes
- The installer rejects:
  - absolute paths
  - `..` path traversal
  - duplicate manifest paths
- Keep manifest paths repo-relative under `immersive_railroading/`.
- Do not use bare `install`, because that calls the OpenOS system installer instead of this project.

## Offline Or Manual Fallback
- Copy the `immersive_railroading/` folder into the OpenOS filesystem manually.
- Run `lua programs/train_controller.lua inspect` to confirm the control card is visible.
